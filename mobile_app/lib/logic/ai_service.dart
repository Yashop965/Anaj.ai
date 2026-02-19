import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image/image.dart' as img; // For image processing
import '../data/database_helper.dart';
import 'treatment_logic.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // For Float32List

class AIService {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool get isReady => _interpreter != null && _labels != null;

  Future<bool> loadModel() async {
    try {
      print("Attempting to load model from: assets/models/crop_slm.tflite");
      _interpreter = await Interpreter.fromAsset('assets/models/crop_slm.tflite');
      print("TFLite Model Loaded Successfully. Interpreter address: $_interpreter");
      
      // Load Labels
      print("Attempting to load labels from: assets/models/labelmap.txt");
      final labelData = await rootBundle.loadString('assets/models/labelmap.txt');
      _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
      print("Labels Loaded (${_labels?.length}): $_labels");
      
      return true;
    } catch (e, stackTrace) {
      print("CRITICAL ERROR loading model/labels: $e");
      print(stackTrace);
      await _runDiagnostics();
      return false;
    }
  }

  Future<void> _runDiagnostics() async {
    print("\n--- STARTING MODEL DIAGNOSTICS ---");
    try {
      // 1. Check Asset Existence
      print("[DIAGNOSTIC] 1. Checking asset 'assets/models/crop_slm.tflite'...");
      final byteData = await rootBundle.load('assets/models/crop_slm.tflite');
      print("[DIAGNOSTIC]    -> Asset FOUND. Size: ${byteData.lengthInBytes} bytes");

      // 2. Check Valid TFLite Format
      print("[DIAGNOSTIC] 2. Attempting to create Interpreter from Buffer...");
      final buffer = byteData.buffer.asUint8List();
      final interpreter = await Interpreter.fromBuffer(buffer);
      print("[DIAGNOSTIC]    -> Interpreter created SUCCESSFULLY from buffer.");
      interpreter.close();
      
      print("[DIAGNOSTIC] 3. Checking Label Map...");
      final labelData = await rootBundle.loadString('assets/models/labelmap.txt');
      print("[DIAGNOSTIC]    -> Label File Content (First 50 chars): ${labelData.substring(0, labelData.length > 50 ? 50 : labelData.length)}");

    } catch (e) {
      print("[DIAGNOSTIC] !!! FAILURE !!!");
      print("[DIAGNOSTIC] Error: $e");
    }
    print("--- END DIAGNOSTICS ---\n");
  }

  Future<Map<String, dynamic>> analyzeImage(String imagePath, String cropType) async {
    if (_interpreter == null) {
      print("Interpreter not ready. Attempting fallback to Boss Model (Cloud).");
      if (await _hasInternet()) {
        return await _uploadToBossModel(imagePath);
      } else {
        return {
              'label': "Model Error & No Internet",
              'confidence': 0.0,
              'is_local': false,
              'action_plan': ["Local AI failed and no internet connection."],
              'audio_text': "Model load nahi hua aur internet bhi nahi hai.",
              'hindi_name': "तकनीकी त्रुटि (Error)"
           };
      }
    }

    try {
      // 1. Read and Resize Image
      var imageBytes = await File(imagePath).readAsBytes();
      var image = img.decodeImage(imageBytes);
      if (image == null) throw Exception("Failed to decode image");

      // Resize to 224x224 (Standard for MobileNet/ResNet)
      var resized = img.copyResize(image, width: 224, height: 224);

      // 2. Convert to Tensor Input [1, 224, 224, 3]
      var input = _imageToByteListFloat32(resized, 224, 127.5, 127.5);
      
      // 3. Output Buffer [1, NUM_CLASSES]
      int numClasses = _labels?.length ?? 10;
      var output = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);

      // 4. Run Inference
      _interpreter!.run(input, output);

      // 5. Parse Output
      List<double> probabilities = List<double>.from(output[0]);
      int maxIndex = 0;
      double maxProb = 0.0;
      
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }
      
      // Map index to Label
      String label = (_labels != null && maxIndex < _labels!.length) 
          ? _labels![maxIndex] 
          : "Unknown ($maxIndex)";
      
      return _processResult(label, maxProb, imagePath);

    } catch (e, stackTrace) {
      print("CRITICAL INFERENCE FAILURE: $e");
      print(stackTrace);
      return _getStubResult();
    }
  }
  
  // Helper: Convert Image to Float32 List with Normalization
  List<dynamic> _imageToByteListFloat32(img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        // image package v4 uses .r, .g, .b directly on the pixel
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }
    return convertedBytes.reshape([1, inputSize, inputSize, 3]);
  }

  Future<Map<String, dynamic>> _processResult(String label, double confidence, String imagePath) async {
     final dbHelper = DatabaseHelper();
     Map<String, dynamic> result;
     
     if (confidence > 0.7) {
       var plan = TreatmentLogic.getPlan(label);
       result = {
        'label': label,
        'confidence': confidence,
        'is_local': true,
        'action_plan': plan['action_plan'],
        'audio_text': plan['audio_text'],
        'hindi_name': plan['hindi_name']
      };
      
      // Save High Confidence Result
      await dbHelper.insertDiagnosis({
        'imagePath': imagePath,
        'diseaseName': label,
        'confidence': confidence,
        'timestamp': DateTime.now().toIso8601String(),
        'isSynced': 1, 
        'actionPlan': plan['action_plan'].join('\n'),
        'audioUrl': "" 
      });

     } else {
       // Low Confidence -> Boss Model
       print("Low Confidence ($confidence). Syncing with Boss Model...");
       if (await _hasInternet()) {
          result = await _uploadToBossModel(imagePath);
       } else {
          result = {
              'label': "Low Confidence ($label)",
              'confidence': confidence,
              'is_local': false,
              'action_plan': ["Internet required for Expert Analysis."],
              'audio_text': "Expert jaanch ke liye internet chahiye.",
              'hindi_name': "विशेषज्ञ जांच (Expert Review)"
           };
       }
       
       // Save Low Confidence / Cloud Result
       await dbHelper.insertDiagnosis({
        'imagePath': imagePath,
        'diseaseName': result['label'],
        'confidence': result['confidence'],
        'timestamp': DateTime.now().toIso8601String(),
        'isSynced': result['is_local'] == false ? 1 : 0, 
        'actionPlan': (result['action_plan'] as List).join('\n'),
        'audioUrl': ""
       });
     }
     
     return result;
  }

  Map<String, dynamic> _getStubResult() {
     return {
        'label': 'Stub: Early Blight',
        'confidence': 0.85, 
        'hindi_name': 'अगेती झुलसा (Stub)',
        'audio_text': "Yeh ek stub result hai.",
        'action_plan': ["Check connections", "Retry scan"]
     };
  }
  
  // 6. Boss Model Fallback (Node.js)
  Future<Map<String, dynamic>> _uploadToBossModel(String imagePath) async {
    try {
      print("Uploading to Boss Model (Node.js)...");
      var uri = Uri.parse('http://10.0.2.2:3000/predict'); // Android Emulator localhost
      // For real device: Use your PC's IP, e.g., http://192.168.1.5:3000/predict
      
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
         var responseData = await response.stream.bytesToString();
         var json = jsonDecode(responseData);
         
         return {
            'label': json['label'],
            'confidence': json['confidence'],
            'is_local': false,
            'action_plan': [json['action_plan']], // Adjust based on actual JSON
            'audio_text': json['action_plan'], // Simply speak the plan
            'hindi_name': "विशेषज्ञ सलाह (Expert Advice)"
         };
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Boss Model Error: $e");
      return _getStubResult(); // Fallback to stub if server down
    }
  }

  // Helper to check Internet
  Future<bool> _hasInternet() async {
    // ... existing logic
    return true; // Stub for now
  }
}



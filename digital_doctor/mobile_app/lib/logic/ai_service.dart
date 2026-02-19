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
      _labels = labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();
      
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

      // 4. Model Signature Inspection
      print("[DIAGNOSTIC] 4. Inspecting Model Signature...");
      var inputTensor = interpreter.getInputTensor(0);
      var outputTensor = interpreter.getOutputTensor(0);
      print("[DIAGNOSTIC]    -> Input Shape: ${inputTensor.shape}, Type: ${inputTensor.type}");
      print("[DIAGNOSTIC]    -> Output Shape: ${outputTensor.shape}, Type: ${outputTensor.type}");
      
      interpreter.close();

    } catch (e) {
      print("[DIAGNOSTIC] !!! FAILURE !!!");
      print("[DIAGNOSTIC] Error: $e");
    }
    print("--- END DIAGNOSTICS ---\n");
  }

  Future<Map<String, dynamic>> analyzeImage(String imagePath, String cropType, {double? lat, double? lng}) async {
    if (_interpreter == null) {
      print("Interpreter not ready. Attempting fallback to Boss Model (Cloud).");
      if (await hasInternet()) {
      if (await hasInternet()) {
         return await _uploadToBossModel(File(imagePath), cropType, lat: lat, lng: lng);
      } else {
         return {
           'label': 'Model Error',
           'confidence': 0.0,
           'hindi_name': 'AI मॉडल लोड नहीं हो सका',
           'action_plan': ["कृपया इंटरनेट कनेक्ट करें और पुनः प्रयास करें।"],
           'audio_text': "AI Model load nahi hua. Internet connect karein."
         };
      }
    }

    try {
      // 1. Preprocess Image
      var imageBytes = File(imagePath).readAsBytesSync();
      var inputImage = img.decodeImage(imageBytes)!;
      
      // FIX: Handle EXIF Rotation (Critical for Mobile Photos)
      inputImage = img.bakeOrientation(inputImage);
      
      var resizedImage = img.copyResize(inputImage, width: 224, height: 224);
      
      // 2. Convert to TensorBuffer 
      // EfficientNetB3 expects [0, 255] range (Float32)
      var inputBuffer = _imageToByteBuffer(resizedImage, mean: 0.0, std: 1.0);

      // 3. Run Inference
      // Get Output Shape Dynamically
      var outputTensor = _interpreter!.getOutputTensor(0);
      var outputShape = outputTensor.shape; 
      int numClasses = outputShape[outputShape.length - 1]; // Last dimension
      print("[AI DEBUG] Model Output Shape: $outputShape, NumClasses: $numClasses");

      var outputBuffer = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);
      _interpreter!.run(inputBuffer, outputBuffer);
      
      // 4. Parse Results
      var output = List<double>.from(outputBuffer[0]);
      var stats = _getTopResult(output);
      double maxConf = stats.value;
      int maxIdx = stats.key;
      
      String label = 'Unknown';
      if (_labels != null && maxIdx < _labels!.length) {
         label = _labels![maxIdx];
      } else {
         print("[AI DEBUG] Index $maxIdx out of bounds (Labels: ${_labels?.length})");
      }
      
      print("[AI DEBUG] Prediction: Index=$maxIdx, Label='$label', Conf=$maxConf");

      // --- FALLBACK CHECK: If result is garbage, try [-1, 1] ---
      // Some TFLite converters might strip the rescaling layer.
      if (maxConf < 0.4) {
        print("[AI DEBUG] Low confidence ($maxConf) with [0, 255]. Retrying with [-1, 1]...");
        var inputBuffer2 = _imageToByteBuffer(resizedImage, mean: 127.5, std: 127.5);
        var outputBuffer2 = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);
        _interpreter!.run(inputBuffer2, outputBuffer2);
        
        var stats2 = _getTopResult(List<double>.from(outputBuffer2[0]));
        if (stats2.value > maxConf) {
           print("[AI DEBUG] Normalization [-1, 1] gave BETTER result: ${stats2.value}");
           maxConf = stats2.value;
           maxIdx = stats2.key;
           if (_labels != null && maxIdx < _labels!.length) {
             label = _labels![maxIdx];
           }
        }
      }
      // -----------------------------------------------------------

      label = (_labels != null && _labels!.length > maxIdx) ? _labels![maxIdx] : 'Unknown';
      
      // 5. Get Treatment Plan
      var treatment = TreatmentLogic.getPlan(label);
      
      Map<String, dynamic> result = {
        'label': label,
        'confidence': maxConf,
        'hindi_name': treatment['hindi_name'],
        'action_plan': treatment['action_plan'],
        'audio_text': treatment['audio_text'],
        'image_path': imagePath,
        'latitude': lat,
        'longitude': lng
      };
      
      // 6. Hybrid Logic
      if (maxConf < 0.6) { // Lower local threshold slightly
         print("Low Confidence ($maxConf). Checking Cloud...");
         if (await hasInternet()) {
         if (await hasInternet()) {
           return await _uploadToBossModel(File(imagePath), cropType, lat: lat, lng: lng);
         } else {
           // Save local result but mark for sync
           await _processResult(result, isSynced: false); 
           result['label'] = result['label'] + " (Low Confidence - Offline)";
           return result;
         }
      } else {
         await _processResult(result, isSynced: true);
         return result;
      }
      
    } catch (e) {
      print("Inference Error: $e");
      return _getStubResult();
    }
  }

  // Helper: Find Max
  MapEntry<int, double> _getTopResult(List<double> output) {
    int maxIdx = 0;
    double maxConf = 0.0;
    for (int i = 0; i < output.length; i++) {
        if (output[i] > maxConf) {
          maxConf = output[i];
          maxIdx = i;
        }
    }
    return MapEntry(maxIdx, maxConf);
  }
  
  // Helper: Convert Image to Float32 List with Normalization
  // Helper: Convert Image to Float32 List with Normalization
  // EfficientNet models (Keras) usually expect [0, 255] input as they have internal Rescaling layers.
  // So Mean = 0.0, Std = 1.0.
  Object _imageToByteBuffer(img.Image image, {double mean = 0.0, double std = 1.0}) {
     return _imageToByteListFloat32(image, 224, mean, std);
  }

  Object _imageToByteListFloat32(img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }
    return convertedBytes.reshape([1, inputSize, inputSize, 3]);
  }

  Future<Map<String, dynamic>> _processResult(Map<String, dynamic> result, {required bool isSynced}) async {
     final dbHelper = DatabaseHelper();
     
     // Save to DB
     await dbHelper.insertDiagnosis({
        'imagePath': result['image_path'],
        'diseaseName': result['label'],
        'confidence': result['confidence'],
        'timestamp': DateTime.now().toIso8601String(),
        'isSynced': isSynced ? 1 : 0, 
        'actionPlan': (result['action_plan'] as List<dynamic>).join('\n'),
        'audioUrl': "",
        'latitude': result['latitude'],
        'longitude': result['longitude']
      });
      
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
  // 6. Boss Model Fallback (Node.js)
  Future<Map<String, dynamic>> _uploadToBossModel(File imageFile, String cropType, {double? lat, double? lng}) async {
    try {
      print("Uploading to Boss Model (Node.js)...");
      // UPDATED: Using Laptop's IP for Local Network Access
      // Run 'ipconfig' on laptop to find this. Currently: 172.20.10.7
      var uri = Uri.parse('http://172.20.10.7:3000/predict'); 
      
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      request.fields['crop'] = cropType;
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
         var responseData = await response.stream.bytesToString();
         var json = jsonDecode(responseData);
         
         var result = {
            'label': json['label'] ?? 'Unknown',
            'confidence': json['confidence'] ?? 0.0,
            'is_local': false,
            'action_plan': [json['action_plan'] ?? "Consult expert"], 
            'audio_text': json['action_plan'] ?? "Expert se salah lein.",
            'hindi_name': "विशेषज्ञ सलाह (Expert Advice)",
            'image_path': imageFile.path, 
            'latitude': lat, 
            'longitude': lng
         };
         
         await _processResult(result, isSynced: true); // SAVE TO DB!
         return result;
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Boss Model Error: $e");
      return _getStubResult(); // Fallback to stub if server down
    }
  }

  // 7. Hybrid Cloud Report Generation (New)
  Future<Map<String, dynamic>> generateCloudReport(String imagePath, String localLabel, String cropType, {double? lat, double? lng}) async {
    if (!await hasInternet()) {
      return {'error': "No Internet"};
    }

    try {
      print("Generating Cloud Report for $localLabel...");
      // Using Laptop IP: 172.20.10.7
      var uri = Uri.parse('http://172.20.10.7:3000/predict'); 
      
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      request.fields['crop'] = cropType;
      request.fields['local_label'] = localLabel; // Tell server our local guess
      request.fields['mode'] = 'report'; // Tell server we want a detailed report
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
         var responseData = await response.stream.bytesToString();
         var json = jsonDecode(responseData);
         
         // Create Full Result Map
         var result = {
            'label': json['label'] ?? localLabel, // Keep local label if cloud is vague, or use cloud's
            'confidence': json['confidence'] ?? 1.0, 
            'is_local': false,
            'action_plan': [json['action_plan'] ?? "See Detailed Report"],
            'audio_text': json['action_plan'] ?? "Report generated.",
            'hindi_name': "विशेषज्ञ रिपोर्ट (Expert Report)",
            'image_path': imagePath,
            'latitude': lat,
            'longitude': lng,
            'ai_insight': json['ai_insight'], // Custom field, handled by UI, not DB yet
            'severity': json['severity']
         };

         // SAVE TO DB so it appears in History
         await _processResult(result, isSynced: true);

         return json; // Return original JSON for UI rendering logic
      } else {
        return {'error': "Server Code: ${response.statusCode}"};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Helper to check Internet
  Future<bool> hasInternet() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile || 
          connectivityResult == ConnectivityResult.wifi) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}



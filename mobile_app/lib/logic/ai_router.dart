import 'dart:io';
// import 'package:tflite_flutter/tflite_flutter.dart'; // Commented out to avoid analysis errors in stub environment
import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:http/http.dart' as http; // Basic stub

class AIRouter {
  // Interpreter? _interpreter; // Stub for TFLite interpreter

  Future<void> loadModel() async {
    // try {
    //   _interpreter = await Interpreter.fromAsset('assets/models/crop_slm.tflite');
    // } catch (e) {
    //   print("Error loading model: $e");
    // }
    print("Model loaded (Simulated)");
  }

  Future<Map<String, dynamic>> processImage(String imagePath) async {
    // Step 1: Run Local SLM (Fast & Offline)
    final localResult = await _runLocalModel(imagePath);
    
    final double confidence = localResult['confidence'];
    final dbHelper = DatabaseHelper();

    if (confidence > 0.8) {
      // High Confidence: Instant Feedback
      print("High confidence detected: ${localResult['label']}");
      
      Map<String, dynamic> record = {
        'imagePath': imagePath,
        'diseaseName': localResult['label'],
        'confidence': confidence,
        'timestamp': DateTime.now().toIso8601String(),
        'isSynced': 1, // No need to sync for boss model verification (MVP logic) or strictly 1 if we treat local as final
        'actionPlan': "Generic Action Plan for ${localResult['label']}",
        'audioUrl': "" // To be generated
      };
      
      await dbHelper.insertDiagnosis(record);
       // triggerAudioReport(localResult); // Call to UI/Audio service
      return localResult;
      
    } else {
      // Step 2: Low Confidence? Queue for Boss Model
      print("Low confidence: $confidence. Queueing for Boss Model.");
      
      Map<String, dynamic> record = {
        'imagePath': imagePath,
        'diseaseName': "Pending Analysis",
        'confidence': confidence,
        'timestamp': DateTime.now().toIso8601String(),
        'isSynced': 0, // Pending Sync
        'actionPlan': "",
        'audioUrl': ""
      };
      
      await dbHelper.insertDiagnosis(record);

      if (await _hasInternet()) {
        return await _uploadToBossModel(imagePath);
      } else {
         return {
           'label': "Uncertain",
           'message': "Local analysis uncertain. Saved for cloud analysis when internet returns."
         };
      }
    }
  }

  Future<Map<String, dynamic>> _runLocalModel(String imagePath) async {
    // STUB: Simulate TFLite inference
    // In real app: Resize image -> Bytebuffer -> Interpreter -> Output Tensor
    await Future.delayed(Duration(milliseconds: 500));
    
    // Simulating a result. Change logic here to test flows.
    bool emulateHighConfidence = true; 
    
    if (emulateHighConfidence) {
       return {'label': 'Early Blight', 'confidence': 0.85};
    } else {
       return {'label': 'Unknown', 'confidence': 0.45};
    }
  }

  Future<bool> _hasInternet() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<Map<String, dynamic>> _uploadToBossModel(String imagePath) async {
    print("Uploading to Boss Model (FastAPI)...");
    // STUB: Http post to FastAPI
    // var request = http.MultipartRequest('POST', Uri.parse('http://YOUR_API_IP:8000/predict'));
    await Future.delayed(Duration(seconds: 2));
    
    return {
      'label': 'Boss Model: Late Blight', 
      'confidence': 0.98,
      'actionPlan': 'Apply Fungicide X' // This would actually come from Bhashini flow
    };
  }
}

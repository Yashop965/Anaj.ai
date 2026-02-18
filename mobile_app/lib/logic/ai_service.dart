import 'dart:io';
// import 'package:tflite_flutter/tflite_flutter.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/database_helper.dart';
import 'treatment_logic.dart';

class AIService {
  // Interpreter? _interpreter;

  Future<void> loadModel() async {
    // try {
    //   _interpreter = await Interpreter.fromAsset('assets/models/crop_slm.tflite');
    //   print("TFLite Model Loaded");
    // } catch (e) {
    //   print("Error loading model: $e");
    // }
     print("TFLite Model Loaded (Stub)");
  }

  Future<Map<String, dynamic>> analyzeImage(String imagePath, String cropType) async {
    // 1. Run Local SLM (Stubbed for MVP)
    // var input = imageToGenerators(imagePath);
    // var output = List.filled(1 * 10, 0).reshape([1, 10]);
    // _interpreter?.run(input, output);
    
    // Simulating result
    double confidence = 0.85; // Change below 0.7 to test Boss Model flow
    String label = "Early Blight"; 

    final dbHelper = DatabaseHelper();
    Map<String, dynamic> result;

    if (confidence > 0.7) {
      // High Confidence - Local Result
      var plan = TreatmentLogic.getPlan(label);
      result = {
        'label': label,
        'confidence': confidence,
        'is_local': true,
        'action_plan': plan['action_plan'],
        'audio_text': plan['audio_text'],
        'hindi_name': plan['hindi_name']
      };
      
      await dbHelper.insertDiagnosis({
        'imagePath': imagePath,
        'diseaseName': label,
        'confidence': confidence,
        'timestamp': DateTime.now().toIso8601String(),
        'isSynced': 1,
        'actionPlan': result['action_plan'].toString(),
        'audioUrl': "" // TTS will generate local audio
      });

    } else {
      // Low Confidence - Boss Model Route
      bool hasNet = await _hasInternet();
      
      if (hasNet) {
        // TODO: Upload to Boss Model (FastAPI)
        // For MVP, we return a "Pending" state
         result = {
          'label': "Analysis Pending",
          'confidence': confidence,
          'is_local': false,
          'action_plan': ["Syncing with Boss Model...", "Please wait for expert verification."],
          'audio_text': "Humare expert iski jaanch kar rahe hain. Kripya prateeksha karein.",
          'hindi_name': "विशेषज्ञ जांच (Expert Review)"
        };
      } else {
         result = {
          'label': "Stored Offline",
          'confidence': confidence,
          'is_local': false,
          'action_plan': ["Saved to gallery.", "Will upload when internet is available."],
          'audio_text': "Internet nahi hai. Humne photo save kar li hai.",
          'hindi_name': "भंडारित (Saved)"
        };
      }
      
      await dbHelper.insertDiagnosis({
        'imagePath': imagePath,
        'diseaseName': "Pending ($label)",
        'confidence': confidence,
        'timestamp': DateTime.now().toIso8601String(),
        'isSynced': 0,
        'actionPlan': "",
        'audioUrl': ""
      });
    }
    
    return result;
  }

  Future<bool> _hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}

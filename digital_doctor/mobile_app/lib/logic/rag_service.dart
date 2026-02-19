import 'dart:convert';
import 'package:flutter/services.dart';

class RAGResult {
  final String answer;
  final List<String> options; // For disambiguation
  final List<String> followUps; // Suggested next questions
  final Map<String, dynamic>? data; // The actual disease object if found

  RAGResult({
    required this.answer,
    this.options = const [],
    this.followUps = const [],
    this.data,
  });
}

class RAGService {
  static final RAGService _instance = RAGService._internal();
  factory RAGService() => _instance;
  RAGService._internal();

  List<dynamic> _knowledgeBase = [];
  
  // Context Management
  Map<String, dynamic>? _currentContext;
  List<Map<String, dynamic>>? _ambiguousContexts;

  Future<void> loadKnowledgeBase() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/knowledge_base.json');
      final data = jsonDecode(jsonString);
      _knowledgeBase = data['diseases'];
      print("RAG Knowledge Base Loaded: ${_knowledgeBase.length} entries.");
    } catch (e) {
      print("Error loading RAG Knowledge Base: $e");
    }
  }

  // Enhanced Context-Aware Search
  RAGResult search(String query) {
    query = query.toLowerCase();

    // 0. Check for Context Reset
    if (query.contains("reset") || query.contains("new") || query.contains("nayi")) {
      _currentContext = null;
      _ambiguousContexts = null;
      return RAGResult(answer: "Thik hai, naye sire se shuru karte hain. Batayein?");
    }

    // 1. Handle Ambiguity Selection (User picked an option)
    if (_ambiguousContexts != null && _ambiguousContexts!.isNotEmpty) {
      for (var potentialMatch in _ambiguousContexts!) {
        if (query.contains(potentialMatch['disease_name_hi'].toLowerCase()) ||
            query.contains(potentialMatch['disease_name_en'].toLowerCase())) {
          _currentContext = potentialMatch;
          _ambiguousContexts = null; // Clear ambiguity
          return _generateFullResponse(_currentContext!);
        }
      }
    }

    // 2. Handle Follow-up Questions (Context Aware)
    if (_currentContext != null) {
      if (query.contains("treatment") || query.contains("upchar") || query.contains("ilaj") || query.contains("dawa")) {
        return RAGResult(
          answer: _formatTreatment(_currentContext!),
          followUps: ["Lakshan (Symptoms)", "Karan (Causes)", "Reset"],
          data: _currentContext
        );
      } else if (query.contains("symp") || query.contains("lakshan") || query.contains("dikh")) {
        return RAGResult(
          answer: "Lakshan: ${_currentContext!['symptoms']}",
           followUps: ["Upchar (Treatment)", "Land Info", "Reset"],
           data: _currentContext
        );
      } else if (query.contains("land") || query.contains("mitti") || query.contains("zamin")) {
        return RAGResult(
          answer: "Zamin/Mitti ki Jaankari: ${_currentContext!['rag_land_info']}",
           followUps: ["Upchar (Treatment)", "Reset"],
           data: _currentContext
        );
      }
    }
    
    // 3. Perform Fresh Search
    List<Map<String, dynamic>> matches = [];
    for (var disease in _knowledgeBase) {
      String nameEn = disease['disease_name_en'].toString().toLowerCase();
      String nameHi = disease['disease_name_hi'].toString().toLowerCase();
      
      if (query.contains(nameEn) || query.contains(nameHi) || query.contains(disease['crop_name'].toLowerCase())) {
        matches.add(disease);
      }
    }

    // 4. Handle Search Results
    if (matches.isEmpty) {
      return RAGResult(answer: "Maaf kijiye, koi jaankari nahi mili. 'Reset' bol kar dubara shuru karein.");
    } else if (matches.length == 1) {
      _currentContext = matches.first;
      _ambiguousContexts = null;
      return _generateFullResponse(_currentContext!);
    } else {
      // Ambiguity Detected
      _ambiguousContexts = matches;
      List<String> validOptions = matches.map((m) => m['disease_name_hi'].toString()).toList();
      return RAGResult(
        answer: "Ek se zyada bimariyan mili hain. Kripya chunein:",
        options: validOptions,
      );
    }
  }

  RAGResult _generateFullResponse(Map<String, dynamic> disease) {
    String name = disease['disease_name_hi'];
    return RAGResult(
      answer: "Yeh $name hai. \n\n${disease['symptoms']}",
      followUps: ["Iska Upchar (Treatment)?", "Mitti ki Jankari (Land Info)?"],
      data: disease
    );
  }
  
  String _formatTreatment(Map<String, dynamic> disease) {
    Map<String, dynamic> plan = disease['treatment_plan_7_days'];
    return "7-Day Plan:\n" +
           "Day 1: ${plan['day_1']}\n" +
           "Day 2: ${plan['day_2']}\n" +
           "Day 3: ${plan['day_3']}\n" +
           "Day 7: ${plan['day_7']}";
  }

  // Format Answer for TTS (Simplified)
  String getTTSAnswer(RAGResult result) {
    return result.answer.replaceAll("\n", " ").replaceAll("*", "");
  }
}

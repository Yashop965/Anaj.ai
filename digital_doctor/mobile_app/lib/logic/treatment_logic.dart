class TreatmentLogic {
  
  // Offline Knowledge Base: Disease Label -> 7-Day Action Plan
  static final Map<String, Map<String, dynamic>> _diseaseDatabase = {
    'Early Blight': {
      'hindi_name': 'अगेती झुलसा (Early Blight)',
      'action_plan': [
        "Day 1: Remove and destroy infected leaves immediately.",
        "Day 2: Spray Copper Oxychloride (2.5g/liter of water).",
        "Day 3: Monitor for new spots.",
        "Day 4: Ensure proper drainage in the field.",
        "Day 5: Apply Mancozeb 75 WP (2g/liter) if spreading.",
        "Day 6: Add Potassium fertilizer to boost immunity.",
        "Day 7: Re-scan the crop to check progress."
      ],
      'audio_text': "Kisan bhai, yeh Ageti Jhulsa hai. Turant prabhavit patton ko hata de aur nasht karein. Copper Oxychloride ka chidkaav karein."
    },
    'Late Blight': {
      'hindi_name': 'पछेती झुलसा (Late Blight)',
      'action_plan': [
        "Day 1: Do NOT irrigate. Moisture spreads this fungus.",
        "Day 2: Spray Metalaxyl + Mancozeb (2.5g/liter).",
        "Day 3: Check nearby fields for spread.",
        "Day 4: Repeat spray if it rains.",
        "Day 5: Remove weeds to lower humidity.",
        "Day 6: Monitor stem lesions.",
        "Day 7: Contact Krishi Vigyan Kendra if uncontrolled."
      ],
      'audio_text': "Yeh Pacheti Jhulsa hai. Sinchai turant rok dein. Metalaxyl aur Mancozeb ka chidkaav karein."
    },
    'Healthy': {
      'hindi_name': 'स्वस्थ फसल (Healthy)',
      'action_plan': [
        "Day 1: Continue regular monitoring.",
        "Day 2: Maintain proper irrigation schedule.",
        "Day 3: Ensure balanced NPK fertilization.",
        "Day 4: Keep field weed-free.",
        "Day 5: Scout for early signs of pests.",
        "Day 6: Check soil moisture.",
        "Day 7: Relax! Your crop is doing great."
      ],
      'audio_text': "Badhai ho! Aapki fasal swasth hai. Dekhbhaal jaari rakhein."
    },
    'Unknown': {
      'hindi_name': 'अनजान बीमारी (Unknown)',
      'action_plan': [
        "Day 1: Isolate the affected plant.",
        "Day 2: Take clear photos and sync with Digital Doctor.",
        "Day 3: Wait for expert analysis from the cloud.",
        "Day 4: Do not over-water.",
        "Day 5: Inspect under-leaf surfaces for pests.",
        "Day 6: Prepare neem oil spray as precaution.",
        "Day 7: Check app for updates."
      ],
      'audio_text': "Bimari ki pehchan nahi ho paayi hai. Hum ise expert ke paas bhej rahe hain. Kripya shanti banaye rakhein."
    }
  };

  static Map<String, dynamic> getPlan(String label) {
    // 1. Exact Match
    if (_diseaseDatabase.containsKey(label)) {
      return _diseaseDatabase[label]!;
    }

    // 2. Partial Match (e.g., "Potato___Early_Blight" -> "Early Blight")
    if (label.contains("Early_Blight")) return _diseaseDatabase['Early Blight']!;
    if (label.contains("Late_Blight")) return _diseaseDatabase['Late Blight']!;
    if (label.contains("Healthy")) return _diseaseDatabase['Healthy']!;
    

    
    // 3. New Specific Mappings for Corn/Rice/Wheat
    if (label.contains("Common_Rust") || label.contains("Brown_Rust") || label.contains("Yellow_Rust")) {
       var steps = [
             "Day 1: Isolate infected plants.",
             "Day 2: Spray Mancozeb (2.5g/L).",
             "Day 3: Check for orange pustules.",
             "Day 4: Avoid overhead irrigation.",
             "Day 5: Apply Propiconazole if severe.",
             "Day 7: Re-scan."
       ];
       return {
          'hindi_name': 'रतुआ रोग (Rust)',
          'action_plan': steps,
          'audio_text': _generateAudio("Ratua Rog", steps)
       };
    }

    if (label.contains("Leaf_Blast") || label.contains("Neck_Blast")) {
       var steps = [
             "Day 1: Maintain water level.",
             "Day 2: Spray Tricyclazole (0.6g/L).",
             "Day 3: Remove infected weeds.",
             "Day 4: Avoid excess Nitrogen.",
             "Day 7: Re-scan."
       ];
       return {
          'hindi_name': 'झोंका रोग (Blast)',
          'action_plan': steps,
          'audio_text': _generateAudio("Jhoka Rog", steps)
       };
    }
    
    if (label.contains("Gray_Leaf_Spot") || label.contains("Brown_Spot")) {
       var steps = [
             "Day 1: Clean field sanitation.",
             "Day 2: Spray Carbendazim (1g/L).",
             "Day 5: Monitor progress.",
             "Day 7: Re-scan."
       ];
       return {
          'hindi_name': 'धब्बा रोग (Leaf Spot)',
          'action_plan': steps,
          'audio_text': _generateAudio("Dhabba Rog", steps)
       };
    }

    if (label.contains("Bacterial Blight")) {
       var steps = [
             "Day 1: Drain the field immediately.",
             "Day 2: Spray Streptocycline (1g) + Copper Oxychloride (500g) per 200L water.",
             "Day 3: Reduce nitrogen fertilizer.",
             "Day 4: Avoid field-to-field water flow.",
             "Day 5: Monitor for yellow oozing drops.",
             "Day 7: Re-scan."
       ];
       return {
          'hindi_name': 'जीवाणु झुलसा (Bacterial Blight)',
          'action_plan': steps,
          'audio_text': _generateAudio("Jeevanu Jhulsa", steps)
       };
    }

    if (label.contains("Red Rot")) {
       var steps = [
             "Day 1: Uproot and burn infected clumps.",
             "Day 2: Do not use sets from this field for seed.",
             "Day 3: Improve drainage.",
             "Day 4: Rotate crop with rice or wheat next season.",
             "Day 5: Treat seeds with fungicide before planting.",
             "Day 7: Re-scan."
       ];
       return {
          'hindi_name': 'लाल सड़न रोग (Red Rot)',
          'action_plan': steps,
          'audio_text': _generateAudio("Laal Sadan Rog", steps)
       };
    }

    return _diseaseDatabase['Unknown']!;
  }
  // Helper to generate full audio from plan
  static String _generateAudio(String diseaseName, List<String> plan) {
    String audio = "Ye raha $diseaseName ka 7 din ka upchar. ";
    for (var step in plan) {
      audio += step + ". ";
    }
    return audio;
  }
}

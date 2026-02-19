/// Multilingual treatment recommendation translations
/// Supports English, Hindi, Punjabi, and Haryanvi

class TreatmentTranslations {
  static const Map<String, Map<String, Map<String, String>>> translations = {
    'English': {
      'titles': {
        'cure_duration': 'Treatment Duration',
        'action_plan': 'Recommended Actions',
        'severity': 'Severity Level',
        'estimated_recovery': 'Estimated Recovery Time',
      },
      'treatments': {
        '3_days': '3 Days Treatment',
        '7_days': '7 Days Treatment',
        '14_days': '14 Days Treatment',
        '21_days': '21 Days Treatment',
        '30_days': '30 Days Treatment',
      },
      'descriptions': {
        '3_days': 'Monitor closely and apply recommended treatment. Recovery expected in 3 days.',
        '7_days': 'Apply recommended spray/treatment for 7 consecutive days for best results.',
        '14_days': 'Follow treatment regimen for 14 days. Check crop health every 2-3 days.',
        '21_days': 'Long-term treatment required. Monitor closely for 21 days.',
        '30_days': 'Extended treatment period. Regular monitoring and follow-ups recommended.',
      },
      'actions': {
        'apply_spray': 'Apply recommended spray/fungicide',
        'monitor': 'Monitor crop health daily',
        'check_moisture': 'Check soil moisture levels',
        'ensure_drainage': 'Ensure proper drainage',
        'prune_affected': 'Prune affected leaves/branches',
        'apply_fertilizer': 'Apply recommended fertilizer',
        'maintain_ph': 'Maintain soil pH between 5.5-7.5',
      },
      'severity': {
        'low': 'Low',
        'medium': 'Medium',
        'high': 'High',
        'critical': 'Critical',
      }
    },
    'Hindi': {
      'titles': {
        'cure_duration': 'उपचार अवधि',
        'action_plan': 'अनुशंसित कार्य',
        'severity': 'गंभीरता स्तर',
        'estimated_recovery': 'अनुमानित रिकवरी समय',
      },
      'treatments': {
        '3_days': '3 दिन का उपचार',
        '7_days': '7 दिन का उपचार',
        '14_days': '14 दिन का उपचार',
        '21_days': '21 दिन का उपचार',
        '30_days': '30 दिन का उपचार',
      },
      'descriptions': {
        '3_days': 'बारीकी से निगरानी करें और अनुशंसित उपचार लागू करें। 3 दिन में ठीक होने की उम्मीद है।',
        '7_days': 'सर्वोत्तम परिणामों के लिए 7 लगातार दिनों तक अनुशंसित स्प्रे/उपचार लागू करें।',
        '14_days': '14 दिनों तक उपचार का पालन करें। हर 2-3 दिन में फसल के स्वास्थ्य की जांच करें।',
        '21_days': 'दीर्घकालिक उपचार आवश्यक है। 21 दिनों तक बारीकी से निगरानी करें।',
        '30_days': 'विस्तारित उपचार अवधि। नियमित निगरानी और फॉलो-अप की सिफारिश की जाती है।',
      },
      'actions': {
        'apply_spray': 'अनुशंसित स्प्रे/कवकनाशी लागू करें',
        'monitor': 'प्रतिदिन फसल के स्वास्थ्य की निगरानी करें',
        'check_moisture': 'मिट्टी की नमी की जांच करें',
        'ensure_drainage': 'उचित जल निकासी सुनिश्चित करें',
        'prune_affected': 'प्रभावित पत्तियों/शाखाओं को काटें',
        'apply_fertilizer': 'अनुशंसित खाद लागू करें',
        'maintain_ph': 'मिट्टी का pH 5.5-7.5 के बीच बनाए रखें',
      },
      'severity': {
        'low': 'कम',
        'medium': 'मध्यम',
        'high': 'उच्च',
        'critical': 'गंभीर',
      }
    },
    'Punjabi': {
      'titles': {
        'cure_duration': 'ਇਲਾਜ ਦੀ ਮਿਆਦ',
        'action_plan': 'ਸਿਫਾਰਸ਼ ਕੀਤੀਆਂ ਕਾਰਵਾਈਆਂ',
        'severity': 'ਗੰਭੀਰਤਾ ਦਾ ਪੱਧਰ',
        'estimated_recovery': 'ਅਨੁਮਾਨਤ ਰਿਕਵਰੀ ਸਮਾਂ',
      },
      'treatments': {
        '3_days': '3 ਦਿਨ ਦਾ ਇਲਾਜ',
        '7_days': '7 ਦਿਨ ਦਾ ਇਲਾਜ',
        '14_days': '14 ਦਿਨ ਦਾ ਇਲਾਜ',
        '21_days': '21 ਦਿਨ ਦਾ ਇਲਾਜ',
        '30_days': '30 ਦਿਨ ਦਾ ਇਲਾਜ',
      },
      'descriptions': {
        '3_days': 'ਧਿਆਨ ਨਾਲ ਨਿਰੀਖਣ ਕਰੋ ਅਤੇ ਸਿਫਾਰਸ਼ ਕੀਤਾ ਇਲਾਜ ਲਾਗੂ ਕਰੋ। 3 ਦਿਨਾਂ ਵਿਚ ਠੀਕ ਹੋਣ ਦੀ ਉਮੀਦ ਹੈ।',
        '7_days': 'ਸਰਵੋਤਮ ਨਤੀਜਿਆਂ ਲਈ 7 ਲਗਾਤਾਰ ਦਿਨਾਂ ਲਈ ਸਿਫਾਰਸ਼ ਕੀਤਾ ਛਿੜਕਾਅ/ਇਲਾਜ ਲਾਗੂ ਕਰੋ।',
        '14_days': '14 ਦਿਨਾਂ ਲਈ ਇਲਾਜ ਦਾ ਪਾਲਣ ਕਰੋ। ਹਰ 2-3 ਦਿਨਾਂ ਵਿਚ ਫਸਲ ਦੀ ਸਿਹਤ ਦੀ ਜਾਂਚ ਕਰੋ।',
        '21_days': 'ਲੰਬੀ ਮਿਆਦ ਦਾ ਇਲਾਜ ਲਾਜ਼ੀ ਹੈ। 21 ਦਿਨਾਂ ਤੱਕ ਧਿਆਨ ਨਾਲ ਨਿਰੀਖਣ ਕਰੋ।',
        '30_days': 'ਵਿਸਤ੍ਰਿਤ ਇਲਾਜ ਮਿਆਦ। ਨਿਯਮਤ ਨਿਰੀਖਣ ਅਤੇ ਫਾਲੋ-ਅਪ ਦੀ ਸਿਫਾਰਸ਼ ਕੀਤੀ ਜਾਂਦੀ ਹੈ।',
      },
      'actions': {
        'apply_spray': 'ਸਿਫਾਰਸ਼ ਕੀਤਾ ਛਿੜਕਾਅ/ਫੰਗਸਾਈਡ ਲਾਗੂ ਕਰੋ',
        'monitor': 'ਦਿਨ ਭਰ ਫਸਲ ਦੀ ਸਿਹਤ ਦੀ ਨਿਗਰਾਨੀ ਕਰੋ',
        'check_moisture': 'ਮਿੱਟੀ ਦੀ ਨਮੀ ਦੀ ਜਾਂਚ ਕਰੋ',
        'ensure_drainage': 'ਸਹੀ ਡ੍ਰੇਨੇਜ ਯਕੀਨੀ ਬਣਾਓ',
        'prune_affected': 'ਪ੍ਰਭਾਵਿਤ ਪੱਤਿਆਂ/ਸ਼ਾਖਾਵਾਂ ਨੂੰ ਕੱਟੋ',
        'apply_fertilizer': 'ਸਿਫਾਰਸ਼ ਕੀਤਾ ਖਾਦ ਲਾਗੂ ਕਰੋ',
        'maintain_ph': 'ਮਿੱਟੀ ਦਾ pH 5.5-7.5 ਦੇ ਵਿਚ ਬਣਾਓ',
      },
      'severity': {
        'low': 'ਘੱਟ',
        'medium': 'ਮੱਧਮ',
        'high': 'ਉੱਚ',
        'critical': 'ਨਾਜ਼ੁਕ',
      }
    },
    'Haryanvi': {
      'titles': {
        'cure_duration': 'इलाज का समय',
        'action_plan': 'सुझाई गई कार्रवाई',
        'severity': 'गंभीरता का स्तर',
        'estimated_recovery': 'अनुमानित ठीक होने का समय',
      },
      'treatments': {
        '3_days': '3 दिन का इलाज',
        '7_days': '7 दिन का इलाज',
        '14_days': '14 दिन का इलाज',
        '21_days': '21 दिन का इलाज',
        '30_days': '30 दिन का इलाज',
      },
      'descriptions': {
        '3_days': 'बारीकी से निरीक्षण करो और सलाह दिए गए इलाज लागू करो। 3 दिन में ठीक होने की उम्मीद है।',
        '7_days': 'सबसे अच्छे परिणामों के लिए 7 लगातार दिनों तक सलाह दी गई दवा/इलाज लागू करो।',
        '14_days': '14 दिन तक इलाज का पालन करो। हर 2-3 दिन में फसल की सेहत देखो।',
        '21_days': 'लंबे समय का इलाज जरूरी है। 21 दिन तक बारीकी से निरीक्षण करो।',
        '30_days': 'बढ़ी हुई इलाज अवधि। नियमित निरीक्षण और अनुवर्ती सलाह की सिफारिश की जाती है।',
      },
      'actions': {
        'apply_spray': 'सलाह दी गई दवा/कवकनाशी लागू करो',
        'monitor': 'हर दिन फसल की सेहत देखो',
        'check_moisture': 'मिट्टी की नमी की जांच करो',
        'ensure_drainage': 'सही जल निकासी सुनिश्चित करो',
        'prune_affected': 'प्रभावित पत्तों/शाखों को काटो',
        'apply_fertilizer': 'सलाह दी गई खाद लागू करो',
        'maintain_ph': 'मिट्टी का pH 5.5-7.5 के बीच रखो',
      },
      'severity': {
        'low': 'कम',
        'medium': 'मध्यम',
        'high': 'ज्यादा',
        'critical': 'बहुत गंभीर',
      }
    },
  };

  /// Get translation by language and key path
  static String translate(String language, String category, String key) {
    return translations[language]?[category]?[key] ?? 
           translations['English']?[category]?[key] ?? 
           key; // Fallback to key if translation not found
  }

  /// Get cure duration translation (e.g., '7_days' -> '7 Days Treatment' or '7 दिन का उपचार')
  static String getCureDuration(String days, String language) {
    final key = '${days.replaceAll(RegExp(r'[^0-9]'), '')}_days';
    return translate(language, 'treatments', key);
  }

  /// Get cure description (detailed explanation of treatment)
  static String getCureDescription(String days, String language) {
    final key = '${days.replaceAll(RegExp(r'[^0-9]'), '')}_days';
    return translate(language, 'descriptions', key);
  }

  /// Get action translation with fallback to English
  static String getAction(String actionKey, String language) {
    return translate(language, 'actions', actionKey);
  }

  /// Get severity level translation
  static String getSeverity(String level, String language) {
    final key = level.toLowerCase();
    return translate(language, 'severity', key);
  }

  /// Supported languages
  static const List<String> supportedLanguages = [
    'English',
    'Hindi',
    'Punjabi',
    'Haryanvi',
  ];

  /// Get language code for language (for API calls if needed)
  static String getLanguageCode(String language) {
    const codes = {
      'English': 'en',
      'Hindi': 'hi',
      'Punjabi': 'pa',
      'Haryanvi': 'brx', // Bodo for Haryanvi dialects
    };
    return codes[language] ?? 'en';
  }
}

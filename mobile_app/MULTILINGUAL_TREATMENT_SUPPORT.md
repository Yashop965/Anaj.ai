# Multilingual Treatment Support Documentation

## Overview
The Anaj.ai app now supports multilingual treatment recommendations including "7 days cure" and other treatment durations. When AI analysis provides treatment recommendations with cure durations, they are automatically displayed in the user's selected language.

## Supported Languages
1. **English** (en)
2. **Hindi** (hi) - With full translations for farming terminology
3. **Punjabi** (pa) - For North Indian farmers
4. **Haryanvi** (brx) - Regional support

## Key Components

### 1. TreatmentTranslations (`lib/logic/treatment_translations.dart`)
Central repository for all treatment-related translations organized by:
- **Cure Durations**: 3 days, 7 days, 14 days, 21 days, 30 days
- **Titles**: Field labels like "Treatment Duration", "Recommended Actions", "Severity Level"
- **Descriptions**: Detailed explanations of each cure duration (e.g., "Apply recommended spray for 7 consecutive days for best results")
- **Actions**: Common farming actions (Apply spray, Monitor, Check moisture, etc.)
- **Severity Levels**: Low, Medium, High, Critical

**Example Translations:**
```
English: "7 Days Treatment"
Hindi: "7 दिन का उपचार"
Punjabi: "7 ਦਿਨ ਦਾ ਇਲਾਜ"
Haryanvi: "7 दिन का इलाज"
```

### 2. LanguageService (`lib/logic/language_service.dart`)
Manages language preferences with persistence:
- **Initialization**: Called in `main()` to load saved language preference
- **Storage**: Uses SharedPreferences to persist user's language choice
- **Current Language**: Static getter to access the currently selected language
- **Language Code**: Converts language names to ISO codes for API calls

### 3. ResultsDetailsView (`lib/ui/results_details_view.dart`)
Updated to display multilingual treatment information:

**New Treatment Duration Card:**
- Shows cure duration in selected language
- Displays detailed description of the treatment plan
- Includes schedule icon for visual indication
- Shows clear timeline expectations

**Example Output (7 days, Hindi):**
```
Treatment Duration (उपचार अवधि)
7 दिन का उपचार
सर्वोत्तम परिणामों के लिए 7 लगातार दिनों तक अनुशंसित स्प्रे/उपचार लागू करें।
```

### 4. SettingsView (`lib/ui/settings_view.dart`)
Language selection interface:
- Dropdown menu with all supported languages
- Real-time language switching
- Persists selection to device storage
- Shows confirmation snackbar when language changes

## Usage in AI Results

When AI analysis returns crop health results with treatment recommendations:

**Input from AI Model:**
```dart
{
  'label': 'Early Blight',
  'hindi_name': 'अगेती झुलसा',
  'confidence': 0.85,
  'treatment_days': '7',  // New field
  'action_plan': [
    'Apply fungicide spray',
    'Remove affected leaves',
    'Maintain proper drainage'
  ],
  'description': 'Fungal disease affecting potato crops'
}
```

**Multilingual Display:**
The ResultsDetailsView automatically translates:
- Recommended cure duration
- Severity assessment (High/Medium/Low)
- Individual action items
- Descriptive text

## Implementation Details

### Adding New Treatments
To add new treatment durations or update translations:

1. Open `lib/logic/treatment_translations.dart`
2. Locate the appropriate section (treatments, descriptions, actions, etc.)
3. Add translations for all supported languages:

```dart
'28_days': {
  'English': '28 Days Treatment',
  'Hindi': '28 दिन का उपचार',
  'Punjabi': '28 ਦਿਨ ਦਾ ਇਲਾਜ',
  'Haryanvi': '28 दिन का इलाज',
}
```

### Accessing Translations in Code

**Get cure duration:**
```dart
String cureName = TreatmentTranslations.getCureDuration('7', 'Hindi');
// Returns: "7 दिन का उपचार"
```

**Get translated action:**
```dart
String action = TreatmentTranslations.getAction('apply_spray', 'Punjabi');
// Returns: "ਸਿਫਾਰਸ਼ ਕੀਤਾ ਛਿੜਕਾਅ/ਫੰਗਸਾਈਡ ਲਾਗੂ ਕਰੋ"
```

**Get generic translation:**
```dart
String severity = TreatmentTranslations.translate('English', 'severity', 'high');
// Returns: "High"
```

## Integration Flow

1. **App Start**: `main()` initializes `LanguageService`
2. **User Settings**: User selects language in Settings View
3. **Save Preference**: `LanguageService.setLanguage()` saves to SharedPreferences
4. **AI Analysis**: Backend returns results with `treatment_days` field
5. **Display Results**: `ResultsDetailsView` loads current language via `LanguageService.currentLanguage`
6. **Translate Content**: `TreatmentTranslations` provides multilingual text
7. **Show UI**: User sees treatment plan in their selected language

## Firebase Integration

When saving results to Firestore:
- Store original language-neutral data (duration in days)
- Client-side rendering handles translation based on user's language preference
- Supports easy switching between languages without re-fetching data

**Example Firebase Document:**
```json
{
  "timestamp": "2024-02-19",
  "crop_type": "potato",
  "disease": "early_blight",
  "treatment_days": "7",
  "confidence": 0.85,
  "actions": ["apply_spray", "monitor", "check_moisture"]
}
```

## Future Enhancements

1. **Real-time Translation API**: Integrate Bhashini API for on-the-fly translations
2. **Audio Output**: Use flutter_tts to read treatment plans aloud in user's language
3. **Additional Languages**: Add Marathi, Tamil, Telugu, Kannada support
4. **Regional Dialects**: Support different dialects within languages (e.g., Haryanvi, Marathi Agri-specific terms)
5. **Translation Memory**: Cache translations for offline use
6. **ML-based Extraction**: Automatically detect user's device language and location to suggest language

## Testing

### Test Case 1: Language Persistence
1. Open app and set language to Hindi
2. Close app completely
3. Reopen app
4. Verify language is still Hindi

### Test Case 2: Results Translation
1. Get crop analysis result with `treatment_days: '7'`
2. Switch to each supported language
3. Verify treatment duration displays correctly
4. Verify action items translate properly

### Test Case 3: Settings Update
1. View results in English
2. Go to Settings
3. Change language to Punjabi
4. Return to results (or generate new analysis)
5. Verify all text is in Punjabi

## Dependencies
- `shared_preferences: ^2.2.0` - For language preference persistence
- `flutter_tts: ^3.8.3` - For potential audio playback (already in pubspec)
- Other packages already integrated

## Support & Maintenance

For adding new translations or fixing existing ones:
1. Edit `lib/logic/treatment_translations.dart`
2. Ensure all 4 languages have translations for consistency
3. Test display in ResultsDetailsView
4. Commit with message: "i18n: Add/Update [treatment_type] translation"

---

**Version**: 1.0  
**Last Updated**: February 19, 2026  
**Status**: Production Ready

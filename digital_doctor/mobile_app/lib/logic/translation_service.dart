import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TranslationService {
  // Singleton
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final _onDeviceTranslator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.hindi,
  );

  final _modelManager = OnDeviceTranslatorModelManager();

  /// Checks if the Hindi model is downloaded.
  Future<bool> isModelDownloaded() async {
    return await _modelManager.isModelDownloaded(TranslateLanguage.hindi.bcpCode);
  }

  /// Downloads the Hindi model if not present.
  /// Returns check if model is downloaded.
  Future<bool> downloadModel() async {
    try {
      final bool isDownloaded = await isModelDownloaded();
      if (isDownloaded) return true;

      // Check Connectivity
      final ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw "No Internet connection available to download model.";
      }

      print("Downloading Hindi Model...");
      
      // Attempt download with a timeout of 2 minutes (it's around 30MB)
      await _modelManager.downloadModel(TranslateLanguage.hindi.bcpCode).timeout(
        Duration(minutes: 2),
        onTimeout: () {
          throw "Download timed out. Check internet connection.";
        },
      );
      
      print("Download Complete.");
      return await isModelDownloaded();
    } catch (e) {
      print("Model Download Failed: $e");
      throw e.toString(); // Propagate error to UI
    }
  }

  /// Deletes the model to free space (optional).
  Future<void> deleteModel() async {
    await _modelManager.deleteModel(TranslateLanguage.hindi.bcpCode);
  }

  /// Translates text from English to Hindi.
  /// Ensures model is downloaded before translating.
  Future<String> translate(String text) async {
    if (text.trim().isEmpty) return "";
    
    // Ensure model is ready
    try {
      bool ready = await downloadModel();
      if (!ready) {
        return "Error: Model failed to download.";
      }
    } catch (e) {
      return "Error: $e";
    }

    try {
      final String response = await _onDeviceTranslator.translateText(text);
      return response;
    } catch (e) {
      print("Translation Error: $e");
      return text; // Return original text on failure
    }
  }

  void dispose() {
    _onDeviceTranslator.close();
  }
}

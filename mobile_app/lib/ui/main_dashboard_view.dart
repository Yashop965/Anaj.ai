import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'dashboard_view.dart';
import 'community_view.dart';
import 'history_view.dart';
import 'profile_view.dart';
import 'settings_view.dart';
import 'login_view.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../logic/ai_service.dart';
import '../logic/firebase_auth_service.dart';
import '../logic/app_logger.dart';
import '../logic/performance_service.dart';
import 'widgets/custom_widgets.dart';
import 'widgets/professional_widgets.dart';

class MainDashboardView extends StatefulWidget {
  @override
  _MainDashboardViewState createState() => _MainDashboardViewState();
}

class _MainDashboardViewState extends State<MainDashboardView> {
  final AIService _aiService = AIService();
  final FlutterTts flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

  int _selectedBottomNavIndex = 0;
  String _selectedCrop = 'Sugarcane';
  final List<String> _crops = ['Sugarcane', 'Wheat', 'Corn', 'Potato', 'Rice'];

  Map<String, dynamic>? _lastResult;
  bool _isScanning = false;
  double _healthScore = 0.85;
  File? _selectedImage;

  bool _isModelReady = false;
  bool _isLoadingModel = true;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initApp();
  }

  Future<void> _initApp() async {
    final monitor = PerformanceMonitor('App Initialization');
    try {
      AppLogger.info('Initializing app and loading AI model');
      bool success = await _aiService.loadModel();
      await _initTts();
      
      if (mounted) {
        setState(() {
          _isModelReady = success;
          _isLoadingModel = false;
        });

        if (!success) {
          AppLogger.warn('Local model failed, using Cloud Mode', tag: 'ai_service');
          await ErrorHandler.showSnackBar(
            context,
            message: "Using Cloud Mode (Local AI Failed to Load)",
            isError: true,
          );
        } else {
          AppLogger.info('Model loaded successfully');
        }
      }
      monitor.complete(tag: 'model_loaded');
    } catch (e, st) {
      AppLogger.error('App initialization failed', e, st, tag: 'init');
      monitor.complete(tag: 'error');
      if (mounted) {
        setState(() {
          _isModelReady = false;
          _isLoadingModel = false;
        });
      }
    }
  }

  Future<void> _initTts() async {
    try {
      await flutterTts.setLanguage("hi-IN");
      await flutterTts.setPitch(1.0);
      AppLogger.debug('TTS initialized');
    } catch (e) {
      AppLogger.warn('TTS initialization failed: $e', tag: 'tts');
    }
  }

  Future<void> _retryLocalModel() async {
    setState(() {
      _isLoadingModel = true;
    });
    await _initApp();
  }

  Future<void> _scanCrop() async {
    final monitor = PerformanceMonitor('Crop Scan');
    try {
      AppLogger.info('Starting crop capture and analysis', tag: 'scan');
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo == null) {
        AppLogger.info('User cancelled image selection');
        return;
      }

      AppLogger.info('Image selected: ${photo.path}', tag: 'scan');
      
      setState(() {
        _isScanning = true;
        _lastResult = null;
        _selectedImage = File(photo.path);
      });

      AppLogger.info('Analyzing image for crop: $_selectedCrop', tag: 'scan');
      var result = await _aiService.analyzeImage(photo.path, _selectedCrop);
      monitor.complete(tag: 'analysis_complete');
      _handleResult(result);
    } on Exception catch (e, st) {
      AppLogger.error('Crop scan failed', e, st, tag: 'scan');
      monitor.complete(tag: 'error');
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ErrorHandler.handleError(
          context,
          title: 'Scan Failed',
          message: 'Could not analyze the image. Please try again.',
          onRetry: _scanCrop,
          buttonText: 'Retry',
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo == null) return;

      setState(() {
        _isScanning = true;
        _lastResult = null;
        _selectedImage = File(photo.path);
      });

      var result = await _aiService.analyzeImage(photo.path, _selectedCrop);
      _handleResult(result);
    } catch (e) {
      print("Gallery Error: $e");
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _handleResult(Map<String, dynamic> result) {
    setState(() {
      _isScanning = false;
      _lastResult = result;

      if (result['confidence'] > 0.7 && result['label'] != 'Healthy') {
        if (_healthScore > 0.1) _healthScore -= 0.05;
      } else if (result['label'] == 'Healthy') {
        if (_healthScore < 0.95) _healthScore += 0.05;
      }
    });

    if (result['confidence'] > 0.8) {
      _speak(result['audio_text']);
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.eco, color: Colors.white),
              SizedBox(width: 8),
              Text("Anaj.ai"),
            ],
          ),
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileView()),
                  );
                } else if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsView()),
                  );
                } else if (value == 'logout') {
                  await _firebaseAuth.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginView()),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 10),
                      Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 10),
                      Text('Settings'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _buildPageContent(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedBottomNavIndex,
          onTap: (index) {
            setState(() {
              _selectedBottomNavIndex = index;
            });
            _pageController.jumpToPage(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'COMMUNITY',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'RECORDS',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    if (_selectedBottomNavIndex == 0) {
      return DashboardContentWidget(
        isLoadingModel: _isLoadingModel,
        selectedCrop: _selectedCrop,
        crops: _crops,
        healthScore: _healthScore,
        isScanning: _isScanning,
        lastResult: _lastResult,
        onCropSelected: (crop) {
          setState(() {
            _selectedCrop = crop;
          });
        },
        onTakePhoto: _scanCrop,
        onGalleryUpload: _pickFromGallery,
        onRetryLocalModel: _retryLocalModel,
        isModelReady: _isModelReady,
        speak: _speak,
      );
    } else if (_selectedBottomNavIndex == 1) {
      return CommunityView();
    } else {
      return HistoryView();
    }
  }
}

// Extract dashboard content into a separate widget for reusability
class DashboardContentWidget extends StatelessWidget {
  final bool isLoadingModel;
  final String selectedCrop;
  final List<String> crops;
  final double healthScore;
  final bool isScanning;
  final Map<String, dynamic>? lastResult;
  final Function(String) onCropSelected;
  final VoidCallback onTakePhoto;
  final VoidCallback onGalleryUpload;
  final VoidCallback onRetryLocalModel;
  final bool isModelReady;
  final Function(String) speak;

  const DashboardContentWidget({
    required this.isLoadingModel,
    required this.selectedCrop,
    required this.crops,
    required this.healthScore,
    required this.isScanning,
    required this.lastResult,
    required this.onCropSelected,
    required this.onTakePhoto,
    required this.onGalleryUpload,
    required this.onRetryLocalModel,
    required this.isModelReady,
    required this.speak,
  });

  @override
  Widget build(BuildContext context) {
    return isLoadingModel
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading AI Model...",
                    style: AppTheme.getTheme().textTheme.bodyMedium),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  _buildHeaderSection(),
                  SizedBox(height: 24),

                  // Health Score Card
                  HealthScoreCard(score: healthScore, cropName: selectedCrop),
                  SizedBox(height: 24),

                  // Main Action Cards
                  ActionCard(
                    icon: Icons.camera_alt,
                    title: "Take Photo",
                    subtitle: "Capture directly",
                    onPressed: isScanning ? () {} : onTakePhoto,
                    isPrimary: true,
                  ),
                  SizedBox(height: 12),

                  ActionCard(
                    icon: Icons.image,
                    title: "Gallery Upload",
                    subtitle: "Upload from device",
                    onPressed: isScanning ? () {} : onGalleryUpload,
                    backgroundColor: Colors.grey[100],
                  ),
                  SizedBox(height: 24),

                  // Crop Selector
                  SectionTitle(
                    title: "Select Crop",
                    subtitle: "फसल चुनें",
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: crops.map((crop) {
                      return ChoiceChip(
                        label: Text(crop),
                        selected: selectedCrop == crop,
                        onSelected: (selected) {
                          onCropSelected(crop);
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),

                  // Results Section
                  if (lastResult != null) _buildResultCard(context),
                  SizedBox(height: 24),
                ],
              ),
            ),
          );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Analyze Crop Health",
          style: AppTheme.getTheme().textTheme.displayMedium,
        ),
        SizedBox(height: 8),
        Text(
          "Instant AI diagnosis for pests and diseases.",
          style: AppTheme.getTheme().textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context) {
    var confidence = lastResult!['confidence'] ?? 0.0;
    var label = lastResult!['hindi_name'] ?? lastResult!['label'];
    var actionPlan = lastResult!['action_plan'];

    Color resultColor =
        confidence > 0.7 ? AppTheme.dangerColor : AppTheme.warningColor;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              resultColor.withOpacity(0.1),
              resultColor.withOpacity(0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: resultColor.withOpacity(0.2),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.warning_amber_rounded,
                      color: resultColor, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.volume_up),
              label: Text("SUNO (सुनो)"),
              onPressed: () => speak(lastResult!['audio_text'] ?? ""),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 16),
            if (actionPlan is List && actionPlan.isNotEmpty) ...[
              Text(
                "Recommended Actions:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              ...actionPlan.map<Widget>((step) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle,
                            color: AppTheme.successColor, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
            ],
          ],
        ),
      ),
    );
  }
}

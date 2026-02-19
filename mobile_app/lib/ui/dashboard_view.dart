import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../logic/ai_service.dart';
import '../logic/firebase_auth_service.dart';
import 'history_view.dart';
import 'login_view.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_widgets.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final AIService _aiService = AIService();
  final FlutterTts flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  
  String _selectedCrop = 'Sugarcane';
  final List<String> _crops = ['Sugarcane', 'Wheat', 'Corn', 'Potato', 'Rice'];
  
  Map<String, dynamic>? _lastResult;
  bool _isScanning = false;
  double _healthScore = 0.85;
  File? _selectedImage;
  int _selectedBottomNavIndex = 0;

  bool _isModelReady = false;
  bool _isLoadingModel = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    bool success = await _aiService.loadModel();
    await _initTts();
    if (mounted) {
      setState(() {
        _isModelReady = success;
        _isLoadingModel = false; 
      });
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Using Cloud Mode (Local AI Failed to Load)"), backgroundColor: Colors.orange)
        );
      }
    }
  }

  Future<void> _retryLocalModel() async {
    setState(() {
      _isLoadingModel = true;
    });
    await _initApp();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setPitch(1.0);
  }

  Future<void> _scanCrop() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      if (photo == null) return; // User cancelled

      setState(() {
        _isScanning = true;
        _lastResult = null;
        _selectedImage = File(photo.path);
      });

      // Pass the real image path to the AI Service
      var result = await _aiService.analyzeImage(photo.path, _selectedCrop);
      _handleResult(result);

    } catch (e) {
      print("Camera Error: $e");
      setState(() { _isScanning = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing image: $e"))
      );
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
      setState(() { _isScanning = false; });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ARow(
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
              if (value == 'logout') {
                final firebaseAuth = FirebaseAuthService();
                await firebaseAuth.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              } else if (value == 'profile') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Profile feature coming soon")),
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
      body: _isLoadingModel
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading AI Model...", style: AppTheme.getTheme().textTheme.bodyMedium),
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
                    HealthScoreCard(score: _healthScore, cropName: _selectedCrop),
                    SizedBox(height: 24),

                    // Main Action Cards
                    ActionCard(
                      icon: Icons.camera_alt,
                      title: "Take Photo",
                      subtitle: "Capture directly",
                      onPressed: _isScanning ? null : _scanCrop,
                      isPrimary: true,
                    ),
                    SizedBox(height: 12),

                    ActionCard(
                      icon: Icons.image,
                      title: "Gallery Upload",
                      subtitle: "Upload from device",
                      onPressed: _isScanning ? null : _pickFromGallery,
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
                      children: _crops.map((crop) {
                        return ChoiceChip(
                          label: Text(crop),
                          selected: _selectedCrop == crop,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCrop = crop;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),

                    // History Button
                    ElevatedButton.icon(
                      icon: Icon(Icons.history),
                      label: Text("View Analysis History"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HistoryView()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Results Section
                    if (_lastResult != null) _buildResultCard(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });
          // Add navigation logic here if needed
          if (index == 2) {
            // Navigate to Records
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryView()),
            );
          }
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
      ] ),
      ),
    );
  }

  Widget _buildResultCard() {
    var confidence = _lastResult!['confidence'] ?? 0.0;
    var label = _lastResult!['hindi_name'] ?? _lastResult!['label'];
    var actionPlan = _lastResult!['action_plan'];

    Color resultColor = confidence > 0.7 ? AppTheme.dangerColor : AppTheme.warningColor;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [resultColor.withOpacity(0.1), resultColor.withOpacity(0.05)],
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
                  child: Icon(Icons.warning_amber_rounded, color: resultColor, size: 28),
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
              onPressed: () => _speak(_lastResult!['audio_text'] ?? ""),
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
              ...actionPlan.map<Widget>((step) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
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
                ),
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }

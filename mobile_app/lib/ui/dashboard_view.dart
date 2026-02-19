import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../logic/ai_service.dart';
import 'history_view.dart';

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
  double _healthScore = 0.85; // Mock daily score
  File? _selectedImage;

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
      appBar: AppBar(
        title: Text("Anaj.ai"),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Health Score Card
              _buildHealthScoreCard(),
              SizedBox(height: 20),

              // 2. Crop Selector
              Text("Select Crop (फसल चुनें):", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: _crops.map((crop) {
                  return ChoiceChip(
                    label: Text(crop),
                    selected: _selectedCrop == crop,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCrop = crop;
                      });
                    },
                    selectedColor: Colors.green[200],
                  );
                }).toList(),
              ),
              SizedBox(height: 30),

              // 3. Scan Button
              Center(
                child: _isLoadingModel 
                  ? Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Loading AI Model...", style: TextStyle(color: Colors.grey))
                      ],
                    )
                  : GestureDetector(
                  onTap: _isScanning ? null : _scanCrop,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: _isScanning ? Colors.grey : (_isModelReady ? Colors.green[700] : Colors.orange[700]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: (_isModelReady ? Colors.green : Colors.orange).withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
                    ),
                    alignment: Alignment.center,
                    child: _isScanning 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isModelReady ? Icons.camera_alt : Icons.cloud_upload, size: 60, color: Colors.white),
                            Text(_isModelReady ? "SCAN" : "CLOUD SCAN", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(_isModelReady ? "(जांच करें)" : "(इंटरनेट आवश्यक)", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          ],
                        ),
                  ),
                ),
              ),
              if (!_isModelReady && !_isLoadingModel)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextButton.icon(
                    onPressed: _retryLocalModel,
                    icon: Icon(Icons.refresh, color: Colors.green[800]),
                    label: Text("Retry Local Model (लोकल मॉडल फिर से लोड करें)", 
                      style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)),
                  ),
                ),
              SizedBox(height: 20),
              
              // Gallery & History Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isScanning ? null : _pickFromGallery,
                    icon: Icon(Icons.photo_library),
                    label: Text("Gallery"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryView()));
                    },
                    icon: Icon(Icons.history),
                    label: Text("History"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
                  ),
                ],
              ),
              if (_selectedImage != null) ...[
                 SizedBox(height: 10),
                 Center(child: Text("Last Image Captured", style: TextStyle(color: Colors.grey))),
                 // SizedBox(height: 100, child: Image.file(_selectedImage!)) // Optional preview
              ],
              SizedBox(height: 30),

              // 4. Results Section
              if (_lastResult != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Crop Health", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                Text("फसल स्वास्थ", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ],
            ),
            CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 10.0,
              percent: _healthScore,
              center: Text("${(_healthScore * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              progressColor: _healthScore > 0.7 ? Colors.green : Colors.orange,
              backgroundColor: Colors.green[100]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    var confidence = _lastResult!['confidence'] ?? 0.0;
    var label = _lastResult!['hindi_name'] ?? _lastResult!['label'];
    var actionPlan = _lastResult!['action_plan'];

    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 40),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text("Confidence: ${(confidence * 100).toStringAsFixed(1)}%", style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.volume_up, size: 28),
              label: Text("SUNO (सुनो)", style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => _speak(_lastResult!['audio_text'] ?? ""),
            ),
            SizedBox(height: 20),
            if (actionPlan is List)
              ...actionPlan.map<Widget>((step) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 10),
                      Expanded(child: Text(step.toString(), style: TextStyle(fontSize: 16))),
                    ],
                  ),
                )
              ).toList(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../logic/ai_service.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final AIService _aiService = AIService();
  final FlutterTts flutterTts = FlutterTts();
  
  String _selectedCrop = 'Wheat';
  final List<String> _crops = ['Wheat', 'Mustard', 'Bajra', 'Rice', 'Cotton', 'Sugarcane'];
  
  Map<String, dynamic>? _lastResult;
  bool _isScanning = false;
  double _healthScore = 0.85; // Mock daily score

  @override
  void initState() {
    super.initState();
    _aiService.loadModel();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setPitch(1.0);
  }

  Future<void> _scanCrop() async {
    setState(() {
      _isScanning = true;
      _lastResult = null;
    });

    // Simulate image path
    String mockPath = "/path/to/image.jpg";
    var result = await _aiService.analyzeImage(mockPath, _selectedCrop);

    setState(() {
      _isScanning = false;
      _lastResult = result;
      // Update health score based on result (Mock logic)
      if (result['confidence'] > 0.7 && result['label'] != 'Healthy') {
         _healthScore -= 0.05; 
      }
    });

    // Auto-play audio if configured? Or wait for user.
    // _speak(result['audio_text']); 
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
                child: GestureDetector(
                  onTap: _isScanning ? null : _scanCrop,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: _isScanning ? Colors.grey : Colors.green[700],
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
                    ),
                    alignment: Alignment.center,
                    child: _isScanning 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 60, color: Colors.white),
                            Text("SCAN", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            Text("(जांच करें)", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          ],
                        ),
                  ),
                ),
              ),
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
                      Text(_lastResult!['hindi_name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text("Confidence: ${(_lastResult!['confidence']*100).toStringAsFixed(1)}%", style: TextStyle(color: Colors.grey[700])),
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
              onPressed: () => _speak(_lastResult!['audio_text']),
            ),
            SizedBox(height: 20),
            if (_lastResult!['action_plan'] is List)
              ...(_lastResult!['action_plan'] as List).map<Widget>((step) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 10),
                      Expanded(child: Text(step, style: TextStyle(fontSize: 16))),
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

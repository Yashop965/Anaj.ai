import 'package:flutter/material.dart';
import 'dart:io';
import '../logic/translation_service.dart';
import '../logic/haryanvi_converter.dart';

class HistoryDetailView extends StatefulWidget {
  final Map<String, dynamic> item;

  const HistoryDetailView({Key? key, required this.item}) : super(key: key);

  @override
  _HistoryDetailViewState createState() => _HistoryDetailViewState();
}

class _HistoryDetailViewState extends State<HistoryDetailView> {
  final TranslationService _translator = TranslationService();
  bool _isTranslating = false;
  List<String> _translatedPlan = [];
  String? _translatedName;
  
  // Use passed item
  Map<String, dynamic> get item => widget.item;

  bool _isModelDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    bool downloaded = await _translator.isModelDownloaded();
    if (mounted) {
      setState(() {
        _isModelDownloaded = downloaded;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // Parse action plan (stored as newline-separated string)
    List<String> planSteps = (item['actionPlan'] as String).split('\n');
    String date = item['timestamp'].split('T')[0];
    String time = item['timestamp'].split('T')[1].split('.')[0];

    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Details"),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image Header
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: (item['imagePath'] != null && File(item['imagePath']).existsSync())
                    ? DecorationImage(
                        image: FileImage(File(item['imagePath'])),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (item['imagePath'] == null || !File(item['imagePath']).existsSync())
                  ? Icon(Icons.broken_image, size: 80, color: Colors.grey)
                  : null,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title & Specifics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['diseaseName'] ?? "Unknown",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900]),
                        ),
                      ),
                      Chip(
                        label: Text("${(item['confidence'] * 100).toStringAsFixed(1)}%"),
                        backgroundColor: Colors.green[100],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text("Scanned on: $date at $time", style: TextStyle(color: Colors.grey[600])),
                  
                  Divider(height: 30, thickness: 1),

                  // 3. 7-Day Action Plan
                  Text(
                    "7-Day Treatment Plan (Upchar):",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  
                  ...planSteps.where((step) => step.trim().isNotEmpty).map((step) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                            SizedBox(width: 10),
                            Expanded(child: Text(step, style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 20),
                  
                  // 4. Translate / Download Section
                  if (_isTranslating)
                     Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Processing..."),
                            SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _isTranslating = false);
                              },
                              icon: Icon(Icons.cancel, color: Colors.red),
                              label: Text("Stop", style: TextStyle(color: Colors.red)),
                            )
                          ],
                        )
                  else if (!_isModelDownloaded)
                     Column(
                       children: [
                         ElevatedButton.icon(
                            onPressed: () async {
                              setState(() => _isTranslating = true);
                              try {
                                bool success = await _translator.downloadModel();
                                if (success) {
                                  if (mounted) {
                                    setState(() {
                                      _isModelDownloaded = true;
                                      _isTranslating = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hindi Model Downloaded!")));
                                  }
                                } else {
                                  throw "Download returned false";
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() => _isTranslating = false);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download Failed: $e"), backgroundColor: Colors.red));
                                }
                              }
                            },
                            icon: Icon(Icons.download),
                            label: Text("Download Hindi Language (30MB)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text("Required for Offline Translation", style: TextStyle(color: Colors.grey)),
                       ],
                     )
                  else
                     // Model IS downloaded - Show Translate Options
                     Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _translatedName != null
                                  ? null // Already translated
                                  : () async {
                                      setState(() => _isTranslating = true);
                                      
                                      // Translate Name
                                      String name = await _translator.translate(item['diseaseName']);
                                      
                                      // Translate Plan Steps
                                      List<String> newPlan = [];
                                      for (String step in planSteps) {
                                        if (step.trim().isNotEmpty) {
                                          newPlan.add(await _translator.translate(step));
                                        }
                                      }

                                      if (mounted) {
                                        setState(() {
                                          _translatedName = name;
                                          _translatedPlan = newPlan;
                                          _isTranslating = false;
                                        });
                                      }
                                    },
                              icon: Icon(Icons.translate),
                              label: Text(_translatedName == null ? "Translate to Hindi" : "Translated (हिंदी)"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[800],
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                            
                            SizedBox(height: 10),

                            // Haryanvi Button
                             ElevatedButton.icon(
                              onPressed: _translatedName != null && _translatedName!.contains("कड़े") 
                                  ? null 
                                  : () async {
                                      setState(() => _isTranslating = true);
                                      
                                      String hindiName = await _translator.translate(item['diseaseName']);
                                      String haryanviName = HaryanviConverter.convertToHaryanvi(hindiName);
                                      
                                      List<String> newPlan = [];
                                      for (String step in planSteps) {
                                        if (step.trim().isNotEmpty) {
                                          String hindiStep = await _translator.translate(step);
                                          newPlan.add(HaryanviConverter.convertToHaryanvi(hindiStep));
                                        }
                                      }

                                      if (mounted) {
                                        setState(() {
                                          _translatedName = "$haryanviName (हरियाणवी)";
                                          _translatedPlan = newPlan;
                                          _isTranslating = false;
                                        });
                                      }
                                    },
                              icon: Icon(Icons.record_voice_over),
                              label: Text("Translate to Haryanvi (Desi)"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[600],
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                          ],
                        ),
                        
                  // 5. Display Translated Content if available
                  if (_translatedName != null) ...[
                    SizedBox(height: 20),
                    Divider(thickness: 2, color: Colors.orange),
                    Text("हिंदी अनुवाद (Hindi Translation):", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[900])),
                    SizedBox(height: 10),
                    Text(_translatedName!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[900])),
                    SizedBox(height: 10),
                    ..._translatedPlan.map((step) => Card(
                          margin: EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          color: Colors.orange[50],
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle, color: Colors.orange[800], size: 20),
                                SizedBox(width: 10),
                                Expanded(child: Text(step, style: TextStyle(fontSize: 16))),
                              ],
                            ),
                          ),
                        )).toList(),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

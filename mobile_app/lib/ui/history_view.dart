import 'package:flutter/material.dart';
import 'dart:io';
import '../data/database_helper.dart';
import 'theme/app_theme.dart';

class HistoryView extends StatefulWidget {
  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _dbHelper.getAllDiagnoses();
    setState(() {
      _history = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan History"),
        subtitle: Text("इतिहास"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(child: Text("No history found.\nStart scanning crops!", textAlign: TextAlign.center))
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: (item['imagePath'] != null && File(item['imagePath']).existsSync())
                            ? Image.file(File(item['imagePath']), width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        title: Text(item['diseaseName'] ?? "Unknown", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Confidence: ${(item['confidence'] * 100).toStringAsFixed(1)}%"),
                            Text(item['timestamp'].split('T')[0] + " " + item['timestamp'].split('T')[1].split('.')[0], style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Icon(item['isSynced'] == 1 ? Icons.cloud_done : Icons.cloud_off, 
                                     color: item['isSynced'] == 1 ? Colors.blue : Colors.grey),
                        onTap: () {
                          // Show full details dialog
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(item['diseaseName']),
                              content: SingleChildScrollView(
                                child: colDetails(item),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Close"))
                              ],
                            )
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Widget colDetails(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item['imagePath'] != null && File(item['imagePath']).existsSync())
          Image.file(File(item['imagePath']), height: 200, width: double.infinity, fit: BoxFit.cover),
        SizedBox(height: 10),
        Text("Action Plan:", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(item['actionPlan'] ?? "No plan available."),
      ],
    );
  }
}

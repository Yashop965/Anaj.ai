import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../data/database_helper.dart';

class CommunityView extends StatefulWidget {
  @override
  _CommunityViewState createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  // Default to Gurugram, India (approximate center) if location fails
  LatLng _center = LatLng(28.4595, 77.0266); 
  bool _loading = true;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check Service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _loadMapData(); // Fallback to default
      return;
    }

    // 2. Check Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _loadMapData();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _loadMapData();
      return;
    }

    // 3. Get Location
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _loadMapData(); // Load data centered around user
      });
    } catch (e) {
      print("Location Error: $e");
      _loadMapData();
    }
  }

  Future<void> _loadMapData() async {
    // 1. Load User's Previous Scans from DB
    final diagnoses = await DatabaseHelper().getAllDiagnoses();
    
    List<Marker> tempMarkers = [];
    
    // Add User Current Location
    tempMarkers.add(
      Marker(
        point: _center,
        width: 80,
        height: 80,
        child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
      ),
    );

    // 2. Add Database Markers (Your Activity)
    for (var record in diagnoses) {
      if (record['latitude'] != null && record['longitude'] != null) {
          bool isHealthy = record['label'].toString().contains("Healthy");
          tempMarkers.add(
            Marker(
              point: LatLng(record['latitude'], record['longitude']),
              width: 80,
              height: 80,
              child: _buildDiseaseMarker(
                record['diseaseName'] ?? 'Unknown', 
                isHealthy ? Colors.green : Colors.red
              ),
            ),
          );
      }
    }

    // 3. Add Some Fake Community Data (Mock Neighbors)
    if (tempMarkers.length < 5) {
       tempMarkers.add(
        Marker(
          point: LatLng(_center.latitude + 0.005, _center.longitude + 0.005),
          width: 80,
          height: 80,
          child: _buildDiseaseMarker("Wheat Rust (Neighbor)", Colors.amber),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = tempMarkers;
        _loading = false;
      });
    }
  }

  Widget _buildDiseaseMarker(String label, Color color) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(label),
            content: Text("Reported by local farmer 2 hours ago."),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Close"))],
          ),
        );
      },
      child: Column(
        children: [
          Icon(Icons.location_on, color: color, size: 30),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Community Spread (आसपास के रोग)"),
        backgroundColor: Colors.green[800],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.anaj.ai',
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
        onPressed: _determinePosition,
        child: Icon(Icons.my_location),
        backgroundColor: Colors.green[800],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

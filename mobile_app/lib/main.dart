import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'logic/ai_router.dart'; // Deprecated in favor of AIService
import 'ui/dashboard_view.dart';
import 'data/database_helper.dart';

// Background Task Entry Point
@pragma('vm:entry-point') 
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Native called background task: $task");
    
    if (task == "sync_data") {
      // Retrieve pending syncs from DB and upload
      final dbHelper = DatabaseHelper();
      final pendingRaw = await dbHelper.getPendingSyncs();
      
      if (pendingRaw.isNotEmpty) {
        print("Found ${pendingRaw.length} pending items to sync.");
        // Logic to upload pending items to Boss Model would go here
      }
    }
    
    // Notification Trigger (Simulated for Crop Health Check)
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('crop_health_channel', 'Crop Health',
            channelDescription: 'Reminders to check crop health',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Digital Doctor', 'Time to scan your crops for a better health score!', platformChannelSpecifics,
        payload: 'item x');

    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Workmanager
  Workmanager().initialize(
    callbackDispatcher, 
    isInDebugMode: true 
  );
  
  // Register Periodic Task
  Workmanager().registerPeriodicTask(
    "1", 
    "sync_data", 
    frequency: Duration(minutes: 15),
    initialDelay: Duration(seconds: 10),
    constraints: Constraints(
      networkType: NetworkType.connected,
    )
  );

  runApp(DigitalDoctorApp());
}

class DigitalDoctorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anaj.ai',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto', // Or any legible font
      ),
      home: DashboardView(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIRouter _aiRouter = AIRouter();
  String _status = "Ready to Scan";
  
  @override
  void initState() {
    super.initState();
    _aiRouter.loadModel();
  }

  void _simulateScan() async {
    setState(() {
      _status = "Scanning...";
    });
    
    // Simulate an image path
    String mockImagePath = "/storage/emulated/0/DCIM/Camera/leaf_test.jpg";
    
    var result = await _aiRouter.processImage(mockImagePath);
    
    setState(() {
      _status = "Result: ${result['label']} (Conf: ${result['confidence']})";
      if (result.containsKey('message')) {
         _status += "\n${result['message']}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Doctor Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Health Score: 85%', // Placeholder
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.grey[200],
              child: Text(
                _status,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: Colors.green[700], 
              ),
              onPressed: _simulateScan,
              child: Text('SCAN CROP', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
             SizedBox(height: 20),
             ElevatedButton(
              onPressed: () {
                 // Open History or Reports
              },
              child: Text('View Reports'),
            ),
          ],
        ),
      ),
    );
  }
}

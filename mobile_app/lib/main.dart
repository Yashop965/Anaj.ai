import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
        0, 'Anaj.ai', 'Time to scan your crops for a better health score!', platformChannelSpecifics,
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
        fontFamily: 'Roboto', 
      ),
      home: DashboardView(), // Uses the new UI
    );
  }
}

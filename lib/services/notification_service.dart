// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   // Initialize notifications
//   Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('app_icon');
//
//     final InitializationSettings initializationSettings =
//     const InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       // Handle incoming messages
//       // You can show the targets or trigger other actions here
//     });
//   }
// }

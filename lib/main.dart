import 'package:cct001/src/helpers/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; 
import 'package:provider/provider.dart';
import 'src/myapp.dart';
import 'src/mynotifier.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
//  -------------------------------------    Main (Property of Nirvasoft.com) Rebased
void main() async { 
  // Native Splash
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized(); 
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); 
  //​ Preloading 
  final settingsController = SettingsController(SettingsService()); 
  await settingsController.loadSettings();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  logger.e('User granted permission: ${settings.authorizationStatus}'); 
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    logger.e('Got a message whilst in the foreground!');
    logger.e('Message data: ${message.data}');

    if (message.notification != null) {
      logger.e('Message also contained a notification: ${message.notification}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Run App
  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyNotifier()) // Provider
      ],
      child:  MyApp(settingsController: settingsController))
  );
  FlutterNativeSplash.remove(); // Native Splash
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  logger.e("Handling a background message: ${message.messageId}");
}
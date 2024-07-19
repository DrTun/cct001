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
  // Run App
  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyNotifier()) // Provider
      ],
      child:  MyApp(settingsController: settingsController))
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  logger.e("FCMToken $fcmToken");


  FlutterNativeSplash.remove(); // Native Splash


}


import 'package:cct001/appconfig.dart';
import 'package:cct001/src/helpers/env.dart';
import 'package:cct001/src/helpers/helpers.dart';
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
    AppConfig.create(
    appName: "CCT 001",
    appDesc: "Production CCT1",
    appID: "com.nirvasoft.cct001.dev",
    primaryColor: Colors.yellow,
    flavor: Flavor.prod,
  );
  
  final settingsController = SettingsController(SettingsService()); 
  await settingsController.loadSettings();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform, );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
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
    logger.e('Foreground data: ${message.data}');
    if (message.data.isNotEmpty) { 
      String c1 = message.data['c1'];
      MyHelpers.msg("Foreground (c1) > $c1"); 
    }
  }); 

  // Run App
  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyNotifier()) // Provider
      ],
      child:  MyApp(settingsController: settingsController))
  );


  FlutterNativeSplash.remove(); // Native Splash

  //Get token # for testing. 
  final fcmToken = await FirebaseMessaging.instance.getToken();
  MyHelpers.msg("FCM Token  $fcmToken");
  logger.e("FCM Token $fcmToken");



} 

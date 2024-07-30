import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; 
import 'package:provider/provider.dart';
import 'dart:ui';

import 'firebase_options.dart';
import 'appconfig.dart';
import 'src/myapp.dart';
import 'src/mynotifier.dart'; 
import 'src/helpers/helpers.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
//  Version 1.0.2
//  -------------------------------------    Main (Property of Nirvasoft.com) 
void main() async {  
  // (A) Native Splash
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized(); 
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); 

  //​ Preloading  
  // 1) Settings  
  final settingsController = SettingsController(SettingsService()); 
  await settingsController.loadSettings(); 
  // 2) Retrieve App Config from Dart Define 
  setAppConfig();
  // 3) Retrieve Secret Key from Dart Define and overwrite Secret Key
  
  // 4) Firebase - Anaytics, Crashlytics
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform, );
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  // 4) Firebase - Messging FCM
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform, );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission( alert: true, announcement: false,  badge: true, carPlay: false,criticalAlert: false,  provisional: false,  sound: true,);
  logger.i('User granted permission: ${settings.authorizationStatus}');
  // 4.2) Message Handlers - foregournd and background
  FirebaseMessaging.onMessage.listen((RemoteMessage message) { 
    if (message.notification?.title!=null && message.notification?.body!=null) { 
      var t = message.notification!.title ;
      var b = message.notification!.body ;
      MyHelpers.msg("Foreground Msg: $t $b"); 
    }
  }); 
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // (B) Run App 
  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyNotifier()) // Provider
      ],
      child:  MyApp(settingsController: settingsController))
  );
  // (C) All done - Remove Native Splash
  FlutterNativeSplash.remove(); // Native Splash
  // (D) Background stuff if any
  // 1) Get token # for testing. 
  if (AppConfig.shared.fcm) {
    FirebaseMessaging.instance.getToken().then((value) =>   showToken(value));
  }
  
} 

// --------------------------------------------------- END of main() ------------------
void showToken(token){
  MyHelpers.showIt(token,label: "FCM Token");   
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
    if (message.notification?.title!=null && message.notification?.body!=null) { 
      var t = message.notification!.title ;
      var b = message.notification!.body ;
      MyHelpers.msg("BG Msg: $t $b"); 
      logger.i("BG Msg: $t $b");
    }
}


void setAppConfig() async{  
  String envFlv = const String.fromEnvironment('FLV', defaultValue: 'dev');
  if (envFlv == 'prd') {
    AppConfig.create(
      appName: "CCT 001", // PRD 
      appID: "com.nirvasoft.cct001",
      primaryColor: Colors.orange, 
      flavor: Flavor.prod, 
      appDesc: const String.fromEnvironment('APP_TITLE',defaultValue: "CCT001"),
      clientID: const String.fromEnvironment('CLIENT_ID', defaultValue:"123"),
      baseURL: const String.fromEnvironment('BASE_URL',defaultValue: "www.base.com"),
      authURL: const String.fromEnvironment('AUTH_URL',defaultValue: "www.auth.com"),
      secretKey: const String.fromEnvironment('KEY1', defaultValue: "empty"),
      log: int.parse(const String.fromEnvironment('LOG', defaultValue: "1")),
      fcm:  const bool.fromEnvironment('FCM', defaultValue: false),
    );
  } else if (envFlv == 'staging'){
    AppConfig.create(
      appName: "CCT1 UAT", 
      appID: "com.nirvasoft.cct001.staging",
      primaryColor: Colors.green, 
      flavor: Flavor.staging,
      appDesc: const String.fromEnvironment('APP_TITLE',defaultValue: "CCT001"),
      clientID: const String.fromEnvironment('CLIENT_ID', defaultValue:"123"),
      baseURL: const String.fromEnvironment('BASE_URL',defaultValue: "www.base.com"),
      authURL: const String.fromEnvironment('AUTH_URL',defaultValue: "www.auth.com"),
      secretKey: const String.fromEnvironment('KEY1', defaultValue: "empty"),
      log: int.parse(const String.fromEnvironment('LOG', defaultValue: "1")),
      fcm:  const bool.fromEnvironment('FCM', defaultValue: false),
    );
  }  else if (envFlv == 'sit'){
    AppConfig.create(
      appName: "CCT1 SIT", 
      appID: "com.nirvasoft.cct001.sit",
      primaryColor: Colors.purple, 
      flavor: Flavor.sit,
      appDesc: const String.fromEnvironment('APP_TITLE',defaultValue: "CCT001"),
      clientID: const String.fromEnvironment('CLIENT_ID', defaultValue:"123"),
      baseURL: const String.fromEnvironment('BASE_URL',defaultValue: "www.base.com"),
      authURL: const String.fromEnvironment('AUTH_URL',defaultValue: "www.auth.com"),
      secretKey: const String.fromEnvironment('KEY1', defaultValue: "empty"),
      log: int.parse(const String.fromEnvironment('LOG', defaultValue: "1")),
      fcm:  const bool.fromEnvironment('FCM', defaultValue: false),
    );
  }  else {

    AppConfig.create(
      appName: "CCT1 DEV*", 
      appID: "com.nirvasoft.cct001.dev",
      primaryColor: Colors.blue, 
      flavor: Flavor.dev,
      appDesc: const String.fromEnvironment('APP_TITLE',defaultValue: "CCT001"),
      clientID: const String.fromEnvironment('CLIENT_ID', defaultValue:"123"),
      baseURL: const String.fromEnvironment('BASE_URL',defaultValue: "www.base.com"),
      authURL: const String.fromEnvironment('AUTH_URL',defaultValue: "www.auth.com"),
      secretKey: const String.fromEnvironment('KEY1', defaultValue: "empty"),
      log: int.parse(const String.fromEnvironment('LOG', defaultValue: "3")),
      fcm:  const bool.fromEnvironment('FCM', defaultValue: false),
    );
  }
}


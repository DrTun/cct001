
import 'myapp.dart';
import 'firebase_options.dart';
import 'src/geolocation/locationnotifier.dart';
import 'src/shared/appconfig.dart';
import 'src/providers/mynotifier.dart'; 
import 'src/helpers/helpers.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
//  Version 1.0.2
//  -------------------------------------    Main (Property of Nirvasoft.com) 
void main() async {   
  // (A) Native Splash Screen if needed
  WidgetsBinding widgetsBinding =  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //​ (B) Preloading  
  // 1) Settings  
  final settingsController = SettingsController(SettingsService()); 
  await settingsController.loadSettings(); 
  // 2) Retrieve App Config from Dart Define 
  setAppConfig();
  // 3) Firebase - Anaytics, Crashlytics
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform, );
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  FlutterError.onError = (errorDetails) {FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);};
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  // 4.1) Firebase - Messging FCM
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
      MyHelpers.msg(message: "Foreground Msg: $t $b"); 
    }
  }); 
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // (C) Run App 
  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyNotifier()), // Provider
        ChangeNotifierProvider(create: (context) => LocationNotifier()) // for GeoData
      ],
      child:  MyApp(settingsController: settingsController))
  );
  // (D) Background stuff if any
  // 1) Get token # for testing. 
  if (AppConfig.shared.fcm) {
    FirebaseMessaging.instance.getToken().then((value) =>   showToken(value));
  }  
  // (E) Remove Splash Screen
  FlutterNativeSplash.remove();
} 

// --------------------------------------------------- END of main() ------------------
void showToken(token){
  logger.i(token);   
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
    if (message.notification?.title!=null && message.notification?.body!=null) { 
      var t = message.notification!.title ;
      var b = message.notification!.body ;
      MyHelpers.msg(message: "BG Msg: $t $b"); 
      logger.i("BG Msg: $t $b");
    }
}
void setAppConfig() async{ 
  var id="",color=Colors.orange,flv=Flavor.dev; 
  String envFlv = const String.fromEnvironment('FLV', defaultValue: 'dev');
  if (envFlv == 'prd') { 
      id = "com.nirvasoft.cct001";
      color= Colors.orange;
      flv = Flavor.prod;
  } else if (envFlv == 'staging'){
      id = "com.nirvasoft.cct001.staging";
      color= Colors.green;
      flv = Flavor.prod;
  }  else if (envFlv == 'sit'){
      id = "com.nirvasoft.cct001.sit";
      color= Colors.green;
      flv = Flavor.prod;
  }  else {
      id ="com.nirvasoft.cct001.dev";
      color = Colors.blue;
      flv= Flavor.dev;
  }
    AppConfig.create(
      appID: id,
      primaryColor: color, 
      flavor: flv,
      appName: const String.fromEnvironment('APP_NAME',defaultValue: "CCT001"),
      appDesc: const String.fromEnvironment('APP_DESC',defaultValue: "CCT001"),
      clientID: const String.fromEnvironment('CLIENT_ID', defaultValue:"123"),
      baseURL: const String.fromEnvironment('BASE_URL',defaultValue: "www.base.com"),
      authURL: const String.fromEnvironment('AUTH_URL',defaultValue: "www.auth.com"),
      secretKey: const String.fromEnvironment('KEY1', defaultValue: "empty"),
      log: int.parse(const String.fromEnvironment('LOG', defaultValue: "1")),
      fcm:  const bool.fromEnvironment('FCM', defaultValue: false),
    );
}


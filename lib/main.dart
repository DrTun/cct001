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
import 'src/helpers/env.dart';
import 'src/helpers/helpers.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
//  -------------------------------------    Main (Property of Nirvasoft.com) Rebased
void main() async { 
  // Native Splash
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized(); 
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); 
  //​ Preloading  
  //  Settings  
  final settingsController = SettingsController(SettingsService()); 
  await settingsController.loadSettings(); 
  //  Dart Define
  const envFlv = String.fromEnvironment('FLV', defaultValue: 'prd');
  setAppConfig( envFlv);
  const envAPIK = String.fromEnvironment('KEY1', defaultValue: 'empty');
  MyHelpers.msg(envAPIK, sec: 5, bcolor: Colors.blue);
  //   Firebase - Anaytics, Crashlytics
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform, );
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  //   Firebase - Messging FCM
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
  //  Get token # for testing. 
    FirebaseMessaging.instance.getToken().then((value) =>  MyHelpers.showIt(value,label: "FCM Token"));
  //  Message Handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) { 
    if (message.notification?.title!=null && message.notification?.body!=null) { 
      var t = message.notification!.title ;
      var b = message.notification!.body ;
      MyHelpers.msg("Foreground Msg: $t $b"); 
    }
  }); 
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
    if (message.notification?.title!=null && message.notification?.body!=null) { 
      var t = message.notification!.title ;
      var b = message.notification!.body ;
      MyHelpers.msg("BG Msg: $t $b"); 
      logger.e("BG Msg: $t $b");
    }
}
void setAppConfig(String env){ 
  if (env == 'prd') {
    AppConfig.create(
      appName: "CCT 001", // PRD
      appDesc: "Production CCT1",
      appID: "com.nirvasoft.cct001",
      primaryColor: Colors.orange, 
      flavor: Flavor.prod, 
    );
  } else if (env == 'dev'){
    AppConfig.create(
      appName: "CCT1 DEV",
      appDesc: "Development CCT1",
      appID: "com.nirvasoft.cct001.dev",
      primaryColor: Colors.blue, 
      flavor: Flavor.prod,
    );
  } else if (env == 'staging'){
    AppConfig.create(
      appName: "CCT1 UAT",
      appDesc: "UAT CCT1",
      appID: "com.nirvasoft.cct001.staging",
      primaryColor: Colors.green, 
      flavor: Flavor.prod,
    );
  }  else if (env == 'sit'){
    AppConfig.create(
      appName: "CCT1 SIT",
      appDesc: "System  CCT1",
      appID: "com.nirvasoft.cct001.sit",
      primaryColor: Colors.purple, 
      flavor: Flavor.prod,
    );
  }  else {
    AppConfig.create(
      appName: "CCT1 DEV*",
      appDesc: "Development CCT1*",
      appID: "com.nirvasoft.cct001.dev",
      primaryColor: Colors.blue, 
      flavor: Flavor.prod,
    );
  }
}


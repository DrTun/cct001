import 'package:shared_preferences/shared_preferences.dart';
import 'my_app.dart';
import 'firebase_options.dart';
import 'src/geolocation/location_notifier.dart';
import 'src/providers/localization.dart';
import 'src/shared/app_config.dart';
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
import 'dart:io'; // ZMT added
import 'src/xpass/utils/websocket.dart';

//  Version 1.0.2
//  -------------------------------------    Main (Property of Nirvasoft.com)
void main() async {
  // (A) Native Splash Screen if needed
  HttpOverrides.global = ApplicationHttpOverrides(); // ZMT Added
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //​ (B) Preloading
  // 1) Settings
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  // 2) Retrieve App Config from Dart Define
  setAppConfig();
  // 3) Firebase - Anaytics, Crashlytics
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  // 4.1) Firebase - Messging FCM
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  logger.i('User granted permission: ${settings.authorizationStatus}');
  // 4.2) Message Handlers - foregournd and background
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification?.title != null &&
        message.notification?.body != null) {
      var t = message.notification!.title;
      var b = message.notification!.body;
      MyHelpers.msg(message: "Foreground Msg: $t $b");
    }
  });
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // (C) Run App
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? lang = prefs.getString('lang');
  Locale initialLocale =
      lang != null && lang.isNotEmpty ? Locale(lang) : const Locale('en');
  // ChuckerFlutter.isDebugMode = true;
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => MyNotifier()), // Provider
    ChangeNotifierProvider(create: (context) => LocaleProvider(initialLocale)),

    ChangeNotifierProvider(
        create: (context) => LocationNotifier()) // for GeoData
  ], child: MyApp(settingsController: settingsController)));
  // (D) Background stuff if any
  // 1) Get token # for testing.
  if (AppConfig.shared.fcm) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (Platform.isIOS) {
      FirebaseMessaging.instance.getAPNSToken().then((value) {
        if (value == null) {
          return;
        }
      });
    }
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        showToken(token);
        String newFbToken = token;
        prefs.setString('fbtoken', newFbToken);
      }
    });
  }
  // (E) Remove Splash Screen
  FlutterNativeSplash.remove();
}

class ApplicationHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, __, ___) => true;
  }
} // ZMT Added

// --------------------------------------------------- END of main() ------------------
void showToken(token) {
  logger.i(token);
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification?.title != null &&
      message.notification?.body != null) {
    var t = message.notification!.title;
    var b = message.notification!.body;
    MyHelpers.msg(message: "BG Msg: $t $b");
    logger.i("BG Msg: $t $b");
  }
}

void setAppConfig() async {
  var id = "", color = Colors.orange, flv = Flavor.dev;
  String envFlv = const String.fromEnvironment('FLV', defaultValue: 'dev');
  if (envFlv == 'prd') {
    id = "com.nirvasoft.grx003";
    color = Colors.orange;
    flv = Flavor.prod;
  } else if (envFlv == 'staging') {
    id = "com.nirvasoft.grx001.staging";
    color = Colors.green;
    flv = Flavor.prod;
  } else if (envFlv == 'sit') {
    id = "com.nirvasoft.grx001.sit";
    color = Colors.green;
    flv = Flavor.prod;
  } else {
    id = "com.nirvasoft.grx001.dev";
    color = Colors.blue;
    flv = Flavor.dev;
  }
  AppConfig.create(
    appID: id,
    primaryColor: color,
    flavor: flv,
    appName: const String.fromEnvironment('APP_NAME', defaultValue: "CCT001"),
    appDesc: const String.fromEnvironment('APP_DESC', defaultValue: "CCT001"),
    appVersion: const String.fromEnvironment('APP_VER', defaultValue: "2.0.1"),
    clientID: const String.fromEnvironment('CLIENT_ID', defaultValue: "123"),
    openIDClientID:
        const String.fromEnvironment('OPEN_ID_CLIENT_ID', defaultValue: "123"),
    baseURL:
        const String.fromEnvironment('BASE_URL', defaultValue: "www.base.com"),
    baseURLDEV: const String.fromEnvironment('BASE_URL_DEV',
        defaultValue: "www.basedev.com"),
    authURL:
        const String.fromEnvironment('AUTH_URL', defaultValue: "www.auth.com"),
    openIDAuthURL: const String.fromEnvironment('OPEN_ID_AUTH_URL',
        defaultValue: "www.openid.com"),
    openIDBaseURL: const String.fromEnvironment('OPEN_ID_BASE_URL',
        defaultValue: "www.openid.com"),
    openIDSignUpURL: const String.fromEnvironment('OPEN_ID_SIGNUP_URL',
        defaultValue: 'www.openid.com'),
    webSocketUrl: const String.fromEnvironment("WEB_SOCKET_URL",
        defaultValue: 'ws.www.com'),
    googleApiKey:
        const String.fromEnvironment('GOOGLE_API_KEY', defaultValue: 'empty'),
    googlePlaceUrl:
        const String.fromEnvironment('GOOGLE_PLACE_URL', defaultValue: 'empty'),
    appUrlPlaystore: const String.fromEnvironment('APP_URL_PLAYSTORE',
        defaultValue: 'empty'),
    secretKey1: const String.fromEnvironment('KEY1', defaultValue: "empty"),
    secretKey3: const String.fromEnvironment('KEY3', defaultValue: "empty"),
    xpassBaseURL: const String.fromEnvironment("XPASS_BASE_URL",defaultValue: 'www.xpass.com'),
    xpassWebSocketURL: const String.fromEnvironment("XPASS_WEB_SOCKET_URL",defaultValue: 'ws.www.com'),
    log: int.parse(const String.fromEnvironment('LOG', defaultValue: "1")),
    fcm: const bool.fromEnvironment('FCM', defaultValue: false),
  );
  WebsocketService.activate();
}

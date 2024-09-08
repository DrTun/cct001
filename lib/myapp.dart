import 'src/signin/forgotpassword.dart';
import 'src/signin/signin.dart';
import 'src/signin/signup.dart'; 
import 'src/geolocation/mapview.dart'; 
import 'src/shared/appconfig.dart';
import 'src/views/viewdatadetails.dart';
import 'src/views/viewdatalist.dart';
import 'src/views/viewsampledetails.dart';
import 'src/views/viewsamplelist.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_view.dart'; 
import 'src/loadingpage.dart';
import 'src/signin/signinpage.dart';
import 'src/rootpage.dart'; 
import 'src/views/viewdata.dart';
import 'src/views/views.dart'; 

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//  -------------------------------------    My App (Property of Nirvasoft.com)
class MyApp extends StatelessWidget {
  const MyApp({  super.key,  required this.settingsController,});
  final SettingsController settingsController;  
  @override
  Widget build(BuildContext context) { 
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp( 
          restorationScopeId: 'app', 
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle, 
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
                    appBarTheme:  AppBarTheme( color: AppConfig.shared.primaryColor, centerTitle: true, titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    floatingActionButtonTheme:  FloatingActionButtonThemeData(backgroundColor: AppConfig.shared.primaryColor),
                    tabBarTheme:  TabBarTheme(labelColor: AppConfig.shared.primaryColor,unselectedLabelColor: Colors.grey,indicator:  BoxDecoration( border: Border( top: BorderSide( color: AppConfig.shared.primaryColor, width: 2.0, ),),),),
          ), 
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode, 
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,            // Route Settings 
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SignupPage.routeName: return const SignupPage();
                  case SignIn.routeName: return const SignIn();
                  case ForgotPassword.routeName: return const ForgotPassword();
                  case RootPage.routeName: return const RootPage(); 
                  case SettingsView.routeName: return SettingsView(controller: settingsController);
                  case ViewDetails.routeName:return  const ViewDetails();
                  case View001.routeName: return const View001();
                  case ViewList.routeName: return const ViewList();
                  case ViewData.routeName: return const ViewData();
                  case ViewDataList.routeName: return const ViewDataList();
                  case ViewDataDetails.routeName: return const ViewDataDetails();
                  case SigninPage.routeName:  return const SigninPage();
                  case MapView.routeName:  return  const MapView(); 
                  default:  return const LoadingPage();
                }
              },
            );
          },
        );
      },
    );
  }
}





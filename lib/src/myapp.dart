
import 'package:cct001/src/views/view_data_details.dart';
import 'package:cct001/src/views/view_data_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/view_sample_details.dart';
import 'views/view_sample_list.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart'; 
import 'loadingpage.dart';
import 'signinpage.dart';
import 'rootpage.dart'; 
import 'views/view_data.dart'; 
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
                    appBarTheme: const AppBarTheme( color: Colors.orange, centerTitle: true, titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.orange ),
                    tabBarTheme: const TabBarTheme(labelColor: Colors.deepOrangeAccent,unselectedLabelColor: Colors.grey,indicator: BoxDecoration( border: Border( top: BorderSide( color: Colors.deepOrangeAccent, width: 2.0, ),),),),
          ), 
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode, 
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,            // Route Settings 
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case RootPage.routeName: return const RootPage(); 
                  case SettingsView.routeName: return SettingsView(controller: settingsController);
                  case ViewDetails.routeName:return  const ViewDetails();
                  case ViewList.routeName: return const ViewList();
                  case ViewData.routeName: return const ViewData();
                  case ViewDataList.routeName: return const ViewDataList();
                  case ViewDataDetails.routeName: return const ViewDataDetails();
                  case SigninPage.routeName:  return const SigninPage();
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





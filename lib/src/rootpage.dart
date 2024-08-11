
import 'dart:async'; 
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';  
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:provider/provider.dart';  

import 'geolocation/geodata.dart';
import 'providers/mynotifier.dart';
import 'shared/appconfig.dart';
import 'maintabs/maincards.dart';
import 'geolocation/mapview001.dart';
import 'shared/globaldata.dart'; 
import 'helpers/helpers.dart';
import 'signin/signinpage.dart'; 
import 'views/views.dart';
import 'settings/settings_view.dart';
import 'api/api_auth.dart';
//  -------------------------------------    Root Page (Property of Nirvasoft.com)
class RootPage extends StatefulWidget {
  static const routeName = '/root';
  const RootPage({super.key});
  @override
  State<RootPage> createState() => _RootPageState();
}
class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  late MyNotifier provider ;  // Provider Declaration and init
  @override
  void initState() {          // Init
    super.initState(); 
    if (AppConfig.shared.log>=3) logger.i('Root initialized'); 
    provider = Provider.of<MyNotifier>(context,listen: false);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_){ 
      provider.updateData01(AppConfig.shared.appName, AppConfig.shared.appDesc);  // Provider update
    }); 
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { // Lifecycle
    super.didChangeAppLifecycleState(state);
    if (AppConfig.shared.log>=3) logger.e("LifeCycle State: $state");
    if (state == AppLifecycleState.paused) {
      logger.e("Background");
      bg();
    }else if (state == AppLifecycleState.inactive) { bg();
    }else if (state == AppLifecycleState.resumed) { 
      logger.e("Foreground");
      ApiAuthService.checkRefreshToken();
    }
  }

  Future<void> bg() async {
    if (GeoData.tripStarted) {
      await GeoData.location.enableBackgroundMode(enable: true);
    } else {
      await GeoData.location.enableBackgroundMode(enable: false);
    }
  }

  @override
  Widget build(BuildContext context) {  // Widget
    return  Consumer<MyNotifier>(
      builder: (BuildContext context, MyNotifier value, Widget? child) {
      return 
        Scaffold(
          appBar: AppBar(
            title: Text(provider.data01.name), // Consumer
            actions: [
              PopupMenuButton<String>(          
                icon: const Icon(Icons.more_vert),
                onSelected: (value) { 
                  if (value == 'Item 1') {provider.updateData01('PRF', 'Profile 1');  } // Provider Update
                  else if (value == 'Item 2') {  provider.updateData01('STN', 'Profile 2'); } // Provider Update
                  else if (value =="settings"){  Navigator.restorablePushNamed(context, SettingsView.routeName);   }
                  else if (value =="map"){  launchUrl(Uri.parse('https://openstreetmap.org'));   }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>( value: 'Item 1',  child: Text('Profile 1'),  ),
                  const PopupMenuItem<String>( value: 'Item 2',  child: Text('Profile 2'), ),
                  const PopupMenuItem<String>( value: 'settings',  child: Text('Settings'), ),
                  const PopupMenuItem<String>( value: 'map',  child: Text('Open Street Map'), ),
                ],
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(decoration: BoxDecoration(color: AppConfig.shared.primaryColor,),child: const Text('Menu', style: TextStyle(color: Colors.white,fontSize: 24,),),),
                ListTile( title:  const Text('Home',), onTap: () async {
                  MyHelpers.msg("You are home");
                  
                  },
                ),
                ListTile( title:  Text('${GlobalAccess.mode=="Guest"?"Sign In":"Sign Out"} ',),  onTap: () async { _gotoSignIn(context); },),
              ],
            ),
          ),
          body: const DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      MainCards(),
                      MapView001(),
                      ViewBlank(),
                      ViewApps(),
                    ],
                  ),
                ),
                TabBar(
                  tabs: [
                    Tab( text: 'Home', icon: Icon(Icons.home), ),
                    Tab( text: 'Map', icon: Icon(Icons.map), ),
                    Tab( text: 'Trips', icon: Icon(Icons.add_location_alt_outlined),  ),
                    Tab( text: 'Apps', icon: Icon(Icons.apps), ),
                  ],
                ), 
              ],
            ),
          ),
        );
      }
    ); 
  }
  Future<void> _gotoSignIn(BuildContext context) async {
    if (GlobalAccess.mode != "Guest") { // if Users, need to confirm before signing out
      if (await confirm(context,title: const Text('Sign out'),content: Text('Would you like to sign out ${GlobalAccess.userName}?'),
        textOK: const Text('Yes'),textCancel: const Text('No'),)) {
        GlobalAccess.reset();               // reset global data
        await GlobalAccess.resetSecToken(); // reset secure storage with global data
        provider.updateData01("", "");    // clear provider on screen
        setState(() {  Navigator.pushNamed(context,SigninPage.routeName, );});
      }
    } else { // if guest, quickly go to sigin in
        GlobalAccess.reset();               // reset global data
        await GlobalAccess.resetSecToken(); // reset secure storage with global data
        provider.updateData01("", "");    // clear provider on screen
        setState(() {  Navigator.pushNamed(context,SigninPage.routeName, );});
    }
  }
} 

import 'package:flutter/material.dart';  
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:provider/provider.dart'; 
import 'helpers/env.dart';
import 'mynotifier.dart';
import 'globaldata.dart'; 
import 'helpers/helpers.dart';
import 'signinpage.dart';
import 'views/views.dart';
import 'views/view_sample_list.dart';
import 'views/view_data.dart';
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
    if (GlobalData.log>=3) logger.i('Root initialized'); 
    provider = Provider.of<MyNotifier>(context,listen: false);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_){ 
      provider.updateData01("CCT 1", "Clean Code Template 1");  // Provider update
    }); 
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { // Lifecycle
    super.didChangeAppLifecycleState(state);
    if (GlobalData.log>=3) logger.e("LifeCycle State: $state");
    if (state == AppLifecycleState.paused) {logger.e("Background");} 
    else if (state == AppLifecycleState.resumed) { 
      logger.e("Foreground");
      ApiAuthService.checkRefreshToken();
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
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>( value: 'Item 1',  child: Text('Profile 1'),  ),
                  const PopupMenuItem<String>( value: 'Item 2',  child: Text('Profile 2'), ),
                  const PopupMenuItem<String>( value: 'settings',  child: Text('Settings'), ),
                ],
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(decoration: BoxDecoration(color: Colors.orange,),child: Text('Menu', style: TextStyle(color: Colors.white,fontSize: 24,),),),
                ListTile( title:  const Text('Home',), onTap: () async {MyHelpers.msg("You are home");},    ),
                ListTile( title:  Text('${GlobalAccess.mode=="Guest"?"Sign In":"Sign Out"} ',),  onTap: () async { _gotoSignIn(context); },),
              ],
            ),
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1 content 
                      Column( children: [ 
                        Align(alignment: Alignment.centerRight, child:  Text('${GlobalAccess.userName!=""?"Welcome ${GlobalAccess.userName} (${GlobalAccess.userID})":""} ',
                          style: const TextStyle(color: Colors.black)),),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      ], ),
                      // Tab 2 content
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16), // Add padding left and right
                        child: Form001()), 
                      // Tab 3 content
                        Column( children: [ 
                          const SizedBox(height: 10),
                          const Text('Samples Applications', style: TextStyle(fontSize: 20),),
                          const SizedBox(height: 10), 
                          TextButton( onPressed: () { Navigator.pushNamed(context,ViewList.routeName, ); }, child: const Text('Form List', 
                            style: TextStyle(decoration: TextDecoration.underline)),),
                          TextButton( onPressed: () { Navigator.pushNamed(context,ViewData.routeName, ); }, child: const Text('SQFlite', 
                            style: TextStyle(decoration: TextDecoration.underline)),),
                      ]
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab( text: 'Home', icon: Icon(Icons.home), ),
                    Tab( text: 'Forms', icon: Icon(Icons.ac_unit_outlined),  ),
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
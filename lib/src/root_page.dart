import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'api/oidc_auth_service.dart';
import 'geolocation/map_view_001.dart';
import 'package:flutter/material.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:provider/provider.dart';
import 'geolocation/geo_data.dart';
import 'geolocation/map_view_002google.dart';
import 'maintabs/trip_list.dart';
import 'modules/flaxi/api/api_data_service_flaxi.dart';
import 'modules/flaxi/api_data_models/driver_version_update.dart';
import 'providers/mynotifier.dart';
import 'settings/settings_controller.dart';
import 'shared/app_config.dart';
import 'maintabs/main_cards.dart';
import 'shared/global_data.dart';
import 'helpers/helpers.dart';
import 'settings/settings_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'views/view_dashboard_page.dart';
import 'views/view_driver_group_list.dart';
import 'views/view_logs.dart';
import 'views/view_profile.dart';
import 'views/view_transactions.dart';

//  -------------------------------------    Root Page (Property of Nirvasoft.com)
class RootPage extends StatefulWidget {
  static const routeName = '/root';
  final SettingsController settingsController;
  const RootPage({
    super.key,
    required this.settingsController,
  });
  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {

  late VersionUpdateResponse versionData = 
    VersionUpdateResponse(status: 0, message: '', type: 3,newVersion: '');
  late MyNotifier provider; // Provider Declaration and init
  // final AuthService _authService = AuthService();
  bool versionType = false;
  final WebViewCookieManager cookieManager = WebViewCookieManager();
  final OidcAuthService oidcAuthService = OidcAuthService();
  File? _profileImage;
  String updatename = MyStore.prefs.getString('username') ?? '';
  @override
  void initState() {
    // Init
    super.initState();
    if (AppConfig.shared.log >= 3) logger.i('Root initialized');
    provider = Provider.of<MyNotifier>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.updateData01(
          AppConfig.shared.appName, AppConfig.shared.appDesc, false);
      // provider.updateTripData("","", GeoData.currentTrip.started, 0, 0); // Provider update
    });
    loadData();
    versionUpdate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Lifecycle
    super.didChangeAppLifecycleState(state);
    if (AppConfig.shared.log >= 3) logger.e("LifeCycle State: $state");
    if (state == AppLifecycleState.paused) {
      logger.e("Background");
      bg();
    } else if (state == AppLifecycleState.inactive) {
      bg();
    } else if (state == AppLifecycleState.resumed) {  
      if(versionData.type == 1){
        versionUpdate();
      }
      logger.e("Foreground");
      /** closed for now because it clean global data **/
      //ApiAuthService.checkRefreshToken();
      /** closed for now because it clean global data **/
    }
  }

  Future<void> bg() async {
    if (GeoData.currentTrip.started) {
      await GeoData.location.enableBackgroundMode(enable: true);
    } else {
      await GeoData.location.enableBackgroundMode(enable: false);
    }
  }

  Future<void> loadData() async {
    String? image = await MyStore.prefs.getString('profileImage');
    if (image != null) {
      setState(() {
        _profileImage = File(image);
      });
      
    }
  }

    versionUpdate() async{
    final versionNo = AppConfig.shared.appVersion;
    const platform   = 1 ;
    final response = await ApiDataServiceFlaxi().driverAppversionUpdate( VersionUpdateReq(versionNo: versionNo, platform: platform));
    if(response.status == 200) {
      versionData = response;
    } 
    if(versionData.type !=3){updateBox(versionData.type);}  
    
  }

    updateBox(type){    
    return showDialog(
        context: context, 
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) {
          final height = MediaQuery.of(context).size.height;
          return Dialog(
            shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: PopScope(
              canPop: versionType,
              child:   SizedBox(
                  height: height*0.35,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 0,left: 8,right: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              child:  ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: const Image( 
                                  fit: BoxFit.fill,
                                  image: AssetImage("assets/images/logo.png"),
                                ),
                              ),
                            ),
                            SizedBox(height: height*0.01,),
                            Text('GRX Fleet',style: TextStyle(color: AppConfig.shared.primaryColor,fontSize: 20,fontWeight: FontWeight.w500),),
                            Text('current version: ${AppConfig.shared.appVersion}',style: const TextStyle(color: Colors.grey)),
                            Row(
                              mainAxisAlignment : MainAxisAlignment.center,
                              children: [
                                const Text('Discover new version  ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,)),
                                Text('V${versionData.newVersion}',style: TextStyle(fontSize: 18,color: AppConfig.shared.primaryColor,fontWeight: FontWeight.w500)),
                              ],
                            ),
                            SizedBox(height: height*0.01,),
                            Text(versionData.message,style: const TextStyle(fontSize: 16,),textAlign: TextAlign.center,),
                          ],
                        ),
                        
                        Row(
                          mainAxisAlignment:type==2 ? MainAxisAlignment.spaceEvenly:MainAxisAlignment.end,
                          children: [
                            type==2 ?  TextButton(onPressed: (){  Navigator.pop(context);}, child: const Text('Cancel',style: TextStyle(color:  Colors.grey,fontSize: 16,fontWeight: FontWeight.w500),)) : const SizedBox(),
                            TextButton(onPressed: (){_openPlayStore();Navigator.pop(context);}, child: Text('Update',style: TextStyle(color: AppConfig.shared.primaryColor,fontWeight: FontWeight.w500,fontSize: 16),) ),
                          ]          
                        ),                      
                      ]
                    ),
                  ),
                )              
            ),
          );
        }
      );
  }

  @override
  Widget build(BuildContext context) {
  //  Widget
    return Consumer<MyNotifier>(
        builder: (BuildContext context, MyNotifier value, Widget? child) {   
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Column(
              children: [
                const SizedBox(height: 12.0),
                Text(
                  AppConfig.shared.appName,
                  //style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 2.0),
                Text(
                  AppConfig.shared.appVersion,
                  style: const TextStyle(fontSize: 9.0, color: Colors.yellow),
                ),
              ],
            ),
          ),
          // Consumer
          actions: [
            IconButton(
              icon: const Icon(
                  Icons.brightness_medium), // Change the icon as needed
              onPressed: () {
                _showThemeDialog();
              },
            ),
            PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async{
                  if (value == "settings") {
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  } else if (value == "groups")  {
                    Navigator.restorablePushNamed(context, ViewDriverGroupList.routeName,);              
                  }
                },
                itemBuilder: (BuildContext context) =>
                    GlobalAccess.userID.isNotEmpty
                        ? <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'settings',
                              child: Text('Settings'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'groups',
                              child: Text('Groups'),
                            ),
                          ]
                        : <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'settings',
                              child: Text('Settings'),
                            ),
                          ]),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                currentAccountPictureSize: const Size.square(72),
                decoration: BoxDecoration(
                  color: AppConfig.shared.primaryColor,
                ),
                currentAccountPicture: InkWell(
                  onTap: () {
                   Navigator.pushNamed(context, ViewProfile.routeName);
                  },
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: value.profileImage != null
                          ? FileImage(value.profileImage!)
                          : _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                      child: 
                      
                    _profileImage == null && value.profileImage == null
                               ?   Text(
                                        updatename.isNotEmpty
                                            ? updatename[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 24),
                                      )
                              : null,
                          
                    ),
                  ]),
                ),
                accountName: SizedBox(
                  height: 25,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      updatename,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                  ),
                ),
                accountEmail: SizedBox(
                  height: 25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        GlobalAccess.userID,
                        style: const TextStyle(color: Colors.white,fontSize: 16),
                      ),
                      InkWell(
                        onTap: (){Navigator.pushNamed(context, ViewProfile.routeName);},
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8,left: 8,),
                          child: Container(
                            height: 25,
                            width: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withOpacity(0.7)
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [                                                                
                                Text(' Edit',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w600),),
                                Icon(Icons.mode_edit_sharp,size: 15,color: Colors.black54),
                              ],
                            )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.payment_outlined),
                title: const Text('Transaction'),
                onTap: () {
                  Navigator.pushNamed(context, ViewTransactions.routeName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('View Logs'),
                onTap: () {
                  Navigator.pushNamed(context, ViewLogs.routeName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: Text(
                  '${GlobalAccess.mode == "Guest" || GlobalAccess.mode.isEmpty ? "Sign In" : "Sign Out"} ',
                ),
                onTap: () async {
                  _gotoSignIn(context);
                },
              ),
              ListTile(
                onTap: () {
                  _openPlayStore();
                },
                title: Center(
                  child: Text(
                    'Version ${AppConfig.shared.appVersion}',
                  ),
                ),
              ),
            ],
          ),
        ),
        body: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  // disable swipe so that the map can be scrolled
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    GeoData.mapType == 1
                        ? const MapView001()
                        : const MapView002Google(),
                    const TripList(),
                    const ViewDashboard(),
                    const MainCards(),
                  ],
                ),
              ),
              TabBar(
                tabs: [
                  Tab(
                    text: AppLocalizations.of(context)!.home,
                    icon: const Icon(Icons.home),
                  ),
                  Tab(
                    text: AppLocalizations.of(context)!.trips,
                    icon: const Icon(Icons.add_location_alt_outlined),
                  ),
                  Tab(
                    text: AppLocalizations.of(context)!.dashboard,
                    icon: const Icon(Icons.equalizer_rounded),
                  ),
                  Tab(
                    text: AppLocalizations.of(context)!.apps,
                    icon: const Icon(Icons.apps),
                  ),
                ],
                labelStyle:
                    const TextStyle(fontSize: 12), // Modify the font size here
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _gotoSignIn(BuildContext context) async {
    if (GeoData.fromto) {
      if (GeoData.fromto) {
        GeoData.fromto = !GeoData.fromto;
      }
      MyStore.prefs.setBool("fromto", false);
      GeoData.fromtotrip.pointsfromto.clear();
    }
    if (GlobalAccess.mode != "Guest" && GlobalAccess.mode.isNotEmpty) {
      if (GeoData.currentTrip.started) {
        MyHelpers.msg(message: "PLease end trip to Sign Out.");
      } else {
        // if Users, need to confirm before signing out
        if (await confirm(
          context,
          title: const Text('Sign out'),
          content: Text('Would you like to sign out ${GlobalAccess.userName}?'),
          textOK: const Text('Yes'),
          textCancel: const Text('No'),
        )) {
          String idToken = '';
          if (AppConfig.shared.signinType == 3) {
            idToken = GlobalAccess.idToken ?? ''; //
          }

          GlobalAccess.reset(); // reset global data
          await GlobalAccess
              .resetSecToken(); // reset secure storage with global data
          provider.updateData01("", "", false); // clear provider on screen
          GeoData.clearTrip();
          GeoData.clearTripPrevious();
          await MyStore.prefs.remove('drivergroup');
          await MyStore.prefs.remove('vehicleNo');
          await MyStore.prefs.remove('vehicleName');
          setState(() {
            AppConfig.signIn(context);
          });
          // sign out from keycloak
          if (AppConfig.shared.signinType == 3) {
            final bool successSignOut = await _signOutKeycloak(idToken);
            if (!successSignOut) return;
          }
        }
      }
    } else {
      // if guest, quickly go to sigin in
      GlobalAccess.reset(); // reset global data
      await GlobalAccess
          .resetSecToken(); // reset secure storage with global data
      provider.updateData01("", "", false); // clear provider on screen
      GeoData.clearTrip();
      GeoData.clearTripPrevious();
      setState(() {
        AppConfig.signIn(context);
      });
    }
  }

  Future<bool> _signOutKeycloak(String idToken) async {
    final response = await oidcAuthService.signOutKeycloak(idToken);
    if (response['status'] == 200) {
      try {
        await cookieManager.clearCookies();
      } catch (e, stacktrace) {
        if (AppConfig.shared.log >= 1) {
          logger.e("Other Exceptions (Sign out)): $e\n$stacktrace");
        }
      }
      return true;
    } else {
      _handleSignOutError(response);
      return false;
    }
  }

  void _handleSignOutError(Map<String, dynamic> response) {
    String message = 'Other Exceptions (Sign out)';
    if (response['status'] == 400) {
      message = response['message'] ?? 'Invalid URL';
    } else if (response['status'] == 422) {
      message = response['message'] ?? 'ID token not found';
    }
    MyHelpers.msg(message: message, backgroundColor: Colors.black);
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: widget.settingsController.themeMode,
                onChanged: (ThemeMode? value) {
                  setState(() {
                    widget.settingsController.updateThemeMode(value!);
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: widget.settingsController.themeMode,
                onChanged: (ThemeMode? value) {
                  setState(() {
                    widget.settingsController.updateThemeMode(value!);
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: widget.settingsController.themeMode,
                onChanged: (ThemeMode? value) {
                  setState(() {
                    widget.settingsController.updateThemeMode(value!);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPlayStore() async {
    final Uri playStoreUrl = Uri.parse(AppConfig.shared.appUrlPlaystore);
    
    if (await canLaunchUrl(playStoreUrl)) {
      await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
    } else {
      logger.i("Could not launch $playStoreUrl");
    }
  }
}

//  -------------------------------------    Loading 
import 'dart:async'; 
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong2/latlong.dart'; 
import '/src/rootpage.dart';
import 'api/api_auth.dart';
import 'signin/signin.dart';
import 'package:location/location.dart';
import '/src/helpers/helpers.dart';
import '/src/geolocation/geodata.dart';
import 'package:provider/provider.dart';
import 'geolocation/locationnotifier.dart';
import 'shared/appconfig.dart';
import 'shared/globaldata.dart';
import 'package:flutter/material.dart';
//  -------------------------------------    Loading (Property of Nirvasoft.com)
class LoadingPage extends StatefulWidget {
  static const routeName = '/loading';
  const LoadingPage({super.key});
  @override
  State<LoadingPage> createState() => _LoadingState();
}
class _LoadingState extends State<LoadingPage> {

  // 1) Geo Declaration >>>>
  late LocationNotifier providerLocNoti ;  // Provider Declaration and init
  
  // 2) Init State
  @override
  void initState() {
    super.initState(); 
    initGeoData();    // 2.1) Geo Init Function
    loading(context); // 2.2) Loading Function
  }
  // 2.1) Geo Init Function
  Future<void> initGeoData() async {
    GeoData.currentLat = GeoData.defaultLat;
    GeoData.currentLng = GeoData.defaultLng;
    try {
      providerLocNoti = Provider.of<LocationNotifier>(context,listen: false);
      if (await GeoData.chkPermissions(GeoData.location)){
        await GeoData.location.changeSettings(accuracy: LocationAccuracy.high, interval: GeoData.interval, distanceFilter: GeoData.distance);
        GeoData.locationSubscription = GeoData.location.onLocationChanged.listen((LocationData  currentLocation) {changeLocations(currentLocation);});
        if (GeoData.listenChanges==false) GeoData.locationSubscription.pause();
      } else {   logger.i("Permission Denied");} 
    } catch (e) {
      logger.i("Exception (initGeoData): $e");
    }
  }
  // 2.1.1) GPS Listener Method
  void changeLocations(LocationData currentLocation){ //listen to location changes
    try {
        DateTime dt = DateTime.now();
        GeoData.updateLocation(currentLocation.latitude!, currentLocation.longitude!, dt);  
        providerLocNoti.notify();
        // No need. above method will notify the provider
        if (AppConfig.shared.log==3){logger.i("(${GeoData.counter}) ${currentLocation.latitude} x ${currentLocation.longitude}");}
    } catch (e) {
      logger.i("Exception (changeLocations): $e");
    }
  }
  // 2.1.2) Current Location Method

  // 2.2) Loading Function
  Future loading(BuildContext context) async { 
    // 2.2.1) Shared Preferences
    await MyStore.init();
    GeoData.tripStarted = MyStore.prefs.getBool('tripStarted') ?? false;
      List<LatLng>? pline;
      List<DateTime> dtlist=[];
      pline = (await MyStore.retrievePolyline("points01"));
      if (pline != null  ) { 
        GeoData.points01 = pline; 
        pline = (await MyStore.retrievePolyline("points01Fixed"));
        if (pline != null) { 
          GeoData.points01Fixed = pline; 
          dtlist = (await MyStore.retrieveDateTimeList("dtimeList01"));
          if (dtlist.isNotEmpty) { 
            GeoData.tripStartDtime =dtlist[0];
            GeoData.dtimeList01 = dtlist; 
            dtlist = (await MyStore.retrieveDateTimeList("dtimeList01Fixed"));
            if (dtlist.isNotEmpty) { 
              GeoData.dtimeList01Fixed = dtlist; 
 
              // end the trip if it is more than 3 minute, it will be ended.
              DateTime currenttime = DateTime.now();
              if (currenttime.difference(dtlist[dtlist.length-1])>const Duration(minutes: 3)){ 
                GeoData.endTrip();
              } 
              //

            }  else { GeoData.endTrip();}
          }   else { GeoData.endTrip();}
        } else { GeoData.endTrip();}
      } else { GeoData.endTrip();}
      

    // 2.2.2) Read Global Data from Secure Storage
    await GlobalAccess.readSecToken();
    if (GlobalAccess.accessToken.isNotEmpty){  // should not refresh if guest coming back. let sign in again
      await ApiAuthService.checkRefreshToken(); 
    }
    // 2.2.3 Decide where to go based on Global Data read from secure storage.
    Timer(const Duration(seconds: 2), () {
    setState(() {
        if (AppConfig.shared.skipSignin) { 
          Navigator.pushReplacementNamed(context,RootPage.routeName, ); 
        } else if( GlobalAccess.userID.isNotEmpty || GlobalAccess.accessToken.isNotEmpty){ 
          
          Navigator.pushReplacementNamed(context,RootPage.routeName, ); 
        } else { 
          Navigator.pushReplacementNamed(context, SignIn.routeName);
        //  Navigator.pushReplacementNamed(context,SigninPage.routeName, );  
        }
    }); 
    });
  } 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [ 
        SizedBox(height: MediaQuery.of(context).size.height * 0.3,), 

        ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
          child: const Image(
            image: AssetImage("assets/images/logo.png"),
            width: 150,
            height: 150,
          ),
        ),

        const SizedBox(height: 50,), 
        Text('Welcome ${AppConfig.shared.appName}', ),
        const SizedBox(height: 50,), 
        Center(child: SizedBox(
              height: 30,
              child: SpinKitWave(color: Colors.grey[400],type: SpinKitWaveType.start,size: 40.0,itemCount: 5,),
        ),),
        SizedBox(height: MediaQuery.of(context).size.height * 0.25,),
        Text('Version ${AppConfig.shared.appVersion}', ),
        ]
      ),
    );
  }
}


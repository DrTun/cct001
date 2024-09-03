//  -------------------------------------    Loading 
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:location/location.dart';
import '/src/helpers/helpers.dart';
import '/src/geolocation/geodata.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'api/api_auth.dart';
import 'geolocation/locationnotifier.dart';
import 'shared/appconfig.dart';
import 'shared/globaldata.dart';
import 'rootpage.dart'; 
import 'package:flutter/material.dart';
import 'signin/signinpage.dart'; 
//  -------------------------------------    Loading (Property of Nirvasoft.com)
class LoadingPage extends StatefulWidget {
  static const routeName = '/loading';
  const LoadingPage({super.key});
  @override
  State<LoadingPage> createState() => _LoadingState();
}
class _LoadingState extends State<LoadingPage> {

  // 1) Geo Declaration >>>>
  late LocationNotifier locationNotifierProvider ;  // Provider Declaration and init
  
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
      locationNotifierProvider = Provider.of<LocationNotifier>(context,listen: false);
      if (await GeoData.chkPermissions(GeoData.location)){
        await GeoData.location.changeSettings(accuracy: LocationAccuracy.high, interval: GeoData.interval, distanceFilter: GeoData.distance);
        GeoData.locationSubscription = GeoData.location.onLocationChanged.listen((LocationData currentLocation) {changeLocations(currentLocation);});
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
        GeoData.updateLocation(currentLocation.latitude!, currentLocation.longitude!, dt,locProvider: locationNotifierProvider);  
        locationNotifierProvider.updateLoc1(currentLocation.latitude!,  currentLocation.longitude!, dt);  
        if (GeoData.defaultMap==0 && GeoData.centerMap && GeoData.mapReady) {
          locationNotifierProvider.mapController.move(LatLng(GeoData.currentLat, GeoData.currentLng),GeoData.zoom);
        } else if (GeoData.defaultMap==1 && GeoData.centerMap && GeoData.gmapReady ) {
          locationNotifierProvider.gmapController.future.then((controller) {
            controller.moveCamera(gmap.CameraUpdate.newCameraPosition(gmap.CameraPosition(
            target: gmap.LatLng(GeoData.currentLat, GeoData.currentLng), zoom: GeoData.zoom,
          )));});
        }
        if (AppConfig.shared.log==3){logger.i("(${GeoData.counter}) ${currentLocation.latitude} x ${currentLocation.longitude}");}
    } catch (e) {
      logger.i("Exception (changeLocations): $e");
    }
  }
  // 2.1.2) Current Location Method
  void moveHere() async { // butten event
    try {
      var locationData = await GeoData.getCurrentLocation(GeoData.location,locProvider: locationNotifierProvider); 
      if (locationData != null) {
        locationNotifierProvider.updateLoc1(GeoData.currentLat, GeoData.currentLng, GeoData.currentDtime); 
        if (GeoData.mapReady) locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom); 
        MyHelpers.showIt("\n${locationNotifierProvider.loc01.lat}\n${locationNotifierProvider.loc01.lng}",label: "You are here",);
      } else { logger.i("Invalid Location!"); }    
    } catch (e) {
      logger.i("Exception (moveHere): $e");
    }
  }
  // 2.2) Loading Function
  Future loading(BuildContext context) async { 
    // 2.2.1) Shared Preferences
    await MyStore.init();
    GeoData.tripStarted = MyStore.prefs.getBool('tripStarted') ?? false;
      Polyline? pline;
      List<DateTime> dtlist=[];
      pline = (await MyStore.retrievePolyline("polyline01"));
      if (pline != null) { 
        GeoData.polyline01 = pline; 
        pline = (await MyStore.retrievePolyline("polyline01Fixed"));
        if (pline != null) { 
          GeoData.polyline01Fixed = pline; 
          dtlist = (await MyStore.retrieveDateTimeList("dtimeList01"));
          if (dtlist.isNotEmpty) { 
            GeoData.tripStartDtime =dtlist[0];
            GeoData.dtimeList01 = dtlist; 
            dtlist = (await MyStore.retrieveDateTimeList("dtimeList01Fixed"));
            if (dtlist.isNotEmpty) { 
              GeoData.dtimeList01Fixed = dtlist; 
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
        if (AppConfig.shared.skipsignin) { 
          Navigator.pushReplacementNamed(context,RootPage.routeName, ); 
        } else if( GlobalAccess.userID.isNotEmpty || GlobalAccess.accessToken.isNotEmpty){ 
          Navigator.pushReplacementNamed(context,RootPage.routeName, ); 
        } else { 
          Navigator.pushReplacementNamed(context,SigninPage.routeName, );  
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


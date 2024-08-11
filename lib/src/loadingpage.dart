//  -------------------------------------    Loading 
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';
import '/src/helpers/helpers.dart';
import '/src/geolocation/geodata.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'api/api_auth.dart';
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

  // (1 of 6) Geo Declaration >>>>
  //final Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;
  late LocationNotifier locationNotifierProvider ;  // Provider Declaration and init
  
  @override
  void initState() {
    super.initState(); 
    // (2 of 6) Geo Init
    //Shared.prefs.init();
    initGeoData();
    loading(context);
  }
  // (3 of 6) Geo Init Function
  Future<void> initGeoData() async {
    GeoData.currentLat = GeoData.defaultLat;
    GeoData.currentLng = GeoData.defaultLng;
    try {
      locationNotifierProvider = Provider.of<LocationNotifier>(context,listen: false);
      if (await GeoData.chkPermissions(GeoData.location)){
        await GeoData.location.changeSettings(accuracy: LocationAccuracy.high, interval: GeoData.interval, distanceFilter: GeoData.distance);
        locationSubscription = GeoData.location.onLocationChanged.listen((LocationData currentLocation) {changeLocations(currentLocation);});
        if (GeoData.listenChanges==false) locationSubscription.pause();
      } else {   logger.i("Permission Denied");} 
    } catch (e) {
      logger.i("Exception (initGeoData): $e");
    }
  }
  // (4 of 6) GPS Listener Method
  void changeLocations(LocationData currentLocation){ //listen to location changes
    try {
        DateTime dt = DateTime.now();
        GeoData.updateLocation(currentLocation.latitude!, currentLocation.longitude!, dt);  
          locationNotifierProvider.updateLoc1(currentLocation.latitude!,  currentLocation.longitude!, dt);  
        if (GeoData.centerMap && GeoData.mapready) {locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom);}
        if (AppConfig.shared.log==3){logger.i("(${GeoData.counter}) ${currentLocation.latitude} x ${currentLocation.longitude}");}

    } catch (e) {
      logger.i("Exception (changeLocations): $e");
    }
  }
  // (5 of 6) Current Location Method
  void moveHere() async { // butten event
    try {
      var locationData = await GeoData.getCurrentLocation(GeoData.location); 
      if (locationData != null) {
        locationNotifierProvider.updateLoc1(GeoData.currentLat, GeoData.currentLng, GeoData.currentDtime); 
        if (GeoData.mapready) locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom); 
        MyHelpers.showIt("\n${locationNotifierProvider.loc01.lat}\n${locationNotifierProvider.loc01.lng}",label: "You are here",);
      } else { logger.i("Invalid Location!"); }    
    } catch (e) {
      logger.i("Exception (moveHere): $e");
    }
  }
  Future loading(BuildContext context) async { 
    // Shared Preferences
    await MyStore.init();
    //if (MyStore.prefs.containsKey('tripStarted')){
      GeoData.tripStarted = MyStore.prefs.getBool('tripStarted') ?? false;
    //}
    // Read Global Data from Secure Storage
    await GlobalAccess.readSecToken();
    if (GlobalAccess.accessToken.isNotEmpty){  // should not refresh if guest coming back. let sign in again
      await ApiAuthService.checkRefreshToken(); 
    }
    // Decide where to go based on Global Data read from secure storage.
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


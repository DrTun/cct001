
import 'dart:async';
import 'package:flutter_map_math/flutter_geo_math.dart';
import '/src/geolocation/locationnotifier.dart';
import 'package:latlong2/latlong.dart';
import '/src/helpers/helpers.dart';
import 'package:location/location.dart'; 
//  -------------------------------------    GeoData (Property of Nirvasoft.com)
class GeoData{
  // Properties
  String tripId="";
  String source="";
  String destination=""; 
  double distance=0;
  double currentSpeed=0;
  int duration=0;
  double distanceAmount=0; 
  DateTime startTime=DateTime.now();
  bool started=false;
  DateTime endTime=DateTime.now();
  bool ended=false; 
  List<LatLng> points=[];  // Previous Trip
  List<DateTime> dtimeList=[]; 
  List<LatLng> pointsFixed=[];  // Previous Trip
  List<DateTime> dtimeListFixed=[];
  void clear(){
    points.clear();
    dtimeList.clear();
    pointsFixed.clear();
    dtimeListFixed.clear();
  }

  // GPS Data
  static int counter=0;   // debugging purpose
  List<LatLng> raws=[];  

  // Send to Server and local location updates
  static double currentLat=0; 
  static double currentLng=0; 
  static DateTime currentDtime= DateTime.now(); // time of the last update

  // Trip Data
  static GeoData currentTrip = GeoData();
  static GeoData previousTrip = GeoData();

  // Shared 
  static Location location =Location();
  static late StreamSubscription<LocationData> locationSubscription;
  static Timer? timer;

  // App Parameters 
  static bool showLatLng=false;
  static bool centerMap=true;
  static bool listenChanges=true;
  static bool useTimer=false;
  static double zoom=16;
  static int interval=1000;
  static double distanceFilter=0;
  static double minDistance=10;
  static double maxDistance=30;
  static double oriThickness=3;
  static double fixedThickness=6;
  static const double defaultLat=1.2926;
  static const double defaultLng=103.8448;
  static const int timerInterval=1000;
  static const int mintripDuration=60;  // to save the trip or not
  static int defaultMap=1;  //0 open street, 1 google map

 
  static void clearTrip(){
    currentTrip.points.clear();
    currentTrip.dtimeList.clear();
    currentTrip.pointsFixed.clear();
    currentTrip.dtimeListFixed.clear();
  }
  static void clearTripPrevious(){
    previousTrip.points.clear();
    previousTrip.dtimeList.clear();
    previousTrip.pointsFixed.clear();
    previousTrip.dtimeListFixed.clear();
    previousTrip.clear();
  }
  static void copyPreviousTrip(){
    previousTrip.points = List.from(currentTrip.points);
    previousTrip.dtimeList = List.from(currentTrip.dtimeList); 
    previousTrip.pointsFixed = List.from(currentTrip.pointsFixed);
    previousTrip.dtimeListFixed = List.from(currentTrip.dtimeListFixed); 
    previousTrip.distance = currentTrip.distance;
    previousTrip.duration = currentTrip.duration;
    previousTrip.distanceAmount = currentTrip.distanceAmount;
  }
  static double estimateSpeed(List<LatLng> points, List<DateTime> dt, int range){
    double speed=0;
    int range =10;
    double dist=0;
    int time= 0;
    FlutterMapMath fmm = FlutterMapMath();
    if (points.length>range && dt.length>range){
      time= dt[dt.length-1].difference(dt[dt.length-range]).inSeconds;
      for (int i=points.length-range; i<points.length-1; i++){
        dist+=fmm.distanceBetween(
              points[i].latitude,            //latest points
              points[i].longitude,
              points[i-1].latitude, 
              points[i-1].longitude,"meters").round();
      }
      speed=dist/time*60*60/1000;
    }
    return speed;
  }
  static int tripDurationOf(List<DateTime> dt){
    if (dt.isEmpty) return 0;
    Duration difference = dt[dt.length-1].difference(dt[0]);
    return (difference.inSeconds).round();
  } 

  static double totalDistance(List<LatLng> points){
    double dist=0;
    FlutterMapMath fmm = FlutterMapMath();
    for (int i=1; i<points.length-1; i++){
      dist+=fmm.distanceBetween(
            points[i].latitude,            //latest points
            points[i].longitude,
            points[i-1].latitude, 
            points[i-1].longitude,"meters").round();
    }
    return (dist/1000);
  }

  static void updateLocation(double lat, double lng, DateTime dt,{LocationNotifier? providerLocNoti}){
    if (lat!=0 && lng!=0){
        GeoData.counter++;
        GeoData.currentLat=lat;
        GeoData.currentLng=lng;
        GeoData.currentDtime=dt;
        if (currentTrip.started){
          currentTrip.points.add(LatLng(lat, lng));
          currentTrip.dtimeList.add(dt);
          // Geo Data Optimization
          FlutterMapMath fmm = FlutterMapMath();
          double dist=fmm.distanceBetween(
                currentTrip.points[currentTrip.points.length-1].latitude,            //latest points
                currentTrip.points[currentTrip.points.length-1].longitude,
                currentTrip.points[currentTrip.points.length-2].latitude, 
                currentTrip.points[currentTrip.points.length-2].longitude,"meters");
          int time= currentTrip.dtimeList[currentTrip.dtimeList.length-1].difference(currentTrip.dtimeList[currentTrip.dtimeList.length-2]).inSeconds;
          double speed=dist/time;
          //if (AppConfig.shared.log>=3) 
          logger.i("Speed: $speed  ($dist / $time)");

          currentTrip.pointsFixed.add(LatLng(lat, lng - 0.000003));
          currentTrip.dtimeListFixed.add(dt);
          // ---------(C or -3)-------(B or -2)--------(A or -1 of original or last point)
          if (currentTrip.pointsFixed.length>=3){  
            double dist2=fmm.distanceBetween(
                currentTrip.pointsFixed[currentTrip.pointsFixed.length-1].latitude,            //latest points
                currentTrip.pointsFixed[currentTrip.pointsFixed.length-1].longitude,
                currentTrip.pointsFixed[currentTrip.pointsFixed.length-2].latitude, 
                currentTrip.pointsFixed[currentTrip.pointsFixed.length-2].longitude,"meters");
            double dist1=fmm.distanceBetween(
                currentTrip.pointsFixed[currentTrip.pointsFixed.length-2].latitude, 
                currentTrip.pointsFixed[currentTrip.pointsFixed.length-2].longitude,
                currentTrip.pointsFixed[currentTrip.pointsFixed.length-3].latitude,
                currentTrip.pointsFixed[currentTrip.pointsFixed.length-3].longitude,"meters");
                
            if ((dist1<minDistance && dist2<minDistance) || 
                (dist1>maxDistance && dist2>maxDistance) ){
              currentTrip.pointsFixed.removeAt(currentTrip.pointsFixed.length-2); // Remove point B
              currentTrip.dtimeListFixed.removeAt(currentTrip.dtimeListFixed.length-2);
              //if (AppConfig.shared.log>=3) 
              logger.i("Remove: $dist1 $dist2 ");
                          
            } else {
              //if (AppConfig.shared.log>=3) 
              logger.i("Keep: $dist1 $dist2 ");       
            }
          }
        } else {
          
        }
          MyStore.storePolyline(currentTrip.points,"points01");
          MyStore.storeDateTimeList(currentTrip.dtimeList, "dtimeList01");
          MyStore.storePolyline(currentTrip.pointsFixed,"points01Fixed");
          MyStore.storeDateTimeList(currentTrip.dtimeListFixed, "dtimeList01Fixed");

          currentTrip.distance=totalDistance(currentTrip.pointsFixed);
          currentTrip.duration=tripDurationOf(currentTrip.dtimeListFixed);
          currentTrip.currentSpeed = estimateSpeed(currentTrip.pointsFixed, currentTrip.dtimeListFixed, 5);
          currentTrip.distanceAmount = calculateAmount(currentTrip.distance, currentTrip.duration);

          providerLocNoti?.notify(); // notify the provider there have been changes
    }
  }
  static double calculateAmount(double distance, int time){  // replace it with real calculation
    double ret=0;
    if (distance>0){ ret = 2500+(distance * 2500);
    } else { ret = 0; }
    return ret;  
  }

  static void startTrip(LocationNotifier locationNotifier){
    currentTrip.startTime= DateTime.now();
    if (!useTimer) startTimer(locationNotifier);
    clearTrip();
    clearTripPrevious();
    currentTrip.started=true;
  }
  static void startTimer(LocationNotifier locationNotifier){
    timer = Timer.periodic(const Duration(milliseconds: GeoData.timerInterval), (timer) {
      locationNotifier.notify();
    });
  }
  static int tripDuration(){
    int tm =0;
    if (GeoData.currentTrip.started){
      tm = DateTime.now().difference(currentTrip.startTime).inSeconds;
    } else {
      tm =tripDurationOf(previousTrip.dtimeListFixed);
    }
    return tm;
  }
  static void endTrip(){
    currentTrip.started=false;
    if (!useTimer) timer?.cancel(); 
    copyPreviousTrip();
    clearTrip();
  }
  static Future<bool> chkPermissions(Location location) async{
    bool serviceEnabled;
    PermissionStatus permissionGranted; 
    try { 
        serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
          if (serviceEnabled) {
            logger.i("Service Enabled");
          } else {
            logger.i("Service Disabled");
            return false;
          }
        }
        permissionGranted = await location.hasPermission();
        if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await location.requestPermission();
          if (permissionGranted == PermissionStatus.granted) {
            logger.i("Permission Granted");
          } else {
            logger.i("Permission Denined");
            return false;
          }
        }
    } catch (e) {
      logger.e("Permission Exception (getCurrentLocation)");
    return false;
    }
    return true;
  } 
  static Future<LocationData?> getCurrentLocation(Location location) async { 
      LocationData locationData;
      bool serviceEnabled=await chkPermissions(location);
      if (serviceEnabled) {
        locationData = await location.getLocation(); 
        GeoData.updateLocation(locationData.latitude!, locationData.longitude!, DateTime.now()); 
        return locationData;
      } else {
        return null;
      } 
  }
}

import 'dart:async';
import 'package:flutter_map_math/flutter_geo_math.dart';
import '/src/geolocation/locationnotifier.dart';
import 'package:latlong2/latlong.dart';
import '../helpers/helpers.dart';
import 'package:location/location.dart';

import 'tripdata.dart';
//  -------------------------------------    GeoData (Property of Nirvasoft.com)
class GeoData{
  // GPS Data
  static int counter=0;
  static double currentLat=0;
  static double currentLng=0; 
  static DateTime currentDtime= DateTime.now();
  static bool tripStarted=false;
  static DateTime tripStartDtime= DateTime.now();

  static List<LatLng> points01=[];
  static List<LatLng> points01Fixed=[];

  static List<DateTime> dtimeList01=[];
  static List<DateTime> dtimeList01Fixed=[];

  static TripData previousTrip = TripData();

  static double tripDistance=0;
  static int tripTime=0;
  static double tripSpeedNow =0;
  static double tripAmount = 0;

  static Location location =Location();
  static late StreamSubscription<LocationData> locationSubscription;
  static Timer? timer;
  static bool useTimer=false;

  // App Parameters 
  static bool showLatLng=false;
  static bool centerMap=true;
  static bool listenChanges=true;
  static double zoom=16;
  static int interval=1000;
  static double distance=0;
  static double minDistance=10;
  static double maxDistance=30;
  static double oriThickness=3;
  static double fixedThickness=6;
  static const double defaultLat=1.2926;
  static const double defaultLng=103.8448;
  static const int timerInterval=1000;
  static const int mintripDuration=60; // to save the trip or not
  static int defaultMap=0;  //0 open street, 1 google map

 
  static void clearTrip(){
    points01.clear();
    dtimeList01.clear();
    points01Fixed.clear();
    dtimeList01Fixed.clear();
  }
  static void clearTripPrevious(){
    previousTrip.points.clear();
    previousTrip.dtimeList.clear();
    previousTrip.pointsFixed.clear();
    previousTrip.dtimeListFixed.clear();
    previousTrip.clear();
  }
  static void copyPreviousTrip(){
    previousTrip.points = List.from(points01);
    previousTrip.dtimeList = List.from(dtimeList01); 
    previousTrip.pointsFixed = List.from(points01Fixed);
    previousTrip.dtimeListFixed = List.from(dtimeList01Fixed); 
  }
  static double currentSpeed(List<LatLng> points, List<DateTime> dt, int range){
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
  static int totalTime(List<DateTime> dt){
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
        if (tripStarted){
          points01.add(LatLng(lat, lng));
          dtimeList01.add(dt);
          // Geo Data Optimization
          FlutterMapMath fmm = FlutterMapMath();
          double dist=fmm.distanceBetween(
                points01[points01.length-1].latitude,            //latest points
                points01[points01.length-1].longitude,
                points01[points01.length-2].latitude, 
                points01[points01.length-2].longitude,"meters");
          int time= dtimeList01[dtimeList01.length-1].difference(dtimeList01[dtimeList01.length-2]).inSeconds;
          double speed=dist/time;
          //if (AppConfig.shared.log>=3) 
          logger.i("Speed: $speed  ($dist / $time)");

          points01Fixed.add(LatLng(lat, lng - 0.000003));
          dtimeList01Fixed.add(dt);
          // ---------(C or -3)-------(B or -2)--------(A or -1 of original or last point)
          if (points01Fixed.length>=3){  
            double dist2=fmm.distanceBetween(
                points01Fixed[points01Fixed.length-1].latitude,            //latest points
                points01Fixed[points01Fixed.length-1].longitude,
                points01Fixed[points01Fixed.length-2].latitude, 
                points01Fixed[points01Fixed.length-2].longitude,"meters");
            double dist1=fmm.distanceBetween(
                points01Fixed[points01Fixed.length-2].latitude, 
                points01Fixed[points01Fixed.length-2].longitude,
                points01Fixed[points01Fixed.length-3].latitude,
                points01Fixed[points01Fixed.length-3].longitude,"meters");
                
            if ((dist1<minDistance && dist2<minDistance) || 
                (dist1>maxDistance && dist2>maxDistance) ){
              points01Fixed.removeAt(points01Fixed.length-2); // Remove point B
              dtimeList01Fixed.removeAt(dtimeList01Fixed.length-2);
              //if (AppConfig.shared.log>=3) 
              logger.i("Remove: $dist1 $dist2 ");
                          
            } else {
              //if (AppConfig.shared.log>=3) 
              logger.i("Keep: $dist1 $dist2 ");       
            }
          }
        }
          MyStore.storePolyline(points01,"points01");
          MyStore.storeDateTimeList(dtimeList01, "dtimeList01");
          MyStore.storePolyline(points01Fixed,"points01Fixed");
          MyStore.storeDateTimeList(dtimeList01Fixed, "dtimeList01Fixed");

          tripDistance=totalDistance(points01Fixed);
          tripTime=totalTime(dtimeList01Fixed);
          tripSpeedNow = currentSpeed(points01Fixed, dtimeList01Fixed, 5);
          tripAmount = calculateAmount(tripDistance, tripTime);

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
    tripStartDtime= DateTime.now();
    if (!useTimer) startTimer(locationNotifier);
    clearTrip();
    clearTripPrevious();
    tripStarted=true;
  }
  static void startTimer(LocationNotifier locationNotifier){
    timer = Timer.periodic(const Duration(milliseconds: GeoData.timerInterval), (timer) {
      locationNotifier.notify();
    });
  }
  static int tripDuration(){
    int tm =0;
    if (GeoData.tripStarted){
      tm = DateTime.now().difference(tripStartDtime).inSeconds;
    } else {
      tm =totalTime(previousTrip.dtimeListFixed);
    }
    return tm;
  }
  static void endTrip(){
    tripStarted=false;
    if (!useTimer) timer?.cancel(); 
    copyPreviousTrip();
    //clearTripPrevious();
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
  static Future<LocationData?> getCurrentLocation(Location location, {LocationNotifier? locProvider}) async { 
      LocationData locationData;
      bool serviceEnabled=await chkPermissions(location);
      if (serviceEnabled) {
        locationData = await location.getLocation();
        if (locProvider==null){
        GeoData.updateLocation(locationData.latitude!, locationData.longitude!, DateTime.now());
         } else {
        GeoData.updateLocation(locationData.latitude!, locationData.longitude!, DateTime.now());
      }
        return locationData;
      } else {
        return null;
      } 
  }
}


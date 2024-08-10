import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:latlong2/latlong.dart';
import '../helpers/helpers.dart';
import 'package:location/location.dart';

import '../shared/appconfig.dart'; 
//  -------------------------------------    GeoData (Property of Nirvasoft.com)
class GeoData{
  // GPS Data
  static int counter=0;
  static double currentLat=0;
  static double currentLng=0; 
  static DateTime currentDtime= DateTime.now();
  static bool tripStarted=false;
  static Polyline polyline01 = Polyline(points: [], color: Colors.red,strokeWidth: origThickenss,);
  static List<DateTime> dtimeList01=[];
  static Polyline polyline01Fixed = Polyline(points: [], color: Colors.blue,strokeWidth: optiThickenss,);
  static List<DateTime> dtimeList01Fixed=[];
  static bool mapready=false;
  static Location location =Location();

  // App Parameters 
  static bool showLatLng=false;
  static bool centerMap=true;
  static bool listenChanges=true;
  static double zoom=16;
  static int interval=1000;
  static double distance=0;
  static double minDistance=10;
  static double maxDistance=30;
  static double origThickenss=3;
  static double optiThickenss=6;
  static const double defaultLat=1.2926;
  static const double defaultLng=103.8448;

  static void updateLocation(double lat, double lng, DateTime dt){
    if (lat!=0 && lng!=0){
        GeoData.counter++;
        GeoData.currentLat=lat;
        GeoData.currentLng=lng;
        GeoData.currentDtime=dt;
        if (tripStarted){
          polyline01.points.add(LatLng(lat, lng));
          dtimeList01.add(dt);
          // Geo Data Optimization
          FlutterMapMath fmm = FlutterMapMath();
          double dist=fmm.distanceBetween(
                polyline01.points[polyline01.points.length-1].latitude,            //latest points
                polyline01.points[polyline01.points.length-1].longitude,
                polyline01.points[polyline01.points.length-2].latitude, 
                polyline01.points[polyline01.points.length-2].longitude,"meters");
          int time= dtimeList01[dtimeList01.length-1].difference(dtimeList01[dtimeList01.length-2]).inSeconds;
          double speed=dist/time;
          if (AppConfig.shared.log>=3) logger.i("Speed: $speed  ($dist / $time)");

          polyline01Fixed.points.add(LatLng(lat, lng - 0.000003));
          dtimeList01Fixed.add(dt);
          // ---------(C or -3)-------(B or -2)--------(A or -1 of original or last point)
          if (polyline01Fixed.points.length>=3){  
            double dist2=fmm.distanceBetween(
                polyline01Fixed.points[polyline01Fixed.points.length-1].latitude,            //latest points
                polyline01Fixed.points[polyline01Fixed.points.length-1].longitude,
                polyline01Fixed.points[polyline01Fixed.points.length-2].latitude, 
                polyline01Fixed.points[polyline01Fixed.points.length-2].longitude,"meters");
            double dist1=fmm.distanceBetween(
                polyline01Fixed.points[polyline01Fixed.points.length-2].latitude, 
                polyline01Fixed.points[polyline01Fixed.points.length-2].longitude,
                polyline01Fixed.points[polyline01Fixed.points.length-3].latitude,
                polyline01Fixed.points[polyline01Fixed.points.length-3].longitude,"meters");
                
            if ((dist1>minDistance && dist1<maxDistance) || (dist2>minDistance && dist2<maxDistance)){
              if (AppConfig.shared.log>=3) logger.i("Keep: $dist1 $dist2 ");                                 // Keep point B
            } else {
              polyline01Fixed.points.removeAt(polyline01Fixed.points.length-2); // Remove point B
              dtimeList01Fixed.removeAt(dtimeList01Fixed.length-2);
              if (AppConfig.shared.log>=3) logger.i("Remove: $dist1 $dist2 ");
            }
          }
        }
    }
  }


  static void startTrip(){
    polyline01.points.clear();
    tripStarted=true;
  }
  static void endTrip(){
    tripStarted=false;
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

//  -------------------------------------    Location Notifier (Property of Nirvasoft.com)
class LocationNotifier extends ChangeNotifier {
  LocationNotifier() { 
    _loc01 = Loc01(0, 0,  DateTime(2000));
  }
  late Loc01 _loc01;
  Loc01 get loc01 => _loc01;
  final MapController _mapController = MapController();
  MapController get mapController => _mapController;
  
  void updateLoc1(double lat, double lng, DateTime dt){
    _loc01 = Loc01(lat, lng, dt);
    notifyListeners();
  }
}
class Loc01 { 
  final double  lat;
  final double lng; 
  final DateTime dt;
  Loc01(this.lat, this.lng, this.dt);
} 
//  -------------------------------------    Location Notifier (Property of Nirvasoft.com)


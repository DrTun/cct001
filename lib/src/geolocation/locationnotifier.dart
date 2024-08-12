//  -------------------------------------    Location Notifier (Property of Nirvasoft.com)
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class LocationNotifier extends ChangeNotifier {
  LocationNotifier() { 
    _loc01 = Loc01(0, 0,  DateTime(2000));
    _tripdata = TripData(false,0,0,0,0);
  }
  late Loc01 _loc01;
  Loc01 get loc01 => _loc01;
  late TripData _tripdata;
  TripData get tripdata => _tripdata;
  final MapController _mapController = MapController();
  MapController get mapController => _mapController;
  
  void updateLoc1(double lat, double lng, DateTime dt){
    _loc01 = Loc01(lat, lng, dt);
    notifyListeners();
  }

  void updateTripData(bool started,double dis, int tme, double spd, double amt){
    _tripdata = TripData(started,dis,tme,spd,amt);
    notifyListeners();
  }
}
class Loc01 { 
  final double  lat;
  final double lng; 
  final DateTime dt;
  Loc01(this.lat, this.lng, this.dt);
} 
class TripData {
  final bool started ;
  final double distance;
  final int time;
  final double speed;
  final double amount;
  TripData(this.started, this.distance,this.time,this.speed,this.amount);
}
//  -------------------------------------    Location Notifier (Property of Nirvasoft.com)


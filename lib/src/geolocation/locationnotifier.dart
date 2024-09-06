//  -------------------------------------    Location Notifier (Property of Nirvasoft.com)
import 'package:flutter/material.dart';

class LocationNotifier extends ChangeNotifier {
  LocationNotifier() { 
    _tripdata = TripData(false,0,0,0,0);
  }
  late TripData _tripdata;
  TripData get tripdata => _tripdata;

  void updateTripData(bool started,double dis, int tme, double spd, double amt){
    _tripdata = TripData(started,dis,tme,spd,amt);
    notifyListeners();
  }
  void notify() {
    notifyListeners(); // Notify listeners that the data has changed
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


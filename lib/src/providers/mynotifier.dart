import 'package:flutter/material.dart';
//  -------------------------------------    My Notifier (Property of Nirvasoft.com)
class MyNotifier extends ChangeNotifier {
  MyNotifier() {
    _data01 = Data01('ID', 'NAME',false);
    _data02 = Data02('s1', 's1',false,0,0);
  }

  late Data01 _data01;
  Data01 get data01 => _data01;
  
  void updateData01(String id, String name,bool online) {
    _data01 = Data01(id, name,online);
    notifyListeners(); // Notify listeners that the data has changed
  } 


  late Data02 _data02;
  Data02 get data2 => _data02;

  // void updateTripData(String s1, String s2,bool started,double lat,double lng) {
  //   _data02 = Data02(s1,s1,started,lat,lng);
  //   notifyListeners(); // Notify listeners that the data has changed
  // } 


  // void notify() {
  //   notifyListeners(); // Notify listeners that the data has changed
  // } 
}



//  -------------------------------------    My Notifier Models (Property of Nirvasoft.com)
class Data01 {
  final bool online ;
  final String id;
  final String name;
  Data01(this.id, this.name,this.online);
}

class Data02 {
  final bool started ;
  final String s1;
  final String s2;
  final double lat;
  final double lng;
  Data02(this.s1, this.s2,this.started,this.lat,this.lng);
}
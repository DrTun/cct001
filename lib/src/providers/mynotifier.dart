import 'package:flutter/material.dart';
//  -------------------------------------    My Notifier (Property of Nirvasoft.com)
class MyNotifier extends ChangeNotifier {
  MyNotifier() {
    _data01 = Data01('CCT1', 'Clean Code Template');
    _data02 = Data02('CCT1', 'Clean Code Template');
  }

  late Data01 _data01;
  Data01 get data01 => _data01;
  void updateData01(String id, String name) {
    _data01 = Data01(id, name);
    notifyListeners(); // Notify listeners that the data has changed
  } 

  late Data02 _data02;
  Data02 get data02 => _data02;
  void updateData02(String id, String name) {
    _data02 = Data02(id, name);
    notifyListeners(); // Notify listeners that the data has changed
  } 

}



//  -------------------------------------    My Notifier Models (Property of Nirvasoft.com)
class Data01 {
  final String id;
  final String name;
  Data01(this.id, this.name);
}
class Data02 {
  final String id;
  final String name;
  Data02(this.id, this.name);
} 
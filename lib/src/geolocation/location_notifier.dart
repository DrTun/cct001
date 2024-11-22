//  -------------------------------------    Location Notifier (Property of Nirvasoft.com)
import 'package:flutter/material.dart';

class LocationNotifier extends ChangeNotifier {
  LocationNotifier();
  void notify() {
    notifyListeners(); // Notify listeners that the data has changed
  } 
}


//  -------------------------------------    Location Notifier (Property of Nirvasoft.com)


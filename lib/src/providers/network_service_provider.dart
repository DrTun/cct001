import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkServiceProvider{
   ValueNotifier<bool> isOnline = ValueNotifier<bool>(false);

  NetworkServiceProvider() {
    _checkInitialConnection();
    _listenToNetworkChanges();
  }

  // Check initial network connection status
  void _checkInitialConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isOnline.value = _updateOnlineStatus(connectivityResult);
  }

  // Listen for network connectivity changes
  void _listenToNetworkChanges() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      isOnline.value = _updateOnlineStatus(result);
    });
  }

  // Helper method to update the online status based on connectivity result
  bool _updateOnlineStatus(List<ConnectivityResult> result) {
  if(result.length > 1){
    if(result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)){
      return true;
    }else{
      return false;}

  }else{
    if (result[0] == ConnectivityResult.wifi || result[0] == ConnectivityResult.mobile) {
      return true; // Connected to either WiFi or mobile data
    } else {
      return false; // No connection
    }
  }
}

  static Future<void> checkConnectionStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    NetworkServiceProvider().isOnline.value = NetworkServiceProvider()._updateOnlineStatus(connectivityResult);
  }
}

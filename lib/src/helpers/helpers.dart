
import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
//  -------------------------------------    Helpers (Property of Nirvasoft.com)

final logger = Logger();
class MyHelpers{
  static msg(String txt, {int? sec, Color? bcolor}){
    sec ??= 2;
    bcolor ??= Colors.redAccent;
    Fluttertoast.showToast(
      msg: txt,toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: sec,  backgroundColor: bcolor, textColor: Colors.white,fontSize: 16.0);
  }
  static showIt(String? value, {String? label}){
  label ??= "Value";
  MyHelpers.msg("$label:  $value",bcolor: Colors.orange);   
  logger.i("$label: $value");
  }
    static Future<String?> getString(BuildContext context,String initvalue,String label) async {
    String? result =  await prompt(
              context,title: Text(label),
              initialValue: initvalue,
              textOK: const Text('OK'), textCancel: const Text('Cancel'),
            );
    return result;
  }
  static Future<int?> getInt(BuildContext context,int initvalue,String label) async {
    int? ret;
    String? result = await getString(context,"$initvalue",label);
      if (result != null) {
        int? parsedResult = int.tryParse(result);
          if (parsedResult != null) { 
            ret = parsedResult;
          }
      }
    return ret;
  }
  static Future<double?> getDouble(BuildContext context,double initvalue,String label) async {
    double? ret;
    String? result = await getString(context,"$initvalue",label);
    if (result != null) {
      double? parsedResult = double.tryParse(result);
      if (parsedResult != null) { 
          ret = parsedResult;
        }
    }
    return ret;
  }


  static Future<bool?> getBool(BuildContext context,String label,{String? title}) async {
    bool ret;
    title ??= "Confirmation";
    ret =await confirm(context,title:  Text(title),content: Text(label),
        textOK: const Text('OK'),textCancel: const Text('Cancel'),);
    return ret;
  }
  





  static String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    
    String hoursString = hours.toString().padLeft(2, '0');
    String minutesString = minutes.toString().padLeft(2, '0');
    String secondsString = remainingSeconds.toString().padLeft(2, '0');
    
    return '$hoursString:$minutesString:$secondsString';
  }

  static String formatDouble(double number){
    NumberFormat numberFormat = NumberFormat("#,##0.00");
    String formattedNumber = numberFormat.format(number);
    return formattedNumber;
  }


}


class MySecure {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  writeSecureData(String key, String value) async {
    await storage.write(key: key, value: value);
  }
  Future<String> readSecureData(String key) async {
    String value = await storage.read(key: key) ?? 'No data found!'; 
    return value;
  }
  deleteSecureData(String key) async {
    await storage.delete(key: key);
  }
}

class MyStore {
  static dynamic prefs;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }
  static Future<void> storePolyline(Polyline polyline,String fname) async {
  // Convert Polyline to a JSON string
  final Map<String, dynamic> polylineMap = { 
    'points': polyline.points.map((LatLng point) {
      return {'latitude': point.latitude, 'longitude': point.longitude};
    }).toList(),
    'color': polyline.color.value,
    'width': polyline.strokeWidth,
  };
  final String polylineJson = jsonEncode(polylineMap);

  // Store JSON string in SharedPreferences
  await MyStore.prefs.setString(fname, polylineJson);
}
// Function to retrieve a Polyline object
static Future<Polyline?> retrievePolyline(String fname) async {  
  final String? polylineJson = MyStore.prefs.getString(fname);
  if (polylineJson == null) {
    return null; // Handle the case where there is no stored polyline
  }
  // Convert JSON string back to Polyline
  final Map<String, dynamic> polylineMap = jsonDecode(polylineJson);

  final List<LatLng> points = (polylineMap['points'] as List).map((point) {
    return LatLng(point['latitude'], point['longitude']);
  }).toList();
  return Polyline( 
    points: points,
    color: Color(polylineMap['color']),
    strokeWidth: polylineMap['width'],
  );
  }

  static Future<void> storeDateTimeList(List<DateTime> dateTimeList, String fname) async { 
  // Convert List<DateTime> to List<String>
  final List<String> dateTimeStrings = dateTimeList.map((dateTime) {
    return dateTime.toIso8601String();
  }).toList();

  // Store the list of strings in SharedPreferences
  await prefs.setStringList(fname, dateTimeStrings);
  }

  static Future<List<DateTime>> retrieveDateTimeList(String fname) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve List<String> from SharedPreferences
  final List<String>? dateTimeStrings = prefs.getStringList(fname);
    if (dateTimeStrings == null) {
      return []; // Return an empty list if there is no stored list
    }

    // Convert List<String> back to List<DateTime>
    return dateTimeStrings.map((dateTimeString) {
      return DateTime.parse(dateTimeString);
    }).toList();
  }
}
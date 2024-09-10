import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../geolocation/geodata.dart';
import '../sqflite/sqf_trip_helpers.dart';
import '../sqflite/sqf_trip_model.dart';
//  -------------------------------------    Helpers (Property of Nirvasoft.com)

final logger = Logger();

class MyHelpers {
  static void msg({
    required String message,
    int? sec,
    Color? backgroundColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: sec ?? 3,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static showIt(String? value, {String? label}) {
    label ??= "Value";
    MyHelpers.msg(message: "$label:  $value", backgroundColor: Colors.red);
    logger.i("$label: $value");
  }

  static Future<String?> getString(
      BuildContext context, String initvalue, String label) async {
    String? result = await prompt(
      context,
      title: Text(label),
      initialValue: initvalue,
      textOK: const Text('OK'),
      textCancel: const Text('Cancel'),
    );
    return result;
  }

  static Future<int?> getInt(
      BuildContext context, int initvalue, String label) async {
    int? ret;
    String? result = await getString(context, "$initvalue", label);
    if (result != null) {
      int? parsedResult = int.tryParse(result);
      if (parsedResult != null) {
        ret = parsedResult;
      }
    }
    return ret;
  }

  static Future<double?> getDouble(
      BuildContext context, double initvalue, String label) async {
    double? ret;
    String? result = await getString(context, "$initvalue", label);
    if (result != null) {
      double? parsedResult = double.tryParse(result);
      if (parsedResult != null) {
        ret = parsedResult;
      }
    }
    return ret;
  }

  static Future<bool?> getBool(
    BuildContext context,
    String label, {
    String title = "Confirmation",
  }) async {
    return await confirm(
      context,
      title: Text(title),
      content: Text(label),
      textOK: const Text('OK'),
      textCancel: const Text('Cancel'),
    );
  }

  static String formatTime(int seconds, {bool? sec}) {
    sec ??= false;
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String hoursString = hours.toString().padLeft(2, '0');
    String minutesString = minutes.toString().padLeft(2, '0');
    String secondsString = remainingSeconds.toString().padLeft(2, '0');

    if (sec) {
      return '$hoursString:$minutesString:$secondsString';
    } else {
      return '$hoursString:$minutesString';
    }
  }

  static String formatDouble(double number) {
    NumberFormat numberFormat = NumberFormat("#,##0.00");
    String formattedNumber = numberFormat.format(number);
    return formattedNumber;
  }

  static String ymdhmsDateFormat() {
    final DateTime now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd HH:mm:ss');
    return formatter.format(now);
  }

  static String ymdDateFormat(DateTime now) {
    final formatter = DateFormat('yyyyMMdd');
    return formatter.format(now);
  }

  static String formatTripDate(String date) {
    DateTime originalDateTime = DateTime.parse(date);

    // Desired format: 01:54 AM, 05/09/2024
    String formattedDate =
        DateFormat('hh:mm a, dd/MM/yyyy').format(originalDateTime);

    return formattedDate;
  }

  static String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    String hoursStr = hours > 0 ? '$hours hr${hours > 1 ? 's' : ''} ' : '';
    String minutesStr =
        minutes > 0 ? '$minutes min${minutes > 1 ? 's' : ''} ' : '';
    String secondsStr = secs > 0 ? '$secs sec${secs > 1 ? 's' : ''} ' : '';

    return (hoursStr + minutesStr + secondsStr).trim();
  }

  static List<String> dateTimeListToStringList(List<DateTime> dateTimeList) {
    return dateTimeList.map((dateTime) => dateTime.toIso8601String()).toList();
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

  static Future<void> storePolyline(List<LatLng> points, String fname) async {
    // Convert Polyline to a JSON string
    final Map<String, dynamic> polylineMap = {
      'points': points.map((LatLng point) {
        return {'latitude': point.latitude, 'longitude': point.longitude};
      }).toList()
    };
    final String polylineJson = jsonEncode(polylineMap);
    // Store JSON string in SharedPreferences
    await MyStore.prefs.setString(fname, polylineJson);
  }

  // Function to retrieve a Polyline object
  static Future<List<LatLng>?> retrievePolyline(String fname) async {
    final String? polylineJson = MyStore.prefs.getString(fname);
    if (polylineJson == null) {
      return null; // Handle the case where there is no stored polyline
    }
    // Convert JSON string back to Polyline
    final Map<String, dynamic> polylineMap = jsonDecode(polylineJson);

    final List<LatLng> points = (polylineMap['points'] as List).map((point) {
      return LatLng(point['latitude'], point['longitude']);
    }).toList();
    return points;
  }

  static Future<void> storeDateTimeList(
      List<DateTime> dateTimeList, String fname) async {
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

class MyTripDBOperator {
  final db = TripsDatabaseHelper.instance;

  Future<void> saveTripToDB() async {
    var uuid = const Uuid().v4();
    String date = MyHelpers.ymdDateFormat(DateTime.now());
    List<String> dateTimeList =
        MyHelpers.dateTimeListToStringList(GeoData.previousTrip.dtimeListFixed);
    List<String> orgDateTimeList =
        MyHelpers.dateTimeListToStringList(GeoData.previousTrip.dtimeList);

    TripModel trip = TripModel(
      tripId: uuid,
      startTime: GeoData.previousTrip.dtimeListFixed.first.toString(),
      endTime: DateTime.now().toString(),
      route: GeoData.previousTrip.pointsFixed,
      originalRoute: GeoData.previousTrip.points,
      dateTimeList: dateTimeList,
      originalDateTimeList: orgDateTimeList,
      tripStatus:
          'posted', // saved (can add fees etc) , posted (cant edit data. can print receipt)
      tripDuration: GeoData.previousTrip.duration.toString(),
      distance: GeoData.previousTrip.distance.toString(),
      orgDistance:
          GeoData.totalDistance(GeoData.previousTrip.points).toString(),
      startLocName: "", //default empty for now
      endLocName: "", //default empty for now
      totalAmount: "", //default empty for now
      rate: "", //default value for now
      initial: "", // default value for now
      createdDate: date,
    );
    logger.i(trip.toJson());
    await db.insertTrip(trip);
  }
}

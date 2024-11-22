import 'dart:convert';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/flaxi/api_data_models/driver_register_models.dart';
import '../modules/flaxi/api_data_models/groups_models.dart';
import '../modules/flaxi/api_data_models/rateby_groups_models.dart';
import '../geolocation/geo_data.dart';
import '../modules/flaxi/helpers/extras_helper.dart';
import '../modules/flaxi/helpers/log_model.dart';
import '../modules/flaxi/helpers/log_service.dart';
import '../sqflite/extras_model.dart';
import '../sqflite/trips_database_helper.dart';
import '../sqflite/trip_model.dart';
//  -------------------------------------    Helpers (Property of Nirvasoft.com)

final logger = Logger();
ExtrasData extrasData = ExtrasData.curExtrasData;
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

  Future<String> getMessageFromCode(String messageCode) async {
    try {
      String jsonMessageCode =
          await rootBundle.loadString('lib/src/message/messagecode.json');
      final Map<String, dynamic> messages = jsonDecode(jsonMessageCode);

      String jsonResonse =
          await rootBundle.loadString('lib/src/message/message_response.json');
      final Map<String, dynamic> messageresponse = jsonDecode(jsonResonse);

      return messageresponse[messages[messageCode]] ??
          'Unknown error'; // Return message or 'Unknown error' if not found
    } catch (e) {
      return 'Error loading messages';
    }
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

  static String formatInt(int number) {
    NumberFormat numberFormat = NumberFormat("#,##0");
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

  static String ymdDateFormatdashboard(DateTime now) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  static String ymdDateFormatapi(String date) {
    DateTime originalDateTime = DateTime.parse(date);
    String formattedDate =
        DateFormat('dd/MM/yyyy    hh:mm ').format(originalDateTime);
    return formattedDate;
  }

  static String ymdDateFormatTran(String date) {
    DateTime originalDateTime = DateTime.parse(date);
    String formattedDate = DateFormat('dd/MM/yyyy').format(originalDateTime);
    return formattedDate;
  }

  static String ymdDateFormatTranTime(String date) {
    DateTime originalDateTime = DateTime.parse(date).toLocal();
    String formattedDate =
        (DateFormat('hh:mm a').format(originalDateTime));
    return formattedDate;
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
    String secondsStr = (hours == 0 && minutes == 0 && secs > 0)
        ? '$secs sec${secs > 1 ? 's' : ''} '
        : '';

    return (hoursStr + minutesStr + secondsStr).trim();
  }

  static String formatWaitingTime(int min) {
    int hours = min ~/ 60;
    int minutes = ((min * 60) % 3600) ~/ 60;
    String hoursStr = hours > 0 ? '$hours hr${hours > 1 ? 's' : ''} ' : '';
    String minutesStr =
        minutes > 0 ? '$minutes min${minutes > 1 ? 's' : ''} ' : '';
    return (hoursStr + minutesStr).trim();
  }

  static List<String> dateTimeListToStringList(List<DateTime> dateTimeList) {
    return dateTimeList.map((dateTime) => dateTime.toIso8601String()).toList();
  }
}

class MySecure {
  final FlutterSecureStorage storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
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

  static Future<void> storeMapType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maptype', GeoData.mapType);
  }

  static Future<void> getMapType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? maptype = prefs.getInt('maptype');
    if (maptype != null) {
      GeoData.mapType = maptype;
    }
  }

  static Future<void> storeSignInDetails(
      int signInType, DateTime signInDateTime) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('signintype', signInType);
    String formattedDateTime = signInDateTime.toIso8601String();
    await prefs.setString('signindatetime', formattedDateTime);
  }

  static Future<void> clearSignInDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('signintype');
    await prefs.remove('signindatetime');
  }

  static Future<void> saveCurTripID(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('curtripstatus', value);
  }

  static Future<String?> getCurTripID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('curtripstatus');
    logger.i(value);
    return value;
  }

  static Future<Group?> retriveDrivergroup(String fname) async {
    final String? driverGroupJson = MyStore.prefs.getString(fname);
    if (driverGroupJson != null) {
      Map<String, dynamic> driverGroupMap = jsonDecode(driverGroupJson);
      Group driverGroup = Group.fromJson(driverGroupMap);
      return driverGroup;
    }
    return null;
  }

  static Future<void> storeDriverRegister(
      DriverRegisterResponse data, String fname) async {
    String driverRegister = jsonEncode(data.toJson());
    await MyStore.prefs.setString(fname, driverRegister);
  }

  static Future<void> storeDrivergroup(Group data, String fname) async {
    String drivergroupJson = jsonEncode(data.toJson());
    await MyStore.prefs.setString(fname, drivergroupJson);
  }

  static Future<void> storeDriverGroupList(List<Group> gp, String fname) async {
    String allGroup = jsonEncode(gp.map((v) => v.toJson()).toList());
    await MyStore.prefs.setString(fname, allGroup);
  }

  static Future<List<Group>?> retrieveGroupList(String fname) async {
    final String? data = MyStore.prefs.getString(fname);
    if (data != null) {
      List<dynamic> groupListData = jsonDecode(data);
      List<Group> rateDataList = groupListData
          .map((groupdata) => Group.fromJson(groupdata as Map<String, dynamic>))
          .toList();
      return rateDataList;
    }
    return null;
  }

  static Future<void> storeRatebyGroup(List<Rate> data, String fname) async {
    String ratebyGroup = jsonEncode(data.map((v) => v.toJson()).toList());
    await MyStore.prefs.setString(fname, ratebyGroup);
  }

  static Future<List<Rate>?> retrieveRatebyGroup(String fname) async {
    final String? data = MyStore.prefs.getString(fname);
    if (data != null) {
      List<dynamic> rateGroupData = jsonDecode(data);
      List<Rate> rateDataList = rateGroupData
          .map((ratedata) => Rate.fromjson(ratedata as Map<String, dynamic>))
          .toList();
      return rateDataList;
    }
    return null;
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

  static Future<void> saveRateScheme(Map<String, dynamic> scheme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(scheme);
    await prefs.setString('selectedRateScheme', jsonString);
  }

  static Future<Map<String, dynamic>?> getRateScheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('selectedRateScheme');
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } else {
      return {}; // Handle case where no data is stored
    }
  }

  static Future<void> saveExtrasList(List<Extra> extras) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the list of Extra objects to a list of Maps
    List<String> extrasJsonList =
        extras.map((extra) => jsonEncode(extra.toJson())).toList();

    // Store the list of JSON strings in SharedPreferences
    await prefs.setStringList('extras', extrasJsonList);
  }

  static Future<List<Extra>> getExtrasList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the list of JSON strings from SharedPreferences
    List<String>? extrasJsonList = prefs.getStringList('extras');

    if (extrasJsonList != null) {
      // Convert the list of JSON strings back to a list of Extra objects
      return extrasJsonList
          .map((jsonStr) => Extra.fromJson(jsonDecode(jsonStr)))
          .toList();
    }

    return [];
  }


  static Future<void> saveSelectedExtras() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'selectedExtras',
      extrasData.selectedExtras.map((e) => e.toString()).toList(),
    );
  }
  

  static Future<void> clearExtraList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('extras');
    await prefs.remove('selectedExtras');
    
  }
}

class MyTripDBOperator {
  final db = TripsDatabaseHelper.instance;

  Future<void> saveTripToDB(TripModel trip) async {
    try {
      await db.insertTrip(trip);
    } catch (error) {
      LogService.writeLog(LogModel(
          errorMessage: error.toString(),
          stackTrace: '',
          timestamp: DateTime.now().toIso8601String()));
      logger.e(error);
    }
  }

  Future<void> saveExtrasToDB(List<Extra> extraList, String tripID) async {
    try {
      for (var extra in extraList) {
        int amount = int.parse(extra.amount);
        int qty = extra.qty;
        int total = amount * qty;
        if (total > 0) {
          ExtrasModel extrasModel = ExtrasModel(
              tripID: tripID,
              name: extra.name,
              amount: extra.amount,
              type: extra.type,
              subTotal: total.toString(),
              qty: extra.qty.toString());
          await db.insertExtras(extrasModel);
          logger.i("Extras ${extrasModel.toJson()}");
        }
      }
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> saveWaitingChargeToDB(String tripID, int wt) async {
    if (wt == 1) {
      try {
        String name = 'Waiting Charges';
        String amount = GeoData.wchargebyGroup.toString();
        String type = '0';
        String qty = '';
        int total = GeoData.waitingCharge;
        if (total > 0) {
          ExtrasModel extrasModel = ExtrasModel(
              tripID: tripID,
              name: name,
              amount: amount,
              type: type,
              subTotal: total.toString(),
              qty: qty);
          await db.insertExtras(extrasModel);
          logger.i("Extras ${extrasModel.toJson()}");
        }
      } catch (error) {
        logger.e(error);
      }
    } else {
      {
        try {
          String name = 'Waiting Time';
          String amount = GeoData.wchargebyGroup.toString();
          String type = '0';
          String qty = '';
          int total = GeoData.waitcount;
          if (GeoData.waitcount > 0) {
            ExtrasModel extrasModel = ExtrasModel(
                tripID: tripID,
                name: name,
                amount: amount,
                type: type,
                subTotal: total.toString(),
                qty: qty);
            await db.insertExtras(extrasModel);
            logger.i("Extras ${extrasModel.toJson()}");
          }
        } catch (error) {
          logger.e(error);
        }
      }
    }
  }

  Future<void> updateCloudStatus(String tripID, String newStatus) async {
    try {
      await db.updateCloudStatus(tripID, newStatus);
    } catch (error) {
      LogService.writeLog(LogModel(
          errorMessage: error.toString(),
          stackTrace: '',
          timestamp: DateTime.now().toIso8601String()));
      logger.e(error);
    }
  }
}

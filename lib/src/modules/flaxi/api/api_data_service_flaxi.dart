import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../helpers/helpers.dart';
import '../../../shared/app_config.dart';
import '../../../socket/socket_data_model.dart';
import '../api_data_models/dashboard_models.dart';
import '../api_data_models/driver_transaction.dart';
import '../api_data_models/driver_version_update.dart';
import '../helpers/log_model.dart';
import '../helpers/log_service.dart';
import '../api_data_models/driver_register_models.dart';
import '../api_data_models/error_models.dart';
import '../api_data_models/groups_models.dart';
import '../api_data_models/rateby_groups_models.dart';
import '../api_data_models/trip_data_models.dart';

class ApiDataServiceFlaxi {
  String timestamp = DateTime.now().toIso8601String();
  static String baseURL = AppConfig.shared.baseURL;
  // static String baseURLDEV = AppConfig.shared.baseURLDEV;
  static const sec = 60;
  Future<Map<String, dynamic>> sendTrip(TripDataModel trip) async {
    final url = Uri.parse("$baseURL/trip");
    try {
      final response = await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(trip.toJson()),
      )
          .timeout(
        const Duration(seconds: sec),
        onTimeout: () {
          return http.Response(
            jsonEncode({'status': 408, 'message': 'Request time out'}),
            408,
          );
        },
      );
      if (response.statusCode == 200) {
        logger.i("Trip data sent successfully.");
        return jsonDecode(response.body);
      } else {
        final res = jsonDecode(response.body);
        logger.e("Failed to send trip data. Status code: $res");
        if (AppConfig.shared.log >= 1) {
          logger.e("Unautorized Access (Login): ${response.body}");
        }
        return jsonDecode(response.body);
      }
    } catch (e, stacktrace) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: stacktrace.toString(),
          timestamp: timestamp));
      if (AppConfig.shared.log >= 1) {
        logger.e("Other Exceptions (Login)): $e\n$stacktrace");
      }
      return {"status": 500, "message": "Other Exceptions (Login): $e"};
    }
  }

  Future<dynamic> getGroups(String driverID) async {
    final url = Uri.parse("$baseURL/domain/list");
    try {
      final response = await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userid": driverID}),
      )
          .timeout(
        const Duration(seconds: sec),
        onTimeout: () {
          return http.Response(
            jsonEncode({'status': 408, 'message': 'Request time out'}),
            408,
          );
        },
      );

      if (response.statusCode == 200) {
        logger.i('data>>${response.body}');
        return GroupsModels.fromJson(jsonDecode(response.body));
      } else {
        return ErrorModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: 'Get Group By User ID',
          timestamp: timestamp));
      return ErrorModel(status: 500, message: 'Unexpected error occurred');
    }
  }

  Future<dynamic> getDriverInfo(String driverID) async {
    final url = Uri.parse("$baseURL/driver/info");
    try {
      final response = await http
          .post(url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"driverid": driverID}))
          .timeout(
        const Duration(seconds: sec),
        onTimeout: () {
          return http.Response(
            jsonEncode({'status': 408, 'message': 'Request time out'}),
            408,
          );
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logger.i('data>>${response.body}');
        return DriverProfile.fromJson(responseData['data']);
      } else {
        return ErrorModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: 'Get Group By Driver ID',
          timestamp: timestamp));
      return ErrorModel(status: 500, message: 'Unexpected error occurred');
    }
  }

  Future<dynamic> sendCurLoc(SocketDataBody data) async {
    final url = Uri.parse("$baseURL/location/gis");
    logger.i(data.toJson());
    try {
      final response = await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data.toJson()),
      )
          .timeout(
        const Duration(seconds: sec),
        onTimeout: () {
          return http.Response(
            jsonEncode({'status': 408, 'message': 'Request time out'}),
            408,
          );
        },
      );
      if (response.statusCode == 200) {
        // MyHelpers.msg(message: "Location data sent successfully.", backgroundColor: Colors.lightBlueAccent);
        return true;
      } else {
        logger.e(jsonDecode(response.body));
        MyHelpers.msg(
            message: "Location data not sent successfully.",
            backgroundColor: Colors.redAccent);
        return false;
      }
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: 'Location Data Sent (api_data_service_flaxi)',
          timestamp: timestamp));
      MyHelpers.msg(
          message: "Location data not sent successfully.",
          backgroundColor: Colors.redAccent);
      logger.e(e.toString());
      return false;
    }
  }

  Future<dynamic> ratebyGroups(String domainId) async {
    final url = Uri.parse("$baseURL/rate/getbydomain");
    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"id": domainId}));
      if (response.statusCode == 200) {
        return RatebyGroups.fromjson(jsonDecode(response.body));
      } else {
        return ErrorModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: ' ratebyGroups by domainId (api_data_service_flaxi)',
          timestamp: timestamp));
      return ErrorModel(status: 500, message: "Unexpected error occurred");
    }
  }

  Future<dynamic> driverRegister(DriverRegister req) async {
    final url = Uri.parse("$baseURL/driver");

    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(req.toJson()));

      if (response.statusCode == 200) {
        return DriverRegisterResponse.fromJson(jsonDecode(response.body));
      } else {
        return ErrorModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: ' driverRegister (api_data_service_flaxi)',
          timestamp: timestamp));
      return ErrorModel(status: 500, message: "Unexpected error occurred");
    }
  }

  Future<dynamic> driverProfile(DriverProfile req) async {
    final url = Uri.parse("$baseURL/driver/profile/update");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(req.toJson()),
      );

      logger.i("Response status: ${response.statusCode}");
      logger.i("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logger.i("Profile update success: $responseData");

        // Parse the response into the appropriate data model
        return responseData;
      } else {
        // Parse error response and return as ErrorModel
        final errorData = jsonDecode(response.body);
        return ErrorModel.fromJson(errorData);
      }
    } catch (e) {
      // Log the exception
      logger.e("Exception in driverProfile: $e");

      // Write the error to the log service
      LogService.writeLog(LogModel(
        errorMessage: e.toString(),
        stackTrace: 'driverProfile (api_data_service_flaxi)',
        timestamp: DateTime.now().toIso8601String(),
      ));

      // Return a generic error model
      return ErrorModel(status: 500, message: "Unexpected error occurred");
    }
  }

  Future<dynamic> driverDashboard(DashboardReqModel req) async {
    final url = Uri.parse("$baseURL/driver/dashboard");

    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(req.toJson()));

      if (response.statusCode == 200) {
        return DashboardResponse.fromJson(jsonDecode(response.body));
      } else {
        ErrorModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: ' driverDashboard (api_data_service_flaxi)',
          timestamp: timestamp));
      return ErrorModel(status: 500, message: "Unexpected error occurred");
    }
  }

  Future<dynamic> driverDashboardDetails(DriverDashBoardDetailsReq req) async {
    final url = Uri.parse("$baseURL/driver/dashboard/details");
    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/Json"},
          body: jsonEncode(req.toJson()));

      if (response.statusCode == 200) {
        return DriverDashBoardDetailsResponse.fromJson(
            jsonDecode(response.body));
      } else {
        return ErrorModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: ' driverDashboard (api_data_service_flaxi)',
          timestamp: timestamp));
      return ErrorModel(status: 500, message: "Unexpected error occurred");
    }
  }

  Future<dynamic> driverTranscation(DriverTransactionReq req, curCount) async {
    final url =
        Uri.parse("$baseURL/driver/transaction?curPage= $curCount&pageSize=10");
    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/Json"},
          body: jsonEncode(req.toJson()));

      if (response.statusCode == 200) {
        return DriverTransactionResponse.fromJson(jsonDecode(response.body));
      } else {
        return ErrorModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: ' driverDashboard (api_data_service_flaxi)',
          timestamp: timestamp));
      return ErrorModel(status: 500, message: "Unexpected error occurred");
    }
  }

  Future<dynamic> driverAppversionUpdate( VersionUpdateReq req ) async{
    final url = Uri.parse("$baseURL/driver/appversion/update");
    
    try{
      final response = await http.post(
      url,
      headers: {"Content-Type" : "application/Json"},
      body: jsonEncode(req.toJson())
      );

      if(response.statusCode == 200) {
        return VersionUpdateResponse.fromJson(jsonDecode(response.body));
      } else {
        ErrorModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace:' driverAppversion (api_data_service_flaxi)', timestamp: timestamp));
      return ErrorModel(status: 500, message: "Unexpected error occurred"); 
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../api/api_service.dart';
import '../../helpers/helpers.dart';
import '../../modules/flaxi/helpers/log_model.dart';
import '../../modules/flaxi/helpers/log_service.dart';
import '../../shared/app_config.dart';
import '../../shared/global_data.dart';
import '../models/xpass_register_models.dart';

class XpassApiData {
  static String xpassBaseURL = AppConfig.shared.xpassBaseURL;
  final ApiService apiService = ApiService();
  static const sec = 60;
  Future<Map<String, dynamic>> getXpassLogs(int currentPage, int size) async {
    return getXpassApiData(
        "api/v1/log?page=$currentPage&size=$size", 'xpasslogslist');
  }

  Future<Map<String, dynamic>> getXpassUserStatus() async {
    return getXpassApiData("api/v1/user/check-user", 'xpasscheckAdminStatus');
  }

  Future<Map<String, dynamic>> getXpassRegister(
      int currentPage, int size) async {
    return getXpassApiData(
        "api/v1/register?page=$currentPage&size=$size", 'xpassregisterlist');
  }

  Future<Map<String, dynamic>> putXpassRegister(
      RegisterItem updatedRegisterItem) {
    return putXpassApiData(
        'api/v1/register', updatedRegisterItem, 'xpasseditregister');
  }

  Future<Map<String, dynamic>> postXpassRegister(RegisterItem registerItem) {
    return postXpassApiData(
        'api/v1/register', registerItem, 'xpasscreateregister');
  }

  String timestamp = DateTime.now().toIso8601String();

  Future<Map<String, dynamic>> getXpassApiData(String path, String nick) async {
    Uri url = Uri.parse("$xpassBaseURL/$path");
    try {
      Response response1 = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": GlobalAccess.accessToken,
      }).timeout(
        const Duration(seconds: sec),
        onTimeout: () {
          return http.Response(
            jsonEncode({'status': 408, 'message': 'Request time out'}),
            408,
          );
        },
      );
      if (response1.statusCode == 200) {
        return {'status': 200, 'data': jsonDecode(response1.body)};
      } else if (response1.statusCode == 401) {
        return {'status': 401, 'data': false};
      } else {
        logger.e(">>> Expired by Server");
        if (AppConfig.shared.log >= 1) {
          logger.e("Unauthorized Access ($nick)");
        }
        if (await apiService.xpassAccesstokenChange()) {
          if (AppConfig.shared.log >= 1) {
            logger.e(">>> 1) Refreshed Succssfully");
          }
          Response response2 = await http.get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": GlobalAccess.accessToken,
            },
          );
          if (response2.statusCode == 200) {
            if (AppConfig.shared.log >= 1) {
              logger.e(">>> 2) Retried Successfully");
            }
            return {'status': 201, 'data': jsonDecode(response2.body)};
          } else if (response1.statusCode == 401) {
            return {'status': 401, 'data': false};
          } else {
            if (AppConfig.shared.log >= 1) {
              logger.e("Other Exceptions ($nick): retry faiiled");
            }
            return {
              "status": response2.statusCode,
              "message": "Unauthorized Access ($nick) Retry failed!"
            };
          }
        } else {
          if (AppConfig.shared.log >= 1) {
            logger.e("Other Exceptions ($nick): refresh failed!");
          }
          return {
            "status": response1.statusCode,
            "message": "Unauthorized Access ($nick) Refresh failed!"
          };
        }
      }
    } catch (e, stacktrace) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: stacktrace.toString(),
          timestamp: timestamp));
      if (AppConfig.shared.log >= 1) {
        logger.e("Other Exceptions ($nick): $e\n$stacktrace");
      }
      return {"status": 500, "message": "Other Exceptions ($nick): $e"};
    }
  }

  Future<Map<String, dynamic>> putXpassApiData(
      String path, RegisterItem editRegisterItem, nick) async {
    Uri url = Uri.parse('$xpassBaseURL/$path');

    try {
      Response response1 = await http
          .put(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": GlobalAccess.accessToken
        },
        body: jsonEncode(editRegisterItem.toJson()),
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
      if (response1.statusCode == 200) {
        return {
          'status': 200,
        };
      } else {
        logger.e(">>> Expired by Server");
        if (AppConfig.shared.log >= 1) {
          logger.e("Unauthorized Access ($nick)");
        }
        if (await apiService.xpassAccesstokenChange()) {
          if (AppConfig.shared.log >= 1) {
            logger.e(">>> 1) Refreshed Succssfully");
          }
          Response response2 = await http.get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": GlobalAccess.accessToken,
            },
          );
          if (response2.statusCode == 200) {
            if (AppConfig.shared.log >= 1) {
              logger.e(">>> 2) Retried Successfully");
            }
            return {
              'status': 201,
            };
          } else {
            if (AppConfig.shared.log >= 1) {
              logger.e("Other Exceptions ($nick): retry faiiled");
            }
            return {
              "status": response2.statusCode,
              "message": "Unauthorized Access ($nick) Retry failed!"
            };
          }
        } else {
          if (AppConfig.shared.log >= 1) {
            logger.e("Other Exceptions ($nick): refresh failed!");
          }
          return {
            "status": response1.statusCode,
            "message": "Unauthorized Access ($nick) Refresh failed!"
          };
        }
      }
    } catch (e, stacktrace) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: stacktrace.toString(),
          timestamp: timestamp));
      if (AppConfig.shared.log >= 1) {
        logger.e("Other Exceptions ($nick)): $e\n$stacktrace");
      }
      return {"status": 500, "message": "Other Exceptions ($nick): $e"};
    }
  }

  Future<Map<String, dynamic>> postXpassApiData(
      String path, RegisterItem registerItem, nick) async {
    Uri url = Uri.parse('$xpassBaseURL/$path');

    try {
      Response response1 = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": GlobalAccess.accessToken
        },
        body: jsonEncode(registerItem.toJson()),
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

      if (response1.statusCode == 200) {
        return {
          'status': 200,
        };
      } else {
        logger.e(">>> Expired by Server");
        if (AppConfig.shared.log >= 1) {
          logger.e("Unauthorized Access ($nick)");
        }
        if (await apiService.xpassAccesstokenChange()) {
          if (AppConfig.shared.log >= 1) {
            logger.e(">>> 1) Refreshed Succssfully");
          }
          Response response2 = await http.get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": GlobalAccess.accessToken,
            },
          );
          if (response2.statusCode == 200) {
            if (AppConfig.shared.log >= 1) {
              logger.e(">>> 2) Retried Successfully");
            }
            return {
              'status': 201,
            };
          } else {
            if (AppConfig.shared.log >= 1) {
              logger.e("Other Exceptions ($nick): retry faiiled");
            }
            return {
              "status": response2.statusCode,
              "message": "Unauthorized Access ($nick) Retry failed!"
            };
          }
        } else {
          if (AppConfig.shared.log >= 1) {
            logger.e("Other Exceptions ($nick): refresh failed!");
          }
          return {
            "status": response1.statusCode,
            "message": "Unauthorized Access ($nick) Refresh failed!"
          };
        }
      }
    } catch (e, stacktrace) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: stacktrace.toString(),
          timestamp: timestamp));
      if (AppConfig.shared.log >= 1) {
        logger.e("Other Exceptions ($nick)): $e\n$stacktrace");
      }
      return {"status": 500, "message": "Other Exceptions ($nick): $e"};
    }
  }
}

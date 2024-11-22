import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '/src/shared/app_config.dart';
import '/src/shared/global_data.dart';

class ApiSampleService {
  // final AuthService _authService = AuthService();
  final dio = Dio();
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger logger = Logger();

  Future<Map<String, dynamic>> getList() async {
    return getApiDataMap("user/list", "getList");
  }

  Future<Map<String, dynamic>> getCategories() async {
    return getApiDataMap("dataapi/categories", "getCategories");
  }

  Future<Map<String, dynamic>> getApiDataMap(String path, String nick) async {
    String baseURL = AppConfig.shared.openIDBaseURL; // config.env
    Uri url = Uri.parse("$baseURL/$path");
    try {
      // String? accessToken = await _secureStorage.read(key: 'access_token');
      final response1 = await http.get(
        url,
        headers: {
          "Content-Type": "application/json;",
          'Authorization': 'Bearer ${GlobalAccess.accessToken}',
        },
      );
      if (response1.statusCode == 200) {
        logger.i("Successful to fetch data");
        return {
          "status": response1.statusCode,
          "data": jsonDecode(response1.body)['content']
        }; // Normal successful pass
      } else {
        logger.e(">>> Expired by Server");
        // if (AppConfig.shared.log>=1)
        logger.e("Unauthorized Access (getList): ${response1.body}");

        return {
          "status": response1.statusCode,
          "message": "${response1.statusCode} ${response1.reasonPhrase}"
        };
      }
    } catch (e, stacktrace) {
      if (AppConfig.shared.log >= 1) {
        logger.e("Other Exceptions ($nick): $e\n$stacktrace");
      }
      // return {"status": 500, "message": "Other Exceptions ($nick)"};
      if (e.toString().contains('No host specified in URI')) {
        return {"status": 400, "message": "Invalid URL"};
      } else {
        return {"status": 500, "message": "Other Exceptions ($nick)"};
      }
    }
  }

  // Future<Map<String, dynamic>> getApiDataMap(String path, String nick) async {
  //   String baseURL = AppConfig.shared.openIDBaseURL; // config.env
  //   Uri url = Uri.parse("$baseURL/$path");
  //   AuthService.checkRefreshAccessToken();
  //   try {
  //     // String? accessToken = await _secureStorage.read(key: 'access_token');
  //     final response1 = await http.get(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json;",
  //         'Authorization': 'Bearer ${GlobalAccess.accessToken}',
  //       },
  //     );
  //     if (response1.statusCode == 200) {
  //       logger.i("Successful to fetch data");
  //       return {
  //         "status": response1.statusCode,
  //         "data": jsonDecode(response1.body)['content']
  //       }; // Normal successful pass
  //     } else {
  //       logger.e(">>> Expired by Server");
  //       if (AppConfig.shared.log >= 1) {
  //         logger.e("Unauthorized Access (getList): ${response1.body}");
  //       }
  //       if (await AuthService.refreshAccessToken()) {
  //         if (AppConfig.shared.log >= 1) {
  //           logger.e(">>> 1) Refreshed Succssfully");
  //         }
  //         final response2 = await http.get(
  //           url,
  //           headers: {
  //             "Content-Type": "application/json;",
  //             'Authorization': 'Bearer ${GlobalAccess.accessToken}',
  //           },
  //         );
  //         if (response2.statusCode == 200) {
  //           if (AppConfig.shared.log >= 1) {
  //             logger.e(">>> 2) Retried Successfully");
  //           }
  //           return {
  //             "status": 201, // Refreshed and Retried successful
  //             "data": jsonDecode(response2.body)['content']
  //           };
  //         } else {
  //           if (AppConfig.shared.log >= 1) {
  //             logger.e("Other Exceptions ($nick): retry faiiled");
  //           }
  //           return {
  //             "status": response2.statusCode,
  //             "message": "Unauthorized Access ($nick) Retry failed!"
  //           };
  //         }
  //       } else {
  //         if (AppConfig.shared.log >= 1) {
  //           logger.e("Other Exceptions ($nick): refresh failed!");
  //         }
  //         return {
  //           "status": response1.statusCode,
  //           "message": "Unauthorized Access ($nick) Refresh failed!"
  //         };
  //       }
  //     }
  //   } catch (e, stacktrace) {
  //     if (AppConfig.shared.log >= 1) {
  //       logger.e("Other Exceptions ($nick): $e\n$stacktrace");
  //     }
  //     if (e.toString().contains('No host specified in URI')) {
  //       return {"status": 400, "message": "Invalid URL"};
  //     } else {
  //       return {"status": 500, "message": "Other Exceptions ($nick)"};
  //     }
  //   }
  // }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart'; 
import 'api_auth.dart';
import '/src/globaldata.dart';
import '/appconfig.dart';
//  -------------------------------------    API (Property of Nirvasoft.com)
class ApiDataService {
  static String baseURL = AppConfig.shared.baseURL;
  final Logger logger = Logger();
  
  Future<Map<String, dynamic>> getList() async {
    return getApiDataMap("user/list", "getList");
  }

  Future<Map<String, dynamic>> getApiDataMap(String path, String nick) async {
    final url = Uri.parse("$baseURL/$path"); 
    try {   
      ApiAuthService.checkRefreshToken(); // check if token is expired on client side
      final response1 = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "user_token": GlobalAccess.accessToken,
        },
      );
      if (response1.statusCode == 200) {
        return jsonDecode(response1.body); // Normal successful pass 
      } else {
        logger.e(">>> Expired by Server");
        if (GlobalData.log>=1) logger.e("Unauthorized Access (getList): ${response1.body}"); 
        if (await ApiAuthService.refreshToken()){ // token refreshed
            if (GlobalData.log>=1) logger.e(">>> 1) Refreshed Succssfully");
            final response2 = await http.get(
              url,headers: {"Content-Type": "application/json",
                "user_token": GlobalAccess.accessToken, },
            );
            if (response2.statusCode == 200) {
                    if (GlobalData.log>=1) logger.e(">>> 2) Retried Successfully");
                    Map<String, dynamic> ret = jsonDecode(response2.body);
                    ret["status"] = 201; // Refreshed and Retried successful
                    return ret;
            } else {
              if (GlobalData.log>=1) logger.e("Other Exceptions ($nick): retry faiiled");
              return { "status": response2.statusCode,  "message": "Unauthorized Access ($nick) Retry failed!"  };
            }
        } else {
          if (GlobalData.log>=1) logger.e("Other Exceptions ($nick): refresh failed!");
          return { "status": response1.statusCode,  "message": "Unauthorized Access ($nick) Refresh failed!"  };
        }
      }
    } catch (e, stacktrace) {
      if (GlobalData.log>=1) logger.e("Other Exceptions ($nick): $e\n$stacktrace");
      return {"status": 500, "message": "Other Exceptions ($nick): $e"};
    }
  }
}

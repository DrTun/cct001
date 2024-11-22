import 'dart:async';
import 'dart:convert';
import '../modules/flaxi/helpers/log_model.dart';
import '../modules/flaxi/helpers/log_service.dart';
import '../providers/network_service_provider.dart';
import '/src/shared/global_data.dart';
import '/src/helpers/helpers.dart';
import '../signin/models/auth_models.dart';
import 'package:http/http.dart' as http;
import '/src/shared/app_config.dart';


class ApiService {
  static String authURL = AppConfig.shared.authURL;
  static const sec = 30;
  String  timestamp = DateTime.now().toIso8601String();
  final NetworkServiceProvider networkService = NetworkServiceProvider();

  Future<Map<String, dynamic>> userSignUp(SignUpRequest req) async {
    final url = Uri.parse("$authURL/signup");
    await NetworkServiceProvider.checkConnectionStatus();
    if(networkService.isOnline.value) {
      try {
          final response = await http.post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(req.toJson()),
          ).timeout(const Duration(seconds: sec),onTimeout: () {
            return http.Response(
                jsonEncode({"message_code": "29", 'message': 'Request timed out.'}),
                29,
              );
          },);
          if (response.statusCode == 200) {
            return jsonDecode(response.body);
          } else {
            if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
            return jsonDecode(response.body);
          }
        } 
        catch (e, stacktrace) {
          LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace: stacktrace.toString(), timestamp: timestamp));
          if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");
          return {"message_code": "500", "message": "Other Exceptions (Login): $e"};
        }
    }
    else {
      return {"message_code": "23", "message": "Connection Lost! Please check your internet connection."};
    }  
  }
  
  Future<Map<String,dynamic>> userSignIn(SignInRequest reqIN) async {
    
    final url = Uri.parse("$authURL/signin");
    await NetworkServiceProvider.checkConnectionStatus();
    if(networkService.isOnline.value) {
      try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqIN.toJson()),
      ).timeout(const Duration(seconds: sec),onTimeout: () {
        return http.Response(
            jsonEncode({"message_code": "29", 'message': 'Request timed out.'}),
            29,
          );
      },);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
        return jsonDecode(response.body);
      }
    } 
    catch (e, stacktrace) {
      LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace: stacktrace.toString(), timestamp: timestamp));
          if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");

          return {"message_code": "500", "message": "Other Exceptions (Login): $e"};
        }
    }
    else {
      return {"message_code": "23", "message": "Connection Lost! Please check your internet connection."};
    }  
  }

  Future<Map<String,dynamic>> resetPassword(ResetPasswordReq reqReset) async{

    final url = Uri.parse("$authURL/reset-mail");
    await NetworkServiceProvider.checkConnectionStatus();
    if(networkService.isOnline.value){
      try {
      final response = await http.post(
        url,
        headers: {"Content-Type" : "application/json"},
        body: jsonEncode(reqReset.toJson())
      )
      .timeout(const Duration(seconds: sec),onTimeout: () {
        return http.Response(
            jsonEncode({"message_code": "29", 'message': 'Request timed out.'}),
            29,
          );
      },)
      ;

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e, stacktrace) {
      LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace: stacktrace.toString(), timestamp: timestamp));
      if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");    
      return {"message_code": "500", "message": "Other Exceptions (Login): $e"};
    }

    }
    else {
      return {"message_code": "23", "message": "Connection Lost! Please check your internet connection."};
    }  
  }



  Future<Map<String,dynamic>> userSignInOtp(OtpSignInReq otpReq) async{
    final url = Uri.parse("$authURL/signin");
    await NetworkServiceProvider.checkConnectionStatus();
    if(networkService.isOnline.value) {
      try{
      final response = await http.post(
        url,
        headers: {"Content-Type" : "application/json"},
        body: jsonEncode(otpReq.toJson())
      ).timeout(const Duration(seconds: sec),onTimeout: () {
        return http.Response(jsonEncode({"message_code": "29", 'message': 'Request timed out.'}),29,);
      },)
      ;
      if(response.statusCode == 200 ) {
        return json.decode(response.body);
      } else {
        if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e, stacktrace) {
      LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace: stacktrace.toString(), timestamp: timestamp));
      if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");
      return {"message_code": "500", "message": "Other Exceptions (Login): $e"};
    }    
    }
    else {
      return {"message_code": "23", "message": "Connection Lost! Please check your internet connection."};
    }  
  }

  Future<Map<String,dynamic>> otpVerify (OtpVerifyReq otpverifyReq) async{
    final url = Uri.parse("$authURL/verify-otp");
    await NetworkServiceProvider.checkConnectionStatus();
    if(networkService.isOnline.value) {
      try{
      final response = await http.post(
        url,
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode(otpverifyReq.toJson())
        ).timeout(const Duration(seconds: sec),onTimeout: () {
        return http.Response(
            jsonEncode({"message_code": "29", 'message': 'Request timed out.'}),
            29, 
          );
      },);
      if(response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e, stacktrace) {
      LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace: stacktrace.toString(), timestamp: timestamp));
      if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");
      return {"message_code": "500", "message": "Other Exceptions (Login): $e"};
    }
    }
    else {
      return {"message_code": "23", "message": "Connection Lost! Please check your internet connection."};
    } 
  }

  Future<Map<String,dynamic>> changeUserName(UserNameReq usernameReq) async{
    final url = Uri.parse('$authURL/update-username');
    await NetworkServiceProvider.checkConnectionStatus();
    
    if(networkService.isOnline.value) {
      try{
      final response = await http.post(
        url,
        headers: {
        'Content-Type' : 'application/json',
        "access_token": GlobalAccess.accessToken},
        body: jsonEncode(usernameReq.toJson())
        ).timeout(const Duration(seconds: sec),onTimeout: () {
        return http.Response(
            jsonEncode({"message_code": "29", 'message': 'Request timed out.'}),
            29, 
          );
      },);
      if(response.statusCode == 200) {
        return json.decode(response.body);
      } 
      else if (response.statusCode == 401) {
        return accesstokenChange(() => changeUserName(usernameReq));
      }
      else {
        if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
        return jsonDecode(response.body);
      } 
    } catch (e, stacktrace) {
      LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace: stacktrace.toString(), timestamp: timestamp));
      if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");
      return {"message_code": "500", "message": "Other Exceptions (Login): $e"};
    }
    }
    else {
      return {"message_code": "23", "message": "Connection Lost! Please check your internet connection."};
    } 
  }

  Future<Map<String,dynamic>> accesstokenChange(Function newtokenReq) async{
    RenewTokenReq renewTokenReq =   RenewTokenReq(userId: GlobalAccess.userID, accessToken: GlobalAccess.accessToken, refreshToken: GlobalAccess.refreshToken);
     final renewResult = await renewToken(renewTokenReq); 
    if (renewResult['status'] == 200) {
      return await newtokenReq();
    } else {
      return {"status": 401, "message":"Unauthorized"};
    }
  }

   Future<bool> xpassAccesstokenChange() async {
    RenewTokenReq renewTokenReq = RenewTokenReq(
        userId: GlobalAccess.userID,
        accessToken: GlobalAccess.accessToken,
        refreshToken: GlobalAccess.refreshToken);
    final renewResult = await ApiService().renewToken(renewTokenReq);
    if (renewResult['status'] != null && renewResult['status'] == 200) {
      return true;
    } else {
      return false;
    }
  }
  
  Future<Map<String,dynamic>> renewToken(RenewTokenReq renewToken ) async{
    final url = Uri.parse("$authURL/generate/renew-token");

    try{
      final response = await http.post(
        url,
        headers: { 'Content-Type' : 'application/json'},
        body: jsonEncode(renewToken.toJson())
      );

      if(response.statusCode == 200) {
        Map<String,dynamic> responseT = json.decode(response.body);
            final String accesstoken = responseT['data']['access_token'];
            await  GlobalAccess.updateAccessToken(accesstoken);
            await  GlobalAccess.updateSecToken();
            return {"status": 200, "message": "Token renewed successfully"};
       }
       else if (response.statusCode == 409){
            return json.decode(response.body);
       }
       else {
        if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
        return jsonDecode(response.body);
      } 
    } catch (e, stacktrace) {
      LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace: stacktrace.toString(), timestamp: timestamp));
      if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");
      return {"message_code": "500", "message": "Other Exceptions (Login): $e"};  
    }
  }
}

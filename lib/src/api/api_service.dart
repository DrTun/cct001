import 'dart:convert';
import '/src/helpers/helpers.dart';
import '/src/models/auth_models.dart';
import 'package:http/http.dart' as http;
import '/src/shared/appconfig.dart';


class ApiService {
  static String authURL = AppConfig.shared.authURL;

  Future<Map<String, dynamic>> userSignUp(SignUpRequest req) async {
    final url = Uri.parse("$authURL/auth/signup");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(req.toJson()),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e, stacktrace) {
      if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");
      return {"status": 500, "message": "Other Exceptions (Login): $e"};
    }
  }
  
  Future<Map<String,dynamic>> userSignIn(SignInRequest reqIN) async {
    
    final url = Uri.parse("$authURL/auth/signin");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqIN.toJson()),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e, stacktrace) {
      if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");
      return {"status": 500, "message": "Other Exceptions (Login): $e"};
    }
  }

  Future<Map<String,dynamic>> resetPassword(ResetPasswordReq reqReset) async{

    final url = Uri.parse("$authURL/auth/reset-password");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type" : "application/json"},
        body: jsonEncode(reqReset.toJson())
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (AppConfig.shared.log>=1) logger.e("Unautorized Access (Login): ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e, stacktrace) {
      if (AppConfig.shared.log>=1) logger.e("Other Exceptions (Login)): $e\n$stacktrace");
      return {"status": 500, "message": "Other Exceptions (Login): $e"};
    }

  }


}

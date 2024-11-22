// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '/src/helpers/helpers.dart';
import '/src/shared/global_data.dart';
import '/src/shared/app_config.dart';
import '/src/api/oidc_auth_service.dart';

class AuthService {
  final OidcAuthService oidcAuthService = OidcAuthService();
  final Dio _dio = Dio();
  late final WebViewCookieManager cookieManager = WebViewCookieManager();
  static String authURL = AppConfig.shared.openIDAuthURL; // config.env
  static String clientID = AppConfig.shared.openIDClientID; // config.env
  static String redirectURL = AppConfig.shared.openIDBaseURL; // config.env
  static String secretKey = AppConfig.shared.secretKey3; // dart define

  static Future<bool> isTokenExpired(String token) async {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  static String readTokens() {
    final accessToken = GlobalAccess.accessToken;
    final refreshToken = GlobalAccess.refreshToken;
    final idToken = GlobalAccess.idToken;
    return 'Access Token : $accessToken\n\nRefresh Token : $refreshToken\n\nID Token : $idToken';
  }

  static Future<Map<String, dynamic>> refreshAccessToken(
      ) async {
    AuthService authService = AuthService();
    final authResponse =
        await authService.refreshAccessTokenWith(GlobalAccess.refreshToken);
    if (authResponse['status'] == 200) {
      GlobalAccess.updateUToken(GlobalAccess.userID, GlobalAccess.userName,
          authResponse['data']['access_token'], GlobalAccess.refreshToken,
          idtoken: authResponse['data']['id_token']);
      GlobalAccess.updateSecToken();
      return {"status": 200};
    }
    else {
      // GlobalAccess.reset();
      // GlobalAccess.resetSecToken();
      return {
        "status" : authResponse['status'],
        "message" : authResponse['message']
      };
    }
  }

  Future<Map<String, dynamic>> refreshAccessTokenWith(
      String refreshToken) async {
    // check refresh token expiry
    try {
      Map<String, dynamic> data = {
        'client_id': clientID,
        'client_secret': secretKey,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'scope': 'openid'
      };
      final response = await _dio.post(
        '$authURL/token',
        // form data
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: data,
      );
      if (response.statusCode == 200) {
        return {"status": response.statusCode, "data": response.data};
      } else {
        if (AppConfig.shared.log >= 1) {
          logger.e("Unauthorized Access (Refresh): ${response.data}");
        }
        return {
          "status": response.statusCode,
          "message": "Unauthorized Access (Refresh)"
        };
      }
    } catch (e, stacktrace) {
      if (AppConfig.shared.log >= 1) {
        logger.e("Other Exceptions (Refresh)): $e\n$stacktrace");
      }
      if (e.toString().contains('No host specified in URI')) {
        return {"status": 400, "message": "Invalid URL"};
      } else if (e is DioException) {
        if (e.response?.statusCode == 400 && e.response != null) {
          if (e.response!.data["error"] == "invalid_grant" &&
              e.response!.data['error_description'] == "Token is not active") {
                // if refresh token is empty -> error_descriptin is Invalid refresh token 
            return {"status": 400, "message": "Token is not active"};
          }
        }
      }
      return {"status": 500, "message": "Other Exceptions (Refresh)"};
    }
  }

  static Future<void> checkRefreshAccessToken() async {
    if (await isTokenExpired(GlobalAccess.accessToken)) {
      // local token checking
      await refreshAccessToken();
    }
  }
}

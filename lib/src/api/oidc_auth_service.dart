import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../helpers/helpers.dart';
import '../shared/app_config.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

//oidc_auth_service
class OidcAuthService {
  final Dio _dio = Dio();
  static String authURL = AppConfig.shared.openIDAuthURL; // config.env
  static String clientID = AppConfig.shared.openIDClientID; // config.env
  static String redirectURL = AppConfig.shared.openIDBaseURL; // config.env
  static String signUpURL = AppConfig.shared.openIDSignUpURL; // config.env
  static String secretKey = AppConfig.shared.secretKey3; // dart define
  static const sec = 30;

  final Uri tokenEndPoint = Uri.parse("$authURL/token");
  final Uri authEndPoint = Uri.parse("$authURL/auth");
  final Uri redirectEndPoint = Uri.parse(redirectURL);
  final Uri signUpEndpoint = Uri.parse(signUpURL);

  oauth2.AuthorizationCodeGrant createAuthorizationCodeGrant() {
    return oauth2.AuthorizationCodeGrant(
      clientID,
      authEndPoint,
      tokenEndPoint,
      secret: secretKey,
    );
  }

  Uri getAuthorizationUrl(oauth2.AuthorizationCodeGrant grant, String type) {
    final authorizationUrl = grant.getAuthorizationUrl(
      redirectEndPoint,
      scopes: ['openid', 'profile', 'email'],
    ); //, 'profile', 'email'
    return Uri.parse('${authorizationUrl.toString()}&kc_idp_hint=$type');
  }

  Future<Map<String, dynamic>> signInKeycloak(
      String userID, String password) async {
    final Map<String, String> data = {
      'username': userID,
      'password': password,
      'client_id': clientID,
      'client_secret': secretKey,
      'grant_type': 'password',
      'scope': 'openid',
    };

    try {
      final response = await http
          .post(
        tokenEndPoint,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: data,
      )
          .timeout(
        const Duration(seconds: sec),
        onTimeout: () {
          return http.Response(
            jsonEncode({'status': 408, 'message': 'Request timed out.'}),
            408,
          );
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          "status": 200,
          "data": {
            "user_id": userID,
            "access_token": responseData['access_token'],
            "refresh_token": responseData['refresh_token'],
            "id_token": responseData['id_token'],
          },
        };
      } else {
        if (AppConfig.shared.log >= 1) {
          logger.e("Unautorized Access (Sign in): ${response.body}");
        }
        return {
          "status": response.statusCode,
          "data": jsonDecode(response.body),
        };
      }
    } catch (e, stacktrace) {
      if (AppConfig.shared.log >= 1) {
        logger.e("Other Exceptions (Sign in)): $e\n$stacktrace");
      }
      if (e.toString().contains('No host specified in URI')) {
        return {"status": 400, "message": "Invalid URL"};
      } else {
        return {"status": 500, "message": "Other Exceptions (Sign in)"};
      }
    }
  }

  Future<Map<String, dynamic>> signUpKeycloak(
    String userName,
    String password,
    String email,
    String firstName,
    String lastName,
  ) async {
    try {
      final tokenResponse = await http.post(
        tokenEndPoint,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientID,
          'client_secret': secretKey,
          'grant_type': 'client_credentials',
        },
      );

      if (tokenResponse.statusCode != 200) {
        return {
          'status': tokenResponse.statusCode,
          'message': 'Failed to obtain token: ${tokenResponse.body}',
        };
      }

      final accessToken = jsonDecode(tokenResponse.body)['access_token'];

      final response = await http
          .post(
        signUpEndpoint,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'credentials': [
            {
              'type': 'password',
              'value': password,
              'temporary': false,
            },
          ],
          'username': userName,
          'enabled': true,
          'email': email,
          'emailVerified': false,
          'firstName': firstName,
          'lastName': lastName,
        }),
      )
          .timeout(
        const Duration(seconds: sec),
        onTimeout: () {
          return http.Response(
            jsonEncode({'status': 408, 'message': 'Request timed out.'}),
            408,
          );
        },
      );

      if (response.statusCode == 201) {
        return {
          'status': 201,
          'message': 'User created successfully',
        };
      }
      if (response.statusCode == 409) {
        return {
          'status': 409,
          'message': 'User already exists.',
        };
      } else {
        if (AppConfig.shared.log >= 1) {
          logger.e("Unautorized Access (Sign up): ${response.body}");
        }
        return jsonDecode(response.body);
      }
    } catch (e, stacktrace) {
      if (AppConfig.shared.log >= 1) {
        logger.e("Other Exceptions (Sign up)): $e\n$stacktrace");
      }
      if (e.toString().contains('No host specified in URI')) {
        return {"status": 400, "message": "Invalid URL"};
      } else {
        return {"status": 500, "message": "Other Exceptions (Sign up)"};
      }
    }
  }

  Future<Map<String, dynamic>> signOutKeycloak(String idToken) async {
    // final idToken = await _secureStorage.read(key: 'id_token') ?? '';
    if (idToken.isNotEmpty) {
      try {
        final response = await _dio.get(
          '$authURL/logout',
          options: Options(
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
          ),
          queryParameters: {
            'client_id': clientID,
            'post_logout_redirect_url': redirectURL,
            'id_token_hint': idToken,
          },
        );
        if (response.statusCode == 200) {
          return {'status': response.statusCode};
        } else {
          if (AppConfig.shared.log >= 1) {
            logger.e("Unauthorized Access (Sign out): $response");
          }
          return {"status": response.statusCode, "message": "Sign out failed"};
        }
      } catch (e, stacktrace) {
        if (AppConfig.shared.log >= 1) {
          logger.e("Other Exceptions (Sign out)): $e\n$stacktrace");
        }
        // return {"status": 500, "message": "Other Exceptions (Login): $e"};
        if (e.toString().contains('No host specified in URI')) {
          return {"status": 400, "message": "Invalid URL"};
        } else {
          return {"status": 500, "message": "Other Exceptions (Sign out)"};
        }
      }
    } else {
      return {"status": 422, "message": "ID token not found"};
    }
  }

  Future<Map<String, dynamic>> forgotPasswordKeycloak(String userId) async {
    try {
      final tokenResponse = await http.post(
        tokenEndPoint,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientID,
          'client_secret': secretKey,
          'grant_type': 'client_credentials',
        },
      ).timeout(const Duration(seconds: sec),onTimeout: () {
        return http.Response(
            jsonEncode({'status': 408, 'message': 'Request timed out.'}),
            408,
          );
      },);

      if (tokenResponse.statusCode != 200) {
        if (AppConfig.shared.log >= 1) {
          logger.e("Forgot Password Token Response : ${tokenResponse.body}");
        }
        return {
          'status': tokenResponse.statusCode,
          'message': 'Failed to obtain access token',
        };
      }

      final accessToken = jsonDecode(tokenResponse.body)['access_token'];

      final findUserResponse = await http.get(
        Uri.parse('$signUpURL?email=$userId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: sec),onTimeout: () {
        return http.Response(
            jsonEncode({'status': 408, 'message': 'Request timed out.'}),
            408,
          );
      },);

      if (findUserResponse.statusCode != 200) {
        if (AppConfig.shared.log >= 1) {
          logger.e("Find User Response : ${findUserResponse.body}");
        }
        return {
          'status': findUserResponse.statusCode,
          'message': 'Failed to find your account',
        };
      }

      final List<dynamic> users = jsonDecode(findUserResponse.body);
      if (users.isEmpty) {
        return {
          'status': 404,
          'message': 'Couldn\'t find your account',
        };
      }

      final String userID = users[0]['id'];

      final resetResponse = await http.put(
        Uri.parse('$signUpURL/$userID/execute-actions-email'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(["UPDATE_PASSWORD"]),
      ).timeout(const Duration(seconds: sec),onTimeout: () {
        return http.Response(
            jsonEncode({'status': 408, 'message': 'Request timed out.'}),
            408,
          );
      },);

      if (resetResponse.statusCode == 204) {
        return {
          'status': 200,
          'message': 'Please check your email',
        };
      } else {
        if (AppConfig.shared.log >= 1) {
          logger.e("Reset Password Response : ${resetResponse.body}");
        }
        return {
          'status': resetResponse.statusCode,
          'message':
              'Failed to send password reset email',
        };
      }
    } catch (e, stacktrace) {
      if (AppConfig.shared.log >= 1) {
          logger.e("Other Exceptions (Forgot password)): $e\n$stacktrace");
        }
        // return {"status": 500, "message": "Other Exceptions (Login): $e"};
        if (e.toString().contains('No host specified in URI')) {
          return {"status": 400, "message": "Invalid URL"};
        } else {
          return {"status": 500, "message": "Other Exceptions (Forgot password)"};
        }
    }
  }

  Future<Map<String, dynamic>> decodeIdToken(String token) async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    int exp = decodedToken['exp'];
    int iat = decodedToken['iat'];
    String jti = decodedToken['jti'];
    String iss = decodedToken['iss'];
    String aud = decodedToken['aud'];
    String sub = decodedToken['sub'];
    String typ = decodedToken['typ'];
    String azp = decodedToken['azp'];
    String sid = decodedToken['sid'];
    String atHash = decodedToken['at_hash'];
    String acr = decodedToken['acr'];
    bool emailVerified = decodedToken['email_verified'];
    String name = decodedToken['name'];
    String preferredUsername = decodedToken['preferred_username'];
    String givenName = decodedToken['given_name'];
    String familyName = decodedToken['family_name'];
    String email = decodedToken['email'];

    return {
      'exp': exp, // Expiry time
      'iat': iat, // Issued at time
      'jti': jti, // JWT ID
      'iss': iss, // Issuer
      'aud': aud, //  Audience
      'userID': sub, // Subject  (user ID)
      'typ': typ, // Token type
      'azp': azp, // Authorized party
      'sid': sid, // Session ID
      'at_hash': atHash, // Access token hash
      'acr': acr, // Authentication context class
      'email_verified': emailVerified, // Whether the email is verified
      'userName': name, // Full name of the user
      'preferred_username': preferredUsername, // Preferred username
      'given_name': givenName, // First name
      'family_name': familyName, // Last name
      'userEmail': email // User email
    };
  }
}

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../api/api_sample_service.dart';
import '../api/auth_service.dart';
import '../api/oidc_auth_service.dart';
import '../helpers/helpers.dart';
import '../utils/check_token_expiry.dart';
import '../shared/app_config.dart';
import '../shared/global_data.dart';

class ViewSSForm01 extends StatefulWidget {
  static const routeName = '/viewssform01';
  const ViewSSForm01({super.key});

  @override
  State<ViewSSForm01> createState() => _ViewSSForm01State();
}

class _ViewSSForm01State extends State<ViewSSForm01> {
  final TextEditingController _dataController = TextEditingController();
  final ApiSampleService apiService = ApiSampleService();
  final AuthService authService = AuthService();
  final WebViewCookieManager cookieManager = WebViewCookieManager();
  bool _isLoading = false;
  final OidcAuthService oidcAuthService = OidcAuthService();
  final Logger logger = Logger();
  String accessTokenExpiryTime = '';
  String refreshTokenExpiryTime = '';

  @override
  void initState() {
    fetchAndDisplayTokenExpiry();
    super.initState();
  }

  Future<void> fetchAndDisplayTokenExpiry() async {
    final accessToken = GlobalAccess.accessToken;
    final refreshToken = GlobalAccess.refreshToken;
    setState(() {
      accessTokenExpiryTime = checkTokenExpiry(accessToken);
      refreshTokenExpiryTime = checkTokenExpiry(refreshToken);
    });
  }

  Future<bool> _signOutKeycloak() async {
    String? idToken = GlobalAccess.idToken;
    final response = await oidcAuthService.signOutKeycloak(idToken ?? '');
    if (response['status'] == 200) {
      try {
        // await authService.deleteTokens();
        await cookieManager.clearCookies();
        GlobalAccess.reset(); // reset global data
        await GlobalAccess
            .resetSecToken(); // reset secure storage with global data
        setState(() {
          AppConfig.signIn(context);
        });
      } catch (e, stacktrace) {
        if (AppConfig.shared.log >= 1) {
          logger.e("Other Exceptions (Sign out)): $e\n$stacktrace");
        }
      }
      return true;
    } else if (response['status'] == 400) {
      MyHelpers.msg(
          message: response['message'] ?? 'Invalid URL',
          backgroundColor: Colors.black);
    } else if (response['status'] == 422) {
      MyHelpers.msg(
          message: response['message'] ?? 'ID token not found',
          backgroundColor: Colors.black);
    } else {
      MyHelpers.msg(
          message: response['message'] ?? 'Other Exceptions (Sign out)',
          backgroundColor: Colors.black);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social/API Gateway Data Testing'),
      ),
      body: Stack(
        children: [
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('The access token lifetime is 2 minutes.'),
              const SizedBox(
                height: 4,
              ),
              const Text('The refresh token lifetime is 15 minutes.'),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 4, bottom: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // await getList();
                      await getCategories();
                    },
                    child: const Text('Data API'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 4, bottom: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _dataController.text = '';
                    },
                    child: const Text('Clear'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 4, bottom: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final response =
                          await AuthService.refreshAccessToken();
                      if (response['status'] == 200) {
                        await fetchAndDisplayTokenExpiry();
                        _dataController.text = AuthService.readTokens();
                      } else if (response['status'] == 400 &&
                          response['message'] == 'Token is not active') {
                        await _signOutKeycloak();
                        MyHelpers.msg(
                            message:
                                "Your session has expired. Please sign in again to continue.",
                            backgroundColor: Colors.black);
                      } else {
                        _dataController.text = response['message'];
                      }
                    },
                    child: const Text('Refresh access token'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 4, bottom: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      GlobalAccess.mode == "Guest"
                          ? {
                              // if guest, quickly go to sigin in
                              GlobalAccess.reset(), // reset global data
                              await GlobalAccess
                                  .resetSecToken(), // reset secure storage with global data
                              setState(() {
                                AppConfig.signIn(context);
                              }),
                            }
                          : {
                              if (await confirm(
                                context,
                                title: const Text('Sign out'),
                                content: Text(
                                    'Would you like to sign out ${GlobalAccess.userName}?'),
                                textOK: const Text('Yes'),
                                textCancel: const Text('No'),
                              ))
                                {
                                  if (AppConfig.shared.signinType == 3)
                                    {
                                      await _signOutKeycloak(),
                                    }
                                  else
                                    {
                                      GlobalAccess.reset(), // reset global data
                                      await GlobalAccess
                                          .resetSecToken(), // reset secure storage with global data
                                      setState(() {
                                        AppConfig.signIn(context);
                                      })
                                    }
                                }
                            };
                    },
                    child: Text(
                      '${GlobalAccess.mode == "Guest" ? "Sign In" : "Sign Out"} ',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _dataController,
                  readOnly: true,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    'Access Token Expiry DateTime: $accessTokenExpiryTime',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Refresh Token Expiry DateTime: $refreshTokenExpiryTime',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> getCategories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> userListResponse = await apiService.getCategories();

      if (userListResponse['status'] == 200 ||
          userListResponse['status'] == 201) {
        String usersName = userListResponse['data']
            .map((data) => data['name'].toString())
            .join('\n');
        _dataController.text =
            "Status Code is : ${userListResponse['status']}\n$usersName";
      } else if (userListResponse['status'] == 400) {
        MyHelpers.msg(
            message: userListResponse['message'] ?? 'Invalid URL',
            backgroundColor: Colors.black);
      } else if (userListResponse['status'] == 500) {
        MyHelpers.msg(message: "Connectivity [50x]");
      } else {
        MyHelpers.msg(
            message: "List retrieval error: ${userListResponse['message']}",
            backgroundColor: Colors.black);
      }
    } catch (e, stacktrace) {
      if (AppConfig.shared.log >= 1) {
        logger.e("Connectivity #50xx (Data List): $e\n$stacktrace");
      }
      MyHelpers.msg(message: "Connectivity [50xx]");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

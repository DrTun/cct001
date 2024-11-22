// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '/src/helpers/helpers.dart';
import '/src/root_page.dart';
import '/src/shared/app_config.dart';
import '/src/shared/global_data.dart';
import '/src/api/oidc_auth_service.dart';
import '/src/utils/responsive_utils.dart';
import '/src/widgets/sign_in_button.dart';
import '/src/signin/openid/signin_keycloak.dart';
import '/src/signin/openid/webview_social.dart';

class SignInSocial extends StatefulWidget {
  static const routeName = '/signinsocial';
  const SignInSocial({super.key});

  @override
  State<SignInSocial> createState() => _SignInSocialState();
}

class _SignInSocialState extends State<SignInSocial> {
  final OidcAuthService _oidcAuthService = OidcAuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsivePadding(constraints)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(_errorMessage!,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      SignInButton(
                        text: 'User ID',
                        type: 'keycloak',
                        assetName: 'images/social/user_id.png',
                        onPressed:
                            _isLoading ? null : () => _signInWith('keycloak'),
                        constraints: constraints,
                      ),
                      SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                              constraints)),
                      SignInButton(
                        text: 'Google',
                        type: 'google',
                        assetName: 'images/social/google_logo.png',
                        onPressed:
                            _isLoading ? null : () => _signInWith('google'),
                        constraints: constraints,
                      ),
                      SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                              constraints)),
                      SignInButton(
                        text: 'Facebook',
                        type: 'facebook',
                        assetName: 'images/social/facebook_logo.png',
                        enabled: false,
                        onPressed:
                            _isLoading ? null : () => _signInWith('facebook'),
                        constraints: constraints,
                      ),
                      SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                              constraints)),
                      SignInButton(
                        text: 'Apple',
                        type: 'apple',
                        assetName: 'images/social/apple_logo.png',
                        enabled: false,
                        onPressed: null,
                        constraints: constraints,
                      ),
                      SizedBox(
                          height: ResponsiveUtils.getResponsiveButtonHeight(
                              constraints)),
                      TextButton(
                        onPressed: _performSkip,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(constraints),
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 106, 193),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _performSkip() async {
    if (AppConfig.shared.log >= 3) logger.i('Skip login');
    GlobalAccess.reset();
    GlobalAccess.updateGToken("");
    Navigator.pushReplacementNamed(context, RootPage.routeName);
  }


  Future<void> _signInWith(String type) async {
    if (type == 'keycloak') {
      Navigator.pushNamed(context, SignInKeycloak.routeName);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Create the OAuth2 client and authorization URL
  /// get the token, save the token, and update the global data.
  ///
  /// Finally, navigate to [RootPage].
        final grant = _oidcAuthService.createAuthorizationCodeGrant();
        final authorizationUrl =
            _oidcAuthService.getAuthorizationUrl(grant, type);

        // Navigate to WebViewScreen and get the result (the redirected URL)
        final responseUrl = await Navigator.push<Uri>(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WebviewSocial(authorizationUrl: authorizationUrl),
          ),
        );

        // Check if responseUrl is null (user cancelled or failed)
        if (responseUrl == null) {
          setState(() {
            _errorMessage =
                ''; // need to be consider for error message & exception later
          });

          return;
        }

        final httpClient = await grant.handleAuthorizationResponse(
            responseUrl.queryParameters); //if success then get the token

        final accessToken = httpClient.credentials.accessToken;
        final refreshToken = httpClient.credentials.refreshToken ?? '';
        final idToken = httpClient.credentials.idToken ?? '';
        // await _authService.saveTokens(accessToken, refreshToken, idToken);
        final Map<String, dynamic> idTokenData =
            await _oidcAuthService.decodeIdToken(idToken);
        String userName =
            "${idTokenData['given_name']} ${idTokenData['family_name']}";
        String userID = idTokenData['preferred_username'];
        GlobalAccess.updateUToken(userID, userName, accessToken, refreshToken,idtoken: idToken);
        GlobalAccess.updateSecToken();
        MyStore.storeSignInDetails(AppConfig.shared.signinType, DateTime.now());

        //Navigator.pushNamed(context, SsForm02.routeName);
        if (mounted) {
          Navigator.pushReplacementNamed(context, RootPage.routeName);
        } //if context is still valid
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage =
                ''; // need to be consider for error message & exception later
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}

import 'package:flutter/material.dart';
import '/src/shared/global_data.dart';
import '/src/shared/app_config.dart';
import '/src/api/auth_service.dart';
import '/src/api/oidc_auth_service.dart';
import '/src/helpers/helpers.dart';
import '/src/root_page.dart';
import '/src/widgets/default_button.dart';
import '/src/widgets/user_input_form_field.dart';
import '/src/signin/openid/forgot_password_keycloak.dart';
import '/src/signin/openid/signup_keycloak.dart';

class SignInKeycloak extends StatefulWidget {
  static const routeName = '/signinkeycloak';
  const SignInKeycloak({super.key});

  @override
  State<SignInKeycloak> createState() => _SignInKeycloakState();
}

class _SignInKeycloakState extends State<SignInKeycloak> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _useridController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loadingTime = false;
  final OidcAuthService _oidcAuthService = OidcAuthService();
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: height * 0.12,
                    ),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: const Image(
                          image: AssetImage("assets/images/logo.png"),
                          width: 110,
                          height: 110,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.05,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'User ID',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        UserInputFormField(
                          obscureText: false,
                          controller: _useridController,
                          validateKey: 'singinUserid',
                          hintText: 'Email',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Password',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        UserInputFormField(
                          obscureText: true,
                          controller: _passwordController,
                          validateKey: 'singinpw',
                          hintText: 'Password',
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      ForgotPasswordKeycloak.routeName);
                                  // ToastUtil.showToastMsg(
                                  //     'Feature not available.');
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 106, 193),
                                      fontWeight: FontWeight.bold),
                                ))),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: height * 0.137,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?  "),
                            InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, SignupKeycloak.routeName);
                                  // ToastUtil.showToastMsg(
                                  //     'Feature not available.');
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 106, 193),
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                        SizedBox(height: height * 0.03),
                        DefaultButton(
                          text: 'Sign In',
                          onTap: () {
                            setState(() {
                              loadingTime
                                  ? null
                                  : _formKey.currentState!.validate()
                                      ? {
                                          loadingTime = true,
                                          signIn(),
                                        }
                                      : null;
                            });
                          },
                          loading: loadingTime,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  signIn() async {
    String userid = _useridController.text;
    String password = _passwordController.text;
    final response = await _oidcAuthService.signInKeycloak(userid, password);
    if (response['status'] == 200) {
      final String msg = response['message'] ?? 'Signed in successfully';
      MyHelpers.msg(message: msg, backgroundColor: Colors.green);
      final String accessToken = response['data']['access_token'];
      final String refreshToken = response['data']['refresh_token'];
      final String idToken = response['data']['id_token'];
      final Map<String, dynamic> idTokenData =
          await _oidcAuthService.decodeIdToken(idToken);
      String userName =
          "${idTokenData['given_name']} ${idTokenData['family_name']}";
      // await authService.saveTokens(accessToken, refreshToken, idToken);
      GlobalAccess.updateUToken(
          response['data']['user_id'], userName, accessToken, refreshToken,
          idtoken: idToken);
      GlobalAccess.updateSecToken();
      MyStore.storeSignInDetails(
          AppConfig.shared.signinType, DateTime.now());
      setState(() {
        Navigator.pushReplacementNamed(context, RootPage.routeName);
        _useridController.clear();
        _passwordController.clear();
      });
    } else if (response['status'] == 408) {
      MyHelpers.msg(
          message: response['message'] ?? 'Request time out.',
          backgroundColor: Colors.black);
    } else {
      MyHelpers.msg(
          message: response['message'] ?? 'Invalid User ID or Password',
          backgroundColor: Colors.black);
    }
    setState(() {
      loadingTime = false;
    });
  }
}

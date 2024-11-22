import 'package:flutter/material.dart';
import '/src/api/oidc_auth_service.dart';
import '/src/helpers/helpers.dart';
import '/src/widgets/default_button.dart';
import '/src/widgets/user_input_form_field.dart';
import '/src/signin/openid/signin_keycloak.dart';

class ForgotPasswordKeycloak extends StatefulWidget {
  static const routeName = '/forgotpasswordkeycloak';
  const ForgotPasswordKeycloak({super.key});

  @override
  State<ForgotPasswordKeycloak> createState() => _ForgotPasswordKeycloakState();
}

class _ForgotPasswordKeycloakState extends State<ForgotPasswordKeycloak> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final OidcAuthService oidcAuthService = OidcAuthService();

  final _useridController = TextEditingController();
  bool loadingtime = false;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom == 0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot password'),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.1,
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
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    'User ID',
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Form(
                    key: _formKey,
                    child: SizedBox(
                      height: 60,
                      child: UserInputFormField(
                        obscureText: false,
                        controller: _useridController,
                        validateKey: 'singinUserid',
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      DefaultButton(
                        text: 'Reset Password',
                        onTap: () {
                          _formKey.currentState!.validate()
                              ? {
                                  setState(() {
                                    loadingtime = true;
                                    resetPassword();
                                  })
                                }
                              : null;
                        },
                        loading: loadingtime,
                      ),
                      isKeyboardVisible
                          ? SizedBox(
                              height: height * 0.2,
                            )
                          : const SizedBox()
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  resetPassword() async {
    String userId = _useridController.text;
    final response = await oidcAuthService.forgotPasswordKeycloak(userId);
    if (response['status'] == 200) {
      final String msg = response['message'] ?? 'Please check your email';
      MyHelpers.msg(message: msg, backgroundColor: Colors.green);
      setState(() {
        Navigator.pushReplacementNamed(context, SignInKeycloak.routeName);
      });
    } else if (response['status'] == 408) {
      MyHelpers.msg(
          message: response['message'] ?? 'Request time out.',
          backgroundColor: Colors.black);
    } else {
      MyHelpers.msg(
          message: response['message'] ?? 'Invalid',
          backgroundColor: Colors.black);
    }
    setState(() {
      loadingtime = false;
    });
  }
}

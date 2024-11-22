import 'package:flutter/material.dart';
import '/src/signin/openid/signin_keycloak.dart';
import 'package:logger/logger.dart';
import '/src/api/oidc_auth_service.dart';
import '/src/helpers/helpers.dart';
import '/src/widgets/default_button.dart';
import '/src/widgets/user_input_form_field.dart';

class SignupKeycloak extends StatefulWidget {
  static const routeName = '/signupkeycloak';

  const SignupKeycloak({super.key});

  @override
  State<SignupKeycloak> createState() => _SignupKeycloakState();
}

class _SignupKeycloakState extends State<SignupKeycloak> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _useridController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userFirstNameController = TextEditingController();
  final _userLastNameController = TextEditingController();
  final logger = Logger();
  final OidcAuthService _oidcAuthService = OidcAuthService();
  bool isPwdMatched = false;
  bool loadingtime = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom == 0;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign up'),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Column(
                      children: [
                        isKeyboardVisible
                            ? SizedBox(
                                height: height * 0.08,
                              )
                            : const SizedBox(
                                height: 15,
                              ),
                        isKeyboardVisible
                            ? Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: const Image(
                                    image: AssetImage("assets/images/logo.png"),
                                    width: 110,
                                    height: 110,
                                  ),
                                ),
                              )
                            : Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: const Image(
                                    image: AssetImage("assets/images/logo.png"),
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              validateKey: 'Userid',
                              hintText: 'Email',
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'First Name',
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            UserInputFormField(
                              obscureText: false,
                              controller: _userFirstNameController,
                              validateKey: 'signupfirstname',
                              hintText: 'First Name',
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Last Name',
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            UserInputFormField(
                              obscureText: false,
                              controller: _userLastNameController,
                              validateKey: 'signuplastname',
                              hintText: 'Last Name',
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
                              validateKey: 'Password',
                              hintText: 'Password',
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            const Text(
                              'Confirm Password',
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            // UserInputFormField(obscureText: true,controller: _confirmPasswordController,validateKey:  _passwordController.text == _confirmPasswordController.text?'confirm': 'unconfirm',hintText: 'Confirm Password',
                            // ),
                            UserInputFormField(
                              obscureText: true,
                              controller: _confirmPasswordController,
                              validateKey: 'unconfirm',
                              hintText: 'Confirm Password',
                              validation: _checkPasswordMatch,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("You already have an account?  "),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, SignInKeycloak.routeName);
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 106, 193),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height * 0.025,
                        ),
                        DefaultButton(
                          text: 'Sign Up',
                          onTap: () async {
                            {
                              setState(() {
                                loadingtime
                                    ? null
                                    : _formKey.currentState!.validate()
                                        ? {
                                            loadingtime = true,
                                            signup(),
                                          }
                                        : null;
                              });
                            }
                          },
                          loading: loadingtime,
                        )
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

  String _checkPasswordMatch() {
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text) {
      return 'confirm';
    }
    return 'unconfirm';
  }

  signup() async {
    final email = _useridController.text;
    final firstName = _userFirstNameController.text;
    final lastName = _userLastNameController.text;
    final password = _passwordController.text;
    final response = await _oidcAuthService.signUpKeycloak(
        email, password, email, firstName, lastName);
    if (response['status'] == 201) {
      final String msg = response['message'] ?? 'User created successfully';
      MyHelpers.msg(message: msg, backgroundColor: Colors.green);
      setState(() {
        _useridController.clear();
        _userFirstNameController.clear();
        _userLastNameController.clear();
        _passwordController.clear();
        Navigator.pushNamedAndRemoveUntil(
          context,
          SignInKeycloak.routeName,
          (route) => false,
        );
      });
    } else if (response['status'] == 408) {
      MyHelpers.msg(
          message: response['message'] ?? 'Request time out.',
          backgroundColor: Colors.black);
    } else if (response['status'] == 409) {
      MyHelpers.msg(
          message: response['message'] ?? 'Registration Failed',
          backgroundColor: Colors.black);
    } else {
      MyHelpers.msg(
          message: response['message'] ?? 'Registration Failed',
          backgroundColor: Colors.black);
    }

    setState(() {
      loadingtime = false;
    });
  }
}

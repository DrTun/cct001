import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/src/api/api_service.dart';
import '/src/models/auth_models.dart';
import '/src/api/token.dart';
import '/src/rootpage.dart';
import '/src/shared/appconfig.dart';
import '/src/shared/globaldata.dart';
import '/src/signin/forgotpassword.dart';
import '/src/signin/signup.dart';
import '/src/widgets/signinbutton.dart';
import '/src/widgets/userinputformfield.dart';

class SignIn extends StatefulWidget {
  static const routeName = '/signIn';
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _useridController = TextEditingController();
  final _passwordController = TextEditingController();

  bool loadingTime = false;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom == 0;
    return SafeArea(
      child: Scaffold(
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'User ID',
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        MyTextField(
                          obscureText: false,
                          controller: _useridController,
                          validateKey: 'Userid',
                          hintText: 'Email',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        MyTextField(
                          obscureText: true,
                          controller: _passwordController,
                          validateKey: 'Password',
                          hintText: 'Password',
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, ForgotPassword.routeName);
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 106, 193),
                                      fontWeight: FontWeight.bold),
                                ))),
                      ],
                    ),
                    isKeyboardVisible
                        ? Column(
                            children: [
                              SizedBox(
                                height: height * 0.2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account?  "),
                                  InkWell(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                            context, SignupPage.routeName);
                                      },
                                      child: const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 0, 106, 193),
                                            fontWeight: FontWeight.bold),
                                      ))
                                ],
                              ),
                              SizedBox(
                                height: height * 0.03,
                              ),
                              loadingTime
                                  ? SpinKitCircle(
                                      duration: const Duration(seconds: 2),
                                      color: Colors.blue[300],
                                      size: 40.0,
                                    )
                                  : MyButton(
                                      text: 'Sign In',
                                      onTap: () {
                                        setState(() {
                                          _formKey.currentState!.validate()
                                              ? {
                                                  loadingTime = true,
                                                  signIn(),
                                                }
                                              : null;
                                        });
                                      }),
                            ],
                          )
                        : const SizedBox()
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
    List<int> bytes = utf8.encode(password);
    String base64password = base64Encode(bytes);
    String uuId = await Token().getDeviceUUID();
    DateTime time = DateTime.now();
    String sToken = await Token().createSToken(time, '2');
    String userName = '';
    SignInRequest reqIN = SignInRequest(
        userId: userid,
        password: base64password,
        sToken: sToken,
        appId: AppConfig.shared.appID,
        uuId: uuId,
        dateTime: time.toIso8601String(),
        reqType: 2);
    final response = await ApiService().userSignIn(reqIN);

    if (response['status'] == 200) {

      final String msg = response['message'] ?? 'Signed in successfully';
      Fluttertoast.showToast(msg: msg);
      GlobalAccess.updateUToken(userid, userName,
          response['data']['access_token'], response['data']['refresh_token']);
      setState(() {
        Navigator.pushReplacementNamed(context, RootPage.routeName);
        _useridController.clear();
        _passwordController.clear();
      });
    } else {
      Fluttertoast.showToast(msg: response['message']??'Invalid User ID or Password');
    }
    setState(() {
      loadingTime = false;
    });
  }
}

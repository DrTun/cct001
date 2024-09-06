import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/src/api/api_service.dart';
import '/src/models/auth_models.dart';
import '/src/helpers/token.dart';
import '/src/rootpage.dart';
import '/src/shared/appconfig.dart';
import '/src/shared/globaldata.dart';
import '/src/signin/forgot_password.dart';
import '/src/signin/sign_up.dart';
import '/src/widgets/signin_button.dart';
import '/src/widgets/text_form.dart';

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
                      height: height * 0.15,
                    ),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: const Image(
                          image: AssetImage("assets/images/logo.png"),
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: height * 0.42,
                      child: Column(
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
                            controller:  _useridController,
                            validateKey: 'Userid',
                            hintText: 'Email',
                          ),
                          const SizedBox(
                            height: 15,
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
                          const SizedBox(
                            height: 5,
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
                    ),
                    SizedBox(
                      height: height * 0.05,
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
                                  color: Color.fromARGB(255, 0, 106, 193),
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: loadingTime
                            ? SizedBox(
                                height: 50,
                                child: SpinKitCircle(
                                  duration: const Duration(seconds: 2),
                                  color: Colors.blue[300],
                                  size: 40.0,
                                ))
                            : MyButton(
                                text: 'Sign In',
                                onTap: () {
                                  _formKey.currentState!.validate()
                                      ? {
                                          setState(() {
                                            loadingTime = true;
                                          }),
                                          signIn(),
                                        }
                                      : null;
                                })),
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
      Fluttertoast.showToast(msg: response['message']);
      GlobalAccess.updateUToken(userid,userName,response['data']['access_token'],response['data']['refresh_token']);
      setState(() {
        Navigator.pushReplacementNamed(context, RootPage.routeName);
        _useridController.clear();
        _passwordController.clear();
      });
    } else {
      Fluttertoast.showToast(msg: response['message']);
    }
    setState(() {
      loadingTime = false;
    });
  }
}
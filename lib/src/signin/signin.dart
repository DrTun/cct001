import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/token.dart';
import '../helpers/helpers.dart';
import '../models/auth_models.dart';
import '../rootpage.dart';
import '../shared/appconfig.dart';
import '../shared/globaldata.dart';
import '../widgets/defaultbutton.dart';
import '../widgets/userinputformfield.dart';
import 'forgotpassword.dart';
import 'signup.dart';



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
                    SizedBox(height: height * 0.12,),
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
                    SizedBox(height: height * 0.05,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('User ID',),
                        const SizedBox(height: 5,),
                        MyTextField(obscureText: false,controller: _useridController,validateKey: 'Userid',hintText: 'Email',),
                        const SizedBox(height: 10,),
                        const Text('Password',),
                        const SizedBox(height: 5,),
                        MyTextField(obscureText: true,controller: _passwordController,validateKey: 'Password',hintText: 'Password',),
                        Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, ForgotPassword.routeName);
                                },
                                child: const Text('Forgot Password?',style: TextStyle(color: Color.fromARGB(255, 0, 106, 193),fontWeight: FontWeight.bold),)
                              )),
                      ],
                    ),
                    Column(
                            children: [
                               
                              SizedBox(height: height * 0.137,),
                              TextButton( onPressed: _performSkip,child: const Text('Skip', style: TextStyle( color:  Color.fromARGB(255, 0, 106, 193))),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account?  "),
                                  InkWell(
                                      onTap: () {Navigator.pushReplacementNamed(context, SignupPage.routeName);},
                                      child: const Text('Sign Up',style: TextStyle(color: Color.fromARGB(255, 0, 106, 193),fontWeight: FontWeight.bold),)
                                    )
                                ],
                              ),
                              SizedBox(height: height * 0.03),
                               MyButton(
                                      text: 'Sign In',
                                      onTap: () {
                                        setState(() {
                                          loadingTime? null:
                                          _formKey.currentState!.validate()
                                              ? { 
                                                  loadingTime = true,
                                                  signIn(),
                                                }
                                              : null;
                                        });
                                      }, loading: loadingTime,
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

  Future<void> _performSkip() async {
    if (AppConfig.shared.log>=3) logger.i('Skip login');
    GlobalAccess.reset();
    GlobalAccess.updateGToken(""); 
    Navigator.pushReplacementNamed(context, RootPage.routeName);
  }

  signIn() async {
    String userid = _useridController.text;
    String password = _passwordController.text;
    List<int> bytes = utf8.encode(password);
    String base64password = base64Encode(bytes);
    String uuId = await Token().getDeviceUUID();
    DateTime time = DateTime.now();
    String sToken = await Token().createSToken(time, '2');
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
      MyHelpers.msg(message: msg,backgroundColor: Colors.green);
      GlobalAccess.updateUToken(response['data']['user_id'], response['data']['user_name'],
          response['data']['access_token'], response['data']['refresh_token']);
      GlobalAccess.updateSecToken();
      setState(() {
        Navigator.pushReplacementNamed(context, RootPage.routeName);
        _useridController.clear();
        _passwordController.clear();
      });
    } else {
    MyHelpers.msg(message: response['message']??'Invalid User ID or Password',backgroundColor: Colors.black);
    }
    setState(() {
      loadingTime = false;
    });
  }
}
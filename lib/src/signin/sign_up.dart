import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/src/api/api_service.dart';
import '/src/models/auth_models.dart';
import '/src/helpers/token.dart';
import '/src/shared/appconfig.dart';
import '/src/signin/sign_in.dart';
import 'package:logger/logger.dart';
import '../widgets/signin_button.dart';
import '../widgets/text_form.dart';

class SignupPage extends StatefulWidget {
  static const routeName = '/signupPage';

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final  _useridController = TextEditingController();
  final  _passwordController = TextEditingController();
  final  _userNameController = TextEditingController();
  final logger = Logger();

  bool loadingtime = false;

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
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          height: height*0.45,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('User Name', ),
                              const SizedBox(height: 5,),
                        MyTextField(
                          obscureText: false,
                          controller: _userNameController,
                          validateKey: 'Username', hintText: 'User Name',
                        ),
                        const SizedBox(height: 15,),
                        const Text('User ID',),
                        const SizedBox(height: 5,),
                        MyTextField(
                            obscureText: false,
                            controller: _useridController,
                            validateKey: 'Userid', hintText: 'Email',),
                        const SizedBox(height: 15,),
                        const Text('Password',),
                        const SizedBox(height: 5,),
                        MyTextField(
                          obscureText: true,
                          controller: _passwordController,
                          validateKey: 'Password', hintText: 'Password',
                        ),
                            ],
                          ),
                        ),
                        
          
                      ],
                    ),
                    SizedBox(height: height * 0.02,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("You already have an account?  "),
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                SignIn.routeName,
                              );
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
                    const SizedBox(height: 20,),
                    loadingtime
                        ? SizedBox(
                            height: 50,
                            child: SpinKitCircle(
                              duration: const Duration(seconds: 2),
                              color: Colors.blue[300],
                              size: 40.0,
                            ))
                        : MyButton(
                            text: 'Sign Up',
                            onTap: () async {
                            //  passwordCheck(_passwordController.text);
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  loadingtime = true;
                                });
                                await signup(context);
                              }
                            })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  signup(BuildContext context,) async {
    final email = _useridController.text;
    final name = _userNameController.text;
    final password = _passwordController.text;
    List<int> bytes = utf8.encode(password);
    String base64password = base64Encode(bytes);
    String uuid = await Token().getDeviceUUID();
    DateTime time = DateTime.now();
    String sToken = await Token().createSToken(time,'1');
    SignUpRequest req = SignUpRequest(
      userId: email,
      password: base64password,
      sToken: sToken,
      userName: name,
      appId: AppConfig.shared.appID,
      uuId: uuid,
      dateTime: time.toIso8601String(),
      reqType: 1,
    );
    final response = await ApiService().userSignUp(req);

    if (response['status'] == 200) {
      Fluttertoast.showToast(msg: response['message']);
      setState(() {
        _useridController.clear();
        _userNameController.clear();
        _passwordController.clear();
        Navigator.pushReplacementNamed(context, SignIn.routeName);
      });
    } else {
      Fluttertoast.showToast(msg: response['message']);
    }
    setState(() {
      loadingtime = false;
    });
  }

}

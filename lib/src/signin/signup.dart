import 'dart:convert';

import 'package:flutter/material.dart';
import '/src/helpers/helpers.dart';
import 'package:logger/logger.dart';
import '../api/api_service.dart';
import '../api/token.dart';
import '../models/auth_models.dart';
import '../shared/appconfig.dart';
import '../widgets/defaultbutton.dart';
import '../widgets/userinputformfield.dart';
import 'signin.dart';

class SignupPage extends StatefulWidget {
  static const routeName = '/signupPage';

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _useridController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();
  final logger = Logger();

  bool loadingtime = false;

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
                  children: [
                    Column(
                      children: [
                        isKeyboardVisible? SizedBox(height: height * 0.12,) : const SizedBox(height: 15,),
                        isKeyboardVisible
                        ?Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child:  const Image(
                              image: AssetImage("assets/images/logo.png"),
                              width:  110,
                              height: 110,
                            ),
                          ),
                        )
                        :Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child:  const Image(
                              image: AssetImage("assets/images/logo.png"),
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),

                        SizedBox(height: height*0.03,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('User ID',),
                            const SizedBox(height: 5,),
                            MyTextField(obscureText: false,controller: _useridController,validateKey: 'Userid',hintText: 'Email',),
                            const SizedBox(height: 10,),

                            const Text('User Name',),
                            const SizedBox(height: 5,),
                            MyTextField(obscureText: false,controller: _userNameController,validateKey: 'Username',hintText: 'User Name',),
                            const SizedBox(height: 10,),

                            const Text('Password',),
                            const SizedBox(height: 5,),
                            MyTextField(obscureText: true,controller: _passwordController,validateKey: 'Password',hintText: 'Password',),
                            const SizedBox(height: 10,),

                            const Text('Confirm Password',),
                            const SizedBox(height: 5,),
                            MyTextField(obscureText: true,controller: _confirmPasswordController,validateKey:  _passwordController.text == _confirmPasswordController.text?'confirm': 'unconfirm',hintText: 'Confirm Password',
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: height * 0.02,),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("You already have an account?  "),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(context,SignIn.routeName);
                            },
                            child: const Text('Sign In',style: TextStyle(color: Color.fromARGB(255, 0, 106, 193),fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                    SizedBox(height: height*0.025,),
                        MyButton(
                            text: 'Sign Up',
                            onTap: () async { 
                              {
                                setState(() {
                                  loadingtime
                                  ? null
                                  :_formKey.currentState!.validate()
                                  ? { 
                                    loadingtime = true,
                                    signup(context),}
                                  : null;
                              });
                            }
                        }, loading: loadingtime,)
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

  signup(BuildContext context) async {
    final email = _useridController.text;
    final name = _userNameController.text;
    final password = _passwordController.text;
    List<int> bytes = utf8.encode(password);
    String base64password = base64Encode(bytes);
    String uuid = await Token().getDeviceUUID();
    DateTime time = DateTime.now();
    String sToken = await Token().createSToken(time, '1');
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
      final String msg = response['message'] ?? 'Please check your email';
    //  MyHelpers.msg(msg,sec: 3,bcolor: Colors.green);
      MyHelpers.msg(message: msg , backgroundColor: Colors.green);
      setState(() {
        _useridController.clear();
        _userNameController.clear();
        _passwordController.clear();
        Navigator.pushReplacementNamed(context, SignIn.routeName);
      });
    } 
     else {
      MyHelpers.msg(message: response['message']??'Registration Failed' , backgroundColor: Colors.black );     
    }
    
    setState(() {
      loadingtime = false;
    });
  }

  
}

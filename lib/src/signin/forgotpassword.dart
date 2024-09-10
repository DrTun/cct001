import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/token.dart';
import '../helpers/helpers.dart';
import '../models/auth_models.dart';
import '../shared/appconfig.dart';
import '../widgets/defaultbutton.dart';
import '../widgets/userinputformfield.dart';
import 'signin.dart';



class ForgotPassword extends StatefulWidget {
  static const routeName = '/forgotPassword';
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _useridController = TextEditingController();
  bool loadingtime = false;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom == 0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {Navigator.pushReplacementNamed(context, SignIn.routeName);}, 
            icon: const Icon(Icons.arrow_back_sharp)
            ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  SizedBox(height: height * 0.1,),
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
                  const SizedBox(height: 40,),
                  const Text('User ID',),
                  const SizedBox(height: 5,),
                  Form(
                    key: _formKey,
                    child: SizedBox(
                      height: 60,
                      child: MyTextField(obscureText: false,controller: _useridController,validateKey: 'Userid',hintText: 'Email',),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      
                          MyButton(
                            text: 'Reset Password', 
                            onTap: (){
                              _formKey.currentState!.validate()
                                          ? {
                                              setState(() {
                                                loadingtime = true;
                                                resetPassword();
                                              })
                                            }
                                          : null;
                            }, loading: loadingtime,),
                          isKeyboardVisible?  SizedBox(height: height * 0.2,) : const SizedBox()
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
    String uuId = await Token().getDeviceUUID();
    DateTime time = DateTime.now();
    String sToken = await Token().createSToken(time, '3');
    ResetPasswordReq reqReset = ResetPasswordReq(
        userId: userId,
        sToken: sToken,
        appId: AppConfig.shared.appID,
        uuId: uuId,
        dateTime: time.toIso8601String(),
        reqType: 3);
    final response = await ApiService().resetPassword(reqReset);
    if (response['status'] == 200) {
      final String msg = response['message'] ?? 'Please check your email';
    MyHelpers.msg(message: msg, backgroundColor: Colors.green);
      setState(() {      
        Navigator.pushReplacementNamed(context, SignIn.routeName);
      });  
    } else {
    MyHelpers.msg(message: response['message']??'Invalid User ID or Password',backgroundColor: Colors.black);
    }
    setState(() {
      loadingtime = false;
    });
  }
}

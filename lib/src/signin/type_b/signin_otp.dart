import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../api/token.dart';
import '../../helpers/helpers.dart';
import '../../root_page.dart';
import '../../shared/app_config.dart';
import '../../shared/global_data.dart';
import '../../widgets/default_button.dart';
import '../../widgets/user_input_form_field.dart';
import '../models/auth_models.dart';
import 'verify_otp.dart';

class SignInotp extends StatefulWidget {
  static const routename = '/signinotp';
  const SignInotp({super.key});

  @override
  State<SignInotp> createState() => _SignInotpState();
}

class _SignInotpState extends State<SignInotp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _useridController = TextEditingController();
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
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                isKeyboardVisible?  SizedBox(height: height * 0.17,) : SizedBox(height: height *0.07,),
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
                      child: UserInputFormField(obscureText: false,controller: _useridController,
                      validateKey:'Useridmobile',hintText: 'Mobile Number or Email',),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Column(
                    children: [
                          DefaultButton(
                            text: 'Sign In', 
                            onTap: () async{
                                
                               setState(() {
                                loadingtime? null:
                                _formKey.currentState!.validate()
                                ? { 
                                    FocusScope.of(context).unfocus(),
                                    loadingtime = true,
                                    signIn(),
                                    }
                                : null;
                                        });
                            }, loading: loadingtime,),
                          isKeyboardVisible?  SizedBox(height: height * 0.2,) : const SizedBox(height: 5,)
                    ],
                  ),
                  SizedBox(height: height*0.01,),
                  AppConfig.shared.allowGuest
                  ?
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextButton( onPressed: _performSkip,child: const Text('Skip', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color:  Color.fromARGB(255, 0, 106, 193),decoration: TextDecoration.underline, decorationColor:  Color.fromARGB(255, 0, 106, 193))),))
                  : const SizedBox()
                ],
              ),
            ),
          ),
        ),
      ),
    );  
  }

  Future<void> _performSkip() async {
    FocusScope.of(context).unfocus();
    if (AppConfig.shared.log>=3) logger.i('Skip signin');
    GlobalAccess.reset();
    GlobalAccess.updateGToken(""); 
    Navigator.pushReplacementNamed(context, RootPage.routeName);
  }

  signIn() async {
    String userId = _useridController.text.trim();
    String uuId =  MyStore.prefs.getString('uuid') ?? await Token().getDeviceUUID();
    DateTime time = DateTime.now();
    String sToken = await Token().createSToken(time, '2');
    OtpSignInReq otpReq = OtpSignInReq(
        userId: userId,
        sToken: sToken,
        appId: AppConfig.shared.appID,
        uuId: uuId,
        dateTime: time.toIso8601String(),
        reqType: 2);
    final response = await ApiService().userSignInOtp(otpReq);
    if (response['status'] == 200) {
      final String session = response['data']['session_id'];
      final int userStatus = response['data']['user_status'];
      OtpResponse otpResponse =  OtpResponse(userId: userId, session: session, userStatus: userStatus);
      setState(() {
        _useridController.clear();
        Navigator.pushNamed(
        context,VerifyOtp.routename,
        arguments: otpResponse
        );
      });
    } 
    else if(response['status'] == 900) {
      MyHelpers.msg(message:response["message"],backgroundColor: Colors.black);
    }
    else {    
      String responseMsg =await MyHelpers().getMessageFromCode(response["message_code"]);
    MyHelpers.msg(message: responseMsg,backgroundColor: Colors.black);
    }
    setState(() {
      loadingtime = false;
    });
  }
}

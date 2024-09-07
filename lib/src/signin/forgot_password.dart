import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/token.dart';
import '/src/api/api_service.dart';
import '/src/models/auth_models.dart';
import '/src/shared/appconfig.dart';
import '/src/signin/sign_in.dart';
import '/src/widgets/text_form.dart';

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {Navigator.pushReplacementNamed(context, SignIn.routeName);}, icon: const Icon(Icons.arrow_back_sharp)),
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
                  SizedBox(
                    height: height * 0.05,
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
                    height: 40,
                  ),
                  const Text(
                    'Enter your Email',
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  Form(
                    key: _formKey,
                    child: SizedBox(
                      height: 70,
                      child: MyTextField(
                        obscureText: false,
                        controller: _useridController,
                        validateKey: 'Userid',
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                      child: loadingtime
                          ? SizedBox(
                              height: 50,
                              child: SpinKitCircle(
                                color: Colors.blue[300],
                                size: 40.0,
                              ))
                          : TextButton(
                              onPressed: () {
                                _formKey.currentState!.validate()
                                    ? {
                                        setState(() {
                                          loadingtime = true;
                                          resetPassword();
                                        })
                                      }
                                    : null;
                              },
                              child: Container(
                                  height: 40,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color.fromARGB(255, 0, 106, 193),
                                  ),
                                  child: const Center(
                                      child: Text(
                                    'Send OTP',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                            )),
                  SizedBox(
                    height: height * 0.2,
                  ),
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
      Fluttertoast.showToast(msg: response['message']);
      setState(() {      
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

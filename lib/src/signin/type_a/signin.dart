import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../api/token.dart';
import '../../geolocation/location_notifier.dart';
import '../../modules/flaxi/api_data_models/rateby_groups_models.dart';
import '../../modules/flaxi/helpers/group_service.dart';
import '../../helpers/helpers.dart';
import '../../modules/flaxi/helpers/rate_change_helpers.dart';
import '../../modules/flaxi/helpers/wallet_helper.dart';
import '../models/auth_models.dart';
import '../../root_page.dart';
import '../../shared/app_config.dart';
import '../../shared/global_data.dart';
import '../../widgets/default_button.dart';
import '../../widgets/user_input_form_field.dart';
import 'forgot_password.dart';
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
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
                          validateKey: 'singinUserid',
                          hintText: 'Email',
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
                          validateKey: 'singinpw',
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
                    Column(
                      children: [
                        SizedBox(
                          height: height * 0.137,
                        ),
                        AppConfig.shared.allowGuest
                            ? TextButton(
                                onPressed: _performSkip,
                                child: const Text('Skip',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 0, 106, 193))),
                              )
                            : const SizedBox(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?  "),
                            InkWell(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, Signup.routeName);
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 106, 193),
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                        SizedBox(height: height * 0.03),
                        DefaultButton(
                          text: 'Sign In',
                          onTap: () {
                            setState(() {
                              loadingTime
                                  ? null
                                  : _formKey.currentState!.validate()
                                      ? {
                                          loadingTime = true,
                                          signIn(),
                                        }
                                      : null;
                            });
                          },
                          loading: loadingTime,
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
    if (AppConfig.shared.log >= 3) logger.i('Skip login');
    GlobalAccess.reset();
    GlobalAccess.updateGToken("");
    Navigator.pushReplacementNamed(context, RootPage.routeName);
  }

  signIn() async {
    String userid = _useridController.text;
    String password = _passwordController.text;
    List<int> bytes = utf8.encode(password);
    String base64password = base64Encode(bytes);
    String uuId =
        MyStore.prefs.getString('uuid') ?? await Token().getDeviceUUID();
    DateTime time = DateTime.now().toUtc();
    String sToken = await Token().createSToken(time, '2');
    // ignore: use_build_context_synchronously
    LocationNotifier providerLocNoti = Provider.of<LocationNotifier>(context, listen: false);
    SignInRequest reqIN = SignInRequest(
        userId: userid,
        password: base64password,
        sToken: sToken,
        appId: AppConfig.shared.appID,
        uuId: uuId,
        dateTime: time.toIso8601String(),
        reqType: 2);
    logger.i(reqIN.toJson());
    final response = await ApiService().userSignIn(reqIN);

    if (response['status'] == 200) {
      String responseMsg =await MyHelpers().getMessageFromCode(response["message_code"]);
      MyHelpers.msg(message: responseMsg,backgroundColor: Colors.green);
      GlobalAccess.updateUToken(
          response['data']['user_id'],
          response['data']['user_name'],
          response['data']['access_token'],
          response['data']['refresh_token']);
      GlobalAccess.updateSecToken();
      MyStore.storeSignInDetails(AppConfig.shared.signinType, DateTime.now());
      GroupService.fetchAndStoreGroups().then((_) {

        GroupService.fetchAndStoreRate().then((_) {
        updateRateData(providerLocNoti);
        });
       WalletData().initializeWallet();


      });
      setState(() {
        loadingTime = false;
        Navigator.pushReplacementNamed(context, RootPage.routeName);
        _useridController.clear();
        _passwordController.clear();
      });
    } else if(response['status'] == 900) {
      MyHelpers.msg(message:response["message"],backgroundColor: Colors.black);
    }
    else {
      String responseMsg =await MyHelpers().getMessageFromCode(response["message_code"]);
      MyHelpers.msg(message: responseMsg,backgroundColor: Colors.black);
    }
    setState(() {
      loadingTime = false;
    });
  }
}

Future<void> updateRateData(LocationNotifier providerLocNoti) async {
  List<Rate>? rateData = await MyStore.retrieveRatebyGroup('ratebydomain');
  if (rateData != null) {
    int initialAmount = int.parse(rateData[0].initial);
    int ratePerKm = int.parse(rateData[0].rate);
    int increment = 100;
    String groupCurrency=rateData[0].rate;
    RateChangeHelper.updateRateData(initialAmount, ratePerKm, increment,groupCurrency,providerLocNoti);
  } else {
    RateChangeHelper.updateRateData(0, 0, 0,'MMK',providerLocNoti);
  }
}

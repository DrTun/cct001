import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../geolocation/location_notifier.dart';
import '../../modules/flaxi/api/api_data_service_flaxi.dart';
import '../../modules/flaxi/api_data_models/driver_register_models.dart';
import '../../modules/flaxi/api_data_models/rateby_groups_models.dart';
import '../../modules/flaxi/helpers/group_service.dart';
import '../../helpers/helpers.dart';
import '../../modules/flaxi/helpers/log_model.dart';
import '../../modules/flaxi/helpers/log_service.dart';
import '../../modules/flaxi/helpers/rate_change_helpers.dart';
import '../../modules/flaxi/helpers/wallet_helper.dart';
import '../models/auth_models.dart';
import '../../root_page.dart';
import '../../shared/app_config.dart';
import '../../shared/global_data.dart';
import '../../widgets/default_button.dart';
import 'signin_otp.dart';
import 'user_singup.dart';

class VerifyOtp extends StatefulWidget {
  static const routename = '/otpverify';

  final OtpResponse otpResponse;
  const VerifyOtp( {super.key, required this.otpResponse,});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final _otpCodeController = TextEditingController();
  final RegExp phoneRegExp = RegExp(r'^(?:\+?959|09)\d{7,9}$');

  
  bool loadingtime = false;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom == 0;
    bool userIdchk = widget.otpResponse.userId.startsWith(RegExp(r'^[a-zA-Z]'));
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, SignInotp.routename);
              },
              icon: const Icon(Icons.arrow_back_sharp)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                isKeyboardVisible?  SizedBox(height: height * 0.1,) : SizedBox(height: height * 0.04,),
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
                  const SizedBox( height: 40,),
                  userIdchk
                    ? const Text('Enter the 6-digits code we sent to your email address',style: TextStyle(fontSize: 18, ),)
                    : const Text('Enter the 6-digits code we sent to your mobile number',style: TextStyle(fontSize: 18, ),),
                  const SizedBox(height: 8),
                  Text(
                    formatPhoneNumber(widget.otpResponse.userId),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  PinCodeTextField(
                    appContext: context,
                    controller: _otpCodeController,
                    length: 6,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.blue,
                    textStyle: const TextStyle(color: Colors.black),
                    enableActiveFill: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter OTP code!';
                      } else if (value.length < 6) {
                        return 'Missing OTP code!';
                      }
                      return null;
                    },
                    pinTheme: PinTheme(
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeColor: Colors.grey[200],
                      selectedColor: Colors.grey[400],
                      inactiveColor: Colors.grey[200],
                      activeFillColor: Colors.grey[200],
                      inactiveFillColor: Colors.grey[200],
                      selectedFillColor: Colors.grey[200],
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  DefaultButton(loading: loadingtime, text: 'Confirm OTP', onTap: () {                          
                          if(_otpCodeController.text.length == 6) {
                            setState(() {
                            FocusScope.of(context).unfocus();
                            loadingtime = true;
                            otpVerify();
                          });
                          }
                          
                        },),
                  isKeyboardVisible
                      ? const SizedBox()
                      : const SizedBox(height: 10,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  otpVerify() async {
    String userId = widget.otpResponse.userId;
    String otp = _otpCodeController.text;
    String session = widget.otpResponse.session;
    LocationNotifier providerLocNoti = Provider.of<LocationNotifier>(context, listen: false);
    OtpVerifyReq otpverifyReq = OtpVerifyReq(
        userId: userId,
        otp: otp,
        session: session,
        appId: AppConfig.shared.appID);
    final response = await ApiService().otpVerify(otpverifyReq);
    if (response['status'] == 200) {
      GlobalAccess.updateUToken(response['data']['user_id'], response['data']['user_name']??'',
          response['data']['access_token'], response['data']['refresh_token']);
      GlobalAccess.updateSecToken();
      MyStore.storeSignInDetails(AppConfig.shared.signinType, DateTime.now());
     await registerDriver();
      GroupService.fetchAndStoreGroups().then((_){
        GroupService.fetchAndStoreRate().then((_){
        updateRateData(providerLocNoti);
        });
      WalletData().initializeWallet();

      });
      

      setState(() {
        if(widget.otpResponse.userStatus==0)
          {  
            
             Navigator.pushReplacementNamed(context, UserSingup.routeName,arguments: widget.otpResponse.userId,); }
        else if(GlobalAccess.userName.isEmpty) 
        { Navigator.pushReplacementNamed(context, UserSingup.routeName,arguments: widget.otpResponse.userId,); }
        else
        {
           Navigator.pushNamedAndRemoveUntil(context, RootPage.routeName, ModalRoute.withName('/'));}
        _otpCodeController.clear();
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

  String formatPhoneNumber(String userid) {
  String formatNumber = userid.replaceAll(RegExp(r'\D'), '');

  switch (formatNumber) {
    case String n when n.startsWith('959'):
      return '+$formatNumber';
    case String n when n.startsWith('09'):
      return formatNumber.replaceFirst('0', '+95');
    case String n when n.startsWith('+959'):
      return formatNumber;
    default:
      return userid; 
  } 
  }

}
 registerDriver() async{
    const syskey = '';
    final fbtoken =await MyStore.prefs.getString('fbtoken') ?? "";
   
    DriverRegister driverRegisterReq = DriverRegister(
      syskey: syskey, 
      name: GlobalAccess.userName, 
      email: GlobalAccess.userID.startsWith(RegExp(r'^(?:\+?959|09)\d{7,9}$'))?"":GlobalAccess.userID, 
      mobile: GlobalAccess.userID.startsWith(RegExp(r'^(?:\+?959|09)\d{7,9}$'))?GlobalAccess.userID:"", 
      vehicleno: "", 
      vehicle: "", 
      fbtoken: fbtoken??'');
   try{
    final response = await ApiDataServiceFlaxi().driverRegister(driverRegisterReq);
    if(response is DriverRegisterResponse){
      GlobalAccess.updateDriverID(response.dataD.syskey);  //adding
      GlobalAccess.updateSecToken();
    }
    else if(response['status'] == 900) {
      MyHelpers.msg(message:response["message"],backgroundColor: Colors.black);
    }
    else {
      String responseMsg =await MyHelpers().getMessageFromCode(response["message_code"]);
    MyHelpers.msg(message: responseMsg,backgroundColor: Colors.black);
    }
   }catch(e){
     LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace: 'Driver Register (api_data_service_flaxi)', timestamp:DateTime.now().toString()));
    MyHelpers.msg(message: e.toString(),backgroundColor: Colors.black);

   }
    
    
  }

Future<void> updateRateData(LocationNotifier providerLocNoti) async {
   List<Rate>? rateData = await MyStore.retrieveRatebyGroup('ratebydomain');
      if (rateData != null) {
        int initialAmount = int.parse(rateData[0].initial);
        int ratePerKm = int.parse(rateData[0].rate);
        String groupCurrecny=rateData[0].symbol;
        int increment = 100;
        RateChangeHelper.updateRateData(initialAmount, ratePerKm, increment,groupCurrecny,providerLocNoti);
      } else {
        RateChangeHelper.updateRateData(0, 0, 0,'MMK',providerLocNoti);
      }
}



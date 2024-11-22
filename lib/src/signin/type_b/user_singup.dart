import 'package:flutter/material.dart';
//import '../../api/api_service.dart';
import '../../helpers/helpers.dart';
//import '../../models/auth_models.dart';
import '../../modules/flaxi/api/api_data_service_flaxi.dart';
import '../../modules/flaxi/api_data_models/driver_register_models.dart';
import '../../root_page.dart';
import '../../shared/global_data.dart';
import '../../widgets/default_button.dart';
import '../../widgets/user_input_form_field.dart';

class UserSingup extends StatefulWidget {
  static const routeName = '/usernamefieldpage';
  final String userid;
  const UserSingup({super.key, required this.userid});

  @override
  State<UserSingup> createState() => _UserSingupState();
}

class _UserSingupState extends State<UserSingup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _vehivleNameController = TextEditingController();
  bool loadingtime = false;
  String emailUserId = '';
  String mobileUserId = '';
  String driverID = GlobalAccess.driverID;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom == 0;
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 25, right: 25.0, bottom: 10, top: 25),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                          width: 110,
                          height: 110,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'User Name',
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        child: UserInputFormField(
                      obscureText: false,
                      controller: _userNameController,
                      validateKey: 'Username',
                      hintText: 'User Name',
                    )),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Vehicle NO.',
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        child: UserInputFormField(
                      obscureText: false,
                      controller: _vehicleNoController,
                      validateKey: 'vehicleName',
                      hintText: 'Vehicle NO.',
                    )),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Vehicle Name',
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        child: UserInputFormField(
                      obscureText: false,
                      controller: _vehivleNameController,
                      validateKey: 'vehicleNO',
                      hintText: 'Vehicle Name',
                    )),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Column(
                      children: [
                        DefaultButton(
                          text: 'Next',
                          onTap: () async {
                            setState(() {
                              loadingtime
                                  ? null
                                  : _formKey.currentState!.validate()
                                      ? {
                                          FocusScope.of(context).unfocus(),
                                          loadingtime = true,
                                          registerDriver()
                                        }
                                      : null;
                            });
                          },
                          loading: loadingtime, //loading time
                        ),
                        isKeyboardVisible
                            ? SizedBox(
                                height: height * 0.05,
                              )
                            : const SizedBox(
                                height: 5,
                              )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  registerDriver() async {
    final syskey = GlobalAccess.driverID;
    final userName = _userNameController.text.trim();
    final vehicleNo = _vehicleNoController.text.trim();
    final vehicleName = _vehivleNameController.text.trim();
    await checkUserId(widget.userid);

    DriverProfile req = DriverProfile(
      syskey: syskey,
      name: userName,
      vehicleno: vehicleNo,
      vehicle: vehicleName,
    );
    ApiDataServiceFlaxi().driverProfile(req);
    // Store updated profile data in SharedPreferences
    await MyStore.prefs.setString('username', req.name);
    await MyStore.prefs.setString('userid', req.syskey);
    await MyStore.prefs.setString('vehicleno', req.vehicleno);
    await MyStore.prefs.setString('vehicle', req.vehicle);

    // MyHelpers.msg(message: response.message, backgroundColor: Colors.green);
    GlobalAccess.updateUnameToken(req.name);
    GlobalAccess.updateSecToken();
    driverInfo();
    setState(() {
      _userNameController.clear();
      Navigator.pushNamedAndRemoveUntil(
          context, RootPage.routeName, ModalRoute.withName('/'));
    });

    setState(() {
      loadingtime = false;
    });
  }

  checkUserId(userid) {
    final RegExp phoneRegExp = RegExp(r'^(?:\+?959|09)\d{7,9}$');
    if (userid.startsWith(phoneRegExp)) {
      setState(() {
        mobileUserId = userid;
      });
    } else {
      setState(() {
        emailUserId = userid;
      });
    }
  }

  void driverInfo() async {
    try {
      final response =
          await ApiDataServiceFlaxi().getDriverInfo(GlobalAccess.driverID);

      if (response is DriverProfile) {
        DriverProfile req = response;
        await MyStore.prefs.setString('username', req.name);
        await MyStore.prefs.setString('vehicleno', req.vehicleno);
        await MyStore.prefs.setString('vehicle', req.vehicle);
      }
    } catch (e) {
      logger.e('Error fetching driver info: $e');
    }
  }
 
}

  // usernamechange() async{
  //   final userName = _userNameController.text.trim();
  //   final userId = widget.userid;
  //   UserNameReq userNameReq = UserNameReq(userId: userId, userName: userName);
  //   final response = await ApiService().changeUserName(userNameReq);
  //   if (response['status'] == 200) {
  //     final String msg = response['message'] ?? 'success';
  //     MyHelpers.msg(message: msg,backgroundColor: Colors.green);
  //     GlobalAccess.updateUnameToken(userName);
  //     GlobalAccess.updateSecToken();
  //     setState(() {
  //       _userNameController.clear();
  //       Navigator.pushNamedAndRemoveUntil(context, RootPage.routeName, ModalRoute.withName('/'));
  //     });
  //   }
  //   else if( response['status'] == 401){
  //     MyHelpers.msg(message : response['messgae']?? 'Unauthorized');
  //   }
  //   else if(response['status'] == 408) {
  //     MyHelpers.msg(message: response['message']??'Request time out.',backgroundColor: Colors.black);
  //   }
  //   else {
  //   MyHelpers.msg(message: response['message']??'Saving Failed',backgroundColor: Colors.black);
  //   }
  //   setState(() {
  //     loadingtime = false;
  //   });
  // }


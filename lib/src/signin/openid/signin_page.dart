
import '../../shared/app_config.dart';
import 'package:flutter/material.dart';   
import '../../api/api_auth.dart'; 
import '../../shared/global_data.dart';  
import '../../helpers/helpers.dart';  
import '../../root_page.dart'; 
//  -------------------------------------    Sign In Page (Property of Nirvasoft.com)
class SigninPage extends StatefulWidget {
  static const routeName = '/signinpage';
  const SigninPage({super.key});
  @override
  State<SigninPage> createState() => _SigninState();
}
class _SigninState extends State<SigninPage> {
    late final ApiAuthService apiAuthService;  
    final userIdController = TextEditingController();
    final passwordController = TextEditingController(); 
  @override
  void initState() {
    super.initState();
    apiAuthService = ApiAuthService();
    if (AppConfig.shared.log>=3) logger.i('API initialized');
    userIdController.text = "demo";          // set default value with demo 
    passwordController.text = "1020304050";    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In'),),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25,),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                TextField( decoration: const InputDecoration( labelText: 'User ID', ),controller: userIdController, ),
                const SizedBox(height: 20),
                TextField( decoration: const InputDecoration( labelText: 'Password', ), obscureText: true,controller: passwordController,),
              ],
            ),
          ),
          const SizedBox(height: 50,),
            ElevatedButton(
            onPressed: () async {
              if (userIdController.text.isEmpty || passwordController.text.isEmpty) { // validation
                showDialog(
                context: context,  builder: (context) => AlertDialog(  title: const Text('Error'),content: const Text('User ID and Password cannot be empty.'),
                actions: [TextButton( onPressed: () => Navigator.pop(context), child: const Text('OK'), ),], ),);
                return;
              }
              _performSignIn();  
            },
            child: const Icon(Icons.arrow_forward),
            ),
          const SizedBox(height: 30,),
          TextButton( onPressed: _performGuest,child: const Text('Join as Guest User', style: TextStyle(decoration: TextDecoration.underline)),), 
          TextButton( onPressed: _performSocial,child: const Text('Social', style: TextStyle(decoration: TextDecoration.underline)),), 
          TextButton( onPressed: _performSkip,child: const Text('Skip', style: TextStyle(decoration: TextDecoration.underline)),), 
        ],
      ), 
    );
  }
  Future<void> _performSignIn() async {
    try {
      String userid = userIdController.text ;
      String password = passwordController.text ;
      final apiResponse = await apiAuthService.userSignIn(userid, password);
      if (AppConfig.shared.log>=3) logger.i('User login response: $apiResponse');
      if (apiResponse['status'] == 200) { 
        GlobalAccess.updateUToken(userid,apiResponse['data']['user_name'],apiResponse['data']['user_token'],apiResponse['data']['refresh_token'],);
        logger.i("gdata  $GlobalAccess.refreshToken");
        
        GlobalAccess.updateSecToken(); 
        MyStore.storeSignInDetails(AppConfig.shared.signinType, DateTime.now());
        setState(() {Navigator.pushReplacementNamed(context, RootPage.routeName);});
      } else if (apiResponse['status'] == 500) { // Other Exceptions from Class
        MyHelpers.showIt("Connectivity [50x]"); 
      } else { 
        MyHelpers.showIt("Invalid User ID or Password.");
      }
    } catch (e, stacktrace) { // Other Exceptions from Widget
      if (AppConfig.shared.log>=1) logger.e("Connectivity #40x (User): $e\n$stacktrace");
      MyHelpers.showIt("Connectivity [50xx]"); 
    }
  }
  Future<void> _performGuest() async {  
    try { 
      final apiResponse = await apiAuthService.guestSignIn();
      if (AppConfig.shared.log>=3) logger.i('Guest login response: $apiResponse');
      if (apiResponse['status'] == 200) {   
        GlobalAccess.reset();               // Reset Global Data
        await GlobalAccess.resetSecToken(); // Reset Secure Storage
        GlobalAccess.updateGToken(apiResponse['data']['guest_token']); // Use guest token
        
        setState(() {  Navigator.pushReplacementNamed(context, RootPage.routeName);   }); // SetState to Route
      } else if (apiResponse['status'] == 500) { // Other Exceptions from Class
        MyHelpers.msg(message: "Connectivity [50x]"); 
      } else { 
        MyHelpers.msg(message: "Unauthorized Access (Guest)"); 
      }
    } catch (e, stacktrace) { // Other Exceptions from Widget
      if (AppConfig.shared.log>=1) logger.e("Connectivity #50xx (Guest): $e\n$stacktrace");
      MyHelpers.msg(message: "Connectivity [50xx]"); 
    } 
  }
  Future<void> _performSocial() async { 
  }
  Future<void> _performSkip() async {
    if (AppConfig.shared.log>=3) logger.i('Skip login');
    GlobalAccess.reset();
    GlobalAccess.updateGToken(""); 
    Navigator.pushReplacementNamed(context, RootPage.routeName);
  }
}

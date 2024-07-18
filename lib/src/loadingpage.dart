//  -------------------------------------    Loading 
import 'api/api_auth.dart';

import 'globaldata.dart';
import 'rootpage.dart';
import 'helpers/helpers.dart'; 
import 'helpers/env.dart';
import 'signinpage.dart';
import 'package:flutter/material.dart'; 
//  -------------------------------------    Loading (Property of Nirvasoft.com)
class LoadingPage extends StatefulWidget {
  static const routeName = '/loading';
  const LoadingPage({super.key});
  @override
  State<LoadingPage> createState() => _LoadingState();
}
class _LoadingState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState(); 
    loading(context);
  }
  Future loading(BuildContext context) async { 
    // Load Environments
    if ( await EnvService.loadEnv()!= 200) {
      MyHelpers.msg("Environment Errors");
      return;
    }
    // Read Global Data from Secure Storage
    await GlobalAccess.readSecToken();
    await ApiAuthService.checkRefreshToken(); // Loading, Resume etc

    // Dummy Code to demo serial, background and parallel processing
    await something(); // serial run
    await something(); 
    something(); // background  run
    something(); 
    var p1 = something(); // parallel run
    var p2 =something(); 
    await p1; 
    await p2;  

    // Decide where to go based on Global Data read from secure storage.
    setState(() {
      if( GlobalAccess.userID.isNotEmpty || GlobalAccess.accessToken.isNotEmpty){
        Navigator.pushReplacementNamed(context,RootPage.routeName, ); 
      } else { 
        Navigator.pushReplacementNamed(context,SigninPage.routeName, );  
      }
    });
  }
  Future<bool> something() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.5,), 
        const Center(
          child: Text('Welcome', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
        ),
        const SizedBox(height: 50,), 
        const Text('Loading data ...', ),
        ]
      ),
    );
  }
}


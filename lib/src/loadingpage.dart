//  -------------------------------------    Loading 
import 'api/api_auth.dart';

import 'shared/globaldata.dart';
import 'rootpage.dart'; 
import 'signin/signinpage.dart';
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
    // Read Global Data from Secure Storage
    await GlobalAccess.readSecToken();
    if (GlobalAccess.accessToken.isNotEmpty){  // should not refresh if guest coming back. let sign in again
      await ApiAuthService.checkRefreshToken(); 
    }

    // Decide where to go based on Global Data read from secure storage.
    setState(() {
      if( GlobalAccess.userID.isNotEmpty || GlobalAccess.accessToken.isNotEmpty){
        Navigator.pushReplacementNamed(context,RootPage.routeName, ); 
      } else { 
        Navigator.pushReplacementNamed(context,SigninPage.routeName, );  
      }
    });
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


import 'package:flutter/material.dart';

import '../signin/signin.dart';
import '../signin/signinpage.dart'; 

enum Flavor { prod, dev, sit, staging }

class AppConfig {
  String appVersion = "1.0.3";   // Update internal version number, edit here
  bool allowGuest = true;       // Allow Guest Access, edit here
  bool skipSignin = true ;      // Skip Signin Page, edit here
  int signinType = 1;          // 0= dummy, 1= AIM 2.0, 3=Keycloak, edit here
  
  String appName = "";
  String appDesc = "";
  String appID = "";
  String baseURL="";
  String authURL="";
  String clientID="";
  String secretKey="";
  int log=1;
  bool fcm=false;
  MaterialColor primaryColor = Colors.blue;
  Flavor flavor = Flavor.dev;

  static AppConfig shared = AppConfig.create();

  factory AppConfig.create({
    String appName = "",
    String appDesc = "",
    String appID = "",
    MaterialColor primaryColor = Colors.blue,
    Flavor flavor = Flavor.dev,
    String clientID="",
    String baseURL="",
    String authURL="",
    String secretKey="",
    int log=1,
    bool fcm=false,
  }) {
    return shared = AppConfig(appName, appDesc,appID, primaryColor, flavor,clientID,baseURL,authURL,secretKey,log,fcm);
  }

  AppConfig(this.appName, this.appDesc, this.appID, this.primaryColor, this.flavor, this.clientID, this.baseURL, this.authURL,this.secretKey, this.log,this.fcm);

  static void signIn(BuildContext context){
    if (AppConfig.shared.signinType==0) { 
      Navigator.pushReplacementNamed(context,SigninPage.routeName, );  
    } else if (AppConfig.shared.signinType==1){
      Navigator.pushReplacementNamed(context, SignIn.routeName);
    }
  }

}


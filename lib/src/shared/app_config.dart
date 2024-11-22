import 'package:flutter/material.dart';

import '../signin/type_a/signin.dart';
import '../signin/type_b/signin_otp.dart';
import '../signin/openid/sigin_social.dart';
import '../signin/openid/signin_page.dart';

enum Flavor { prod, dev, sit, staging }

class AppConfig {
  bool allowGuest = false; // Allow Guest Access, edit here
  bool gotoRootDirect = false; // Goto Root Direclty, skipping Signin Page when app starts, edit here
  int signinType = 2; // 0= dummy, 1= IAM 2.0 typeA , 2= IAM 2.0 typeB, 3=Keycloak, edit here
  bool saveTrip = true; // Save Trip to DB, edit here
  bool curlocByApi = false; // send Current Location by API, edit here

  String appName = "";
  String appDesc = "";
  String appID = "";
  String appVersion = "1.0.0";
  String baseURL = "";
  String baseURLDEV = "";
  String authURL = "";
  String clientID = "";
  String secretKey1 = "";
  String openIDClientID = "";
  String openIDBaseURL = "";
  String openIDAuthURL = "";
  String openIDSignUpURL = "";
  String secretKey3 = "";
  String webSocketUrl = "";
  String googleApiKey="";
  String googlePlaceUrl="";
  String appUrlPlaystore="";
  String xpassBaseURL = "";
  String xpassWebSocketURL = "";
  int log=1;
  bool fcm=true;
  MaterialColor primaryColor = Colors.blue;
  Flavor flavor = Flavor.dev;

  static AppConfig shared = AppConfig.create();

  factory AppConfig.create({
    String appName = "",
    String appDesc = "",
    String appID = "",
    String appVersion = "2.0.0",
    MaterialColor primaryColor = Colors.blue,
    Flavor flavor = Flavor.dev,
    String clientID = "",
    String baseURL = "",
    String baseURLDEV = "",
    String authURL = "",
    String secretKey1 = "",
    String openIDClientID = "",
    String openIDBaseURL = "",
    String openIDAuthURL = "",
    String openIDSignUpURL = "",
    String secretKey3 = "",
    String webSocketUrl = "",
    String googleApiKey="",
    String googlePlaceUrl="",
    String appUrlPlaystore="",
    String xpassBaseURL ="",
    String xpassWebSocketURL = "",
    int log=1,
    bool fcm=false,
  }) {
    return shared = AppConfig(appName, appDesc,appID,appVersion, primaryColor, flavor,clientID,baseURL,baseURLDEV,authURL,secretKey1,openIDClientID,openIDAuthURL,openIDBaseURL,openIDSignUpURL, secretKey3,webSocketUrl,googleApiKey,googlePlaceUrl,appUrlPlaystore,xpassBaseURL,xpassWebSocketURL,log,fcm);
  }

  AppConfig(this.appName, this.appDesc, this.appID,this.appVersion, this.primaryColor, this.flavor, this.clientID, this.baseURL,this.baseURLDEV, this.authURL,this.secretKey1,this.openIDClientID,this.openIDAuthURL,this.openIDBaseURL,this.openIDSignUpURL,this.secretKey3,this.webSocketUrl,this.googleApiKey,this.googlePlaceUrl,this.appUrlPlaystore,this.xpassBaseURL,this.xpassWebSocketURL, this.log,this.fcm,);

  static void signIn(BuildContext context) {
    if (AppConfig.shared.signinType == 0) {
      Navigator.pushReplacementNamed(
        context,
        SigninPage.routeName,
      );
    } else if (AppConfig.shared.signinType == 1) {
      Navigator.pushReplacementNamed(context, SignIn.routeName);
    } else if (AppConfig.shared.signinType == 2) {
      Navigator.pushReplacementNamed(context, SignInotp.routename);
    } else if (AppConfig.shared.signinType == 3) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        SignInSocial.routeName,
        (route) => false,
      );
    }
  }
}

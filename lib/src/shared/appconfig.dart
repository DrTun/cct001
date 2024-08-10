import 'package:flutter/material.dart';

enum Flavor { prod, dev, sit, staging }

class AppConfig {
  String appVersion = "1.0.3";  // Update internal version number, edit here
  bool skipsignin = true ;      // Skip Signin Page, edit here
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
}
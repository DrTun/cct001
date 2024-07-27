import 'package:flutter/material.dart';

enum Flavor { prod, dev, sit, staging }

class AppConfig {
  String appName = "";
  String appDesc = "";
  String appID = "";
  String baseURL="";
  String authURL="";
  String clientID="";
  String secretKey="";
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
  }) {
    return shared = AppConfig(appName, appDesc,appID, primaryColor, flavor,clientID,baseURL,authURL,secretKey);
  }

  AppConfig(this.appName, this.appDesc, this.appID, this.primaryColor, this.flavor, this.clientID, this.baseURL, this.authURL,this.secretKey);
}
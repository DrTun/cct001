import 'package:flutter/material.dart';

enum Flavor { prod, dev, uat }

class AppConfig {
  String appName = "";
  String appDesc = "";
  String appID = "";
  MaterialColor primaryColor = Colors.blue;
  Flavor flavor = Flavor.dev;

  static AppConfig shared = AppConfig.create();

  factory AppConfig.create({
    String appName = "",
    String appDesc = "",
    String appID = "",
    MaterialColor primaryColor = Colors.blue,
    Flavor flavor = Flavor.dev,
  }) {
    return shared = AppConfig(appName, appDesc,appID, primaryColor, flavor);
  }

  AppConfig(this.appName, this.appDesc, this.appID, this.primaryColor, this.flavor);
}
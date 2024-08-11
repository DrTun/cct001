
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
//  -------------------------------------    Helpers (Property of Nirvasoft.com)

final logger = Logger();
class MyHelpers{
  static msg(String txt, {int? sec, Color? bcolor}){
    sec ??= 2;
    bcolor ??= Colors.redAccent;
    Fluttertoast.showToast(
      msg: txt,toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: sec,  backgroundColor: bcolor, textColor: Colors.white,fontSize: 16.0);
  }
  static showIt(String? value, {String? label}){
  label ??= "Value";
  MyHelpers.msg("$label:  $value",bcolor: Colors.orange);   
  logger.i("$label: $value");
  }
    static Future<String?> getString(BuildContext context,String initvalue,String label) async {
    String? result =  await prompt(
              context,title: Text(label),
              initialValue: initvalue,
              textOK: const Text('OK'), textCancel: const Text('Cancel'),
            );
    return result;
  }
  static Future<int?> getInt(BuildContext context,int initvalue,String label) async {
    int? ret;
    String? result = await getString(context,"$initvalue",label);
      if (result != null) {
        int? parsedResult = int.tryParse(result);
          if (parsedResult != null) { 
            ret = parsedResult;
          }
      }
    return ret;
  }
  static Future<double?> getDouble(BuildContext context,double initvalue,String label) async {
    double? ret;
    String? result = await getString(context,"$initvalue",label);
    if (result != null) {
      double? parsedResult = double.tryParse(result);
      if (parsedResult != null) { 
          ret = parsedResult;
        }
    }
    return ret;
  }
}




class SecureStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  writeSecureData(String key, String value) async {
    await storage.write(key: key, value: value);
  }
  Future<String> readSecureData(String key) async {
    String value = await storage.read(key: key) ?? 'No data found!'; 
    return value;
  }
  deleteSecureData(String key) async {
    await storage.delete(key: key);
  }
}

class MyStore {
  static dynamic prefs;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }
}
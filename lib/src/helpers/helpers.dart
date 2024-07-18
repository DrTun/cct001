
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//  -------------------------------------    Helpers (Property of Nirvasoft.com)
class MyHelpers{
  static msg(String txt, {int? sec, Color? bcolor}){
    sec ??= 2;
    bcolor ??= Colors.redAccent;
    Fluttertoast.showToast(
      msg: txt,toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: sec,  backgroundColor: bcolor, textColor: Colors.white,fontSize: 16.0);
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
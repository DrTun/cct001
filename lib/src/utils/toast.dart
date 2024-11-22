import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static void showToast(int? code, String? message) {
    Fluttertoast.showToast(
      msg: 'Status Code : $code\n Message : $message',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: 16,
      timeInSecForIosWeb: 3,
    );
  }
  static void showToastMsg(String? message) {
    Fluttertoast.showToast(
      msg: '$message',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: 16,
      timeInSecForIosWeb: 3,
    );
  }
}

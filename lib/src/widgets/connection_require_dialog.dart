import 'package:flutter/material.dart';

void connectionRequireDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Connection Required"),
          content: const Text("Please check your internet connection."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
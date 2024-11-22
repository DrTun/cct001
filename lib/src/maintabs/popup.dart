// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomPopup extends StatefulWidget {
  final String message;

  // Constructor to accept the parameter
  const CustomPopup({super.key, required this.message});

  @override
  _CustomPopupState createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  bool _isChanged = false;

  // Method to toggle the state
  void _toggleState() {
    setState(() {
      _isChanged = !_isChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.message,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Access the parameter using widget.message
            Text(widget.message),
            const SizedBox(height: 20),
            Text(
              _isChanged ? "State has been changed!" : "Initial state.",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleState,
              child: const Text("Toggle State"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}

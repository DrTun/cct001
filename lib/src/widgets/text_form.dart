import 'package:flutter/material.dart';
import '/src/helpers/validation.dart';

class MyTextField extends StatefulWidget {
  final String validateKey;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.validateKey,
    required this.obscureText,
    required this.controller,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(    
      autofocus: false,
      validator: (value) => validateField(value, widget.validateKey),
      controller: widget.controller,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          left: 10,
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
           color:  Colors.grey.shade400,
           fontSize: 14
         ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        focusedErrorBorder:OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: Colors.red,
          ), 
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: Colors.grey.shade500,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: Colors.grey.shade500,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: Colors.grey.shade500,
          ),
        ),   
      ),
    );
  }
}

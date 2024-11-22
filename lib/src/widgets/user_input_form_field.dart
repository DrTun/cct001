import 'package:flutter/material.dart';
import '../helpers/validation.dart';
 
class UserInputFormField extends StatefulWidget {
  final String validateKey;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String Function()? validation;
  const UserInputFormField({
    super.key,
    required this.hintText,
    required this.validateKey,
    required this.obscureText,
    required this.controller,
    this.validation,
  });
 
  @override
  State<UserInputFormField> createState() => _UserInputFormFieldState();
}
 
class _UserInputFormFieldState extends State<UserInputFormField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextFormField(
        autofocus: false,
        validator: (value) {
          if (widget.validation != null) {
            String validateKey = widget.validation!();
            return validateField(value, validateKey);
          } else {
            return validateField(value, widget.validateKey);
          }
        },
        controller: widget.controller,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          errorMaxLines: 1,
          errorStyle:
              const TextStyle(color: Colors.red, fontSize: 12, height: 0.25),
          contentPadding: const EdgeInsets.only(left: 10, top: 0, bottom: 0),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          focusedErrorBorder: OutlineInputBorder(
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
      ),
    );
  }
}
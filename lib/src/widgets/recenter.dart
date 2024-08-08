import 'package:flutter/material.dart';
import '/src/widgets/circularbutton.dart';

// ignore: must_be_immutable
class ReCenter extends StatelessWidget {
  final bool value;
  final VoidCallback? onClick;

  final icon1 = const Icon( Icons.center_focus_weak_rounded, color: Colors.white,);
  const ReCenter(
      {super.key,
      required this.value,   
      required this.onClick}
  );
  @override
  Widget build(BuildContext context) {
    return value
    ? const Text("Centered",style: TextStyle(color: Colors.blueGrey),)
    : CircularButton( // show refresh icon onclick go refreshing (rotate)
            color: Colors.lightBlue,
            width: 40, height: 40,
            icon: icon1,
            onClick: () async { 
                onClick!(); 
            },
    );
  }
}
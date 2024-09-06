import 'package:flutter/material.dart';
import '/src/widgets/circularbutton.dart';

// ignore: must_be_immutable
class ReCenterOn extends StatelessWidget {
  final bool value;
  final VoidCallback? onClick;

  final icon1 = const Icon( Icons.center_focus_weak_rounded, color: Colors.white,);
  const ReCenterOn(
      {super.key,
      required this.value,   
      required this.onClick}
  );
  @override
  Widget build(BuildContext context) {
    return value
    ? 
    
    Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers the text horizontally
            children: [
    CircularButton( // show refresh icon onclick go refreshing (rotate)
            color: Colors.grey,
            width: 40, height: 40,
            icon: icon1,
            onClick: () async { 
                onClick!(); 
            },
    ),

    const Text(" Center Map", style: TextStyle(color: Colors.black, fontSize: 10)),
    ]))


    : 
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers the text horizontally
            children: [
    
    CircularButton( // show refresh icon onclick go refreshing (rotate)
            color: Colors.lightBlue,
            width: 40, height: 40,
            icon: icon1,
            onClick: () async { 
                onClick!(); 
            },
    ),

    const Text(" Center Map", style: TextStyle(color: Colors.red, fontSize: 10)),
    ]));
  }
}
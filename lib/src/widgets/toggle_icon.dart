import 'package:flutter/material.dart';
import 'circular_button.dart';

// ignore: must_be_immutable
class ToggleIcon extends StatelessWidget {
  final bool value;
  Icon? iconOn;
  String? labelOn = "";
  Icon? iconOff;
  String? labelOff = "";
  final VoidCallback? onClick;

  //final icon1 = const Icon( Icons.auto_mode, color: Colors.white,);
  ToggleIcon(
      {super.key,
      required this.value,   
      this.iconOn, this.labelOn, this.iconOff, this.labelOff, required this.onClick}
  );
  @override
  Widget build(BuildContext context) {
    Icon iconOn = this.iconOn!=null? this.iconOn!: const Icon( Icons.beenhere , color: Colors.white,);
    Icon iconOff = this.iconOff!=null? this.iconOff!: const Icon( Icons.beenhere, color: Colors.white,);
    String labelOn = this.labelOn!=null? this.labelOn!: "";
    String labelOff = this.labelOff!=null? this.labelOff!: "";
    return value
    ? 
    Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers the text horizontally
            children: [
    CircularButton( // show refresh icon onclick go refreshing (rotate)
            color: Colors.blue,
            width: 40, height: 40,
            icon: iconOn,
            onClick: () async { 
                onClick!(); 
            },
    ),

    Text(" $labelOn", style: const TextStyle(color: Colors.black, fontSize: 10)),
    ]))


    : 
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers the text horizontally
            children: [
    
    CircularButton( // show refresh icon onclick go refreshing (rotate)
            color: Colors.grey,
            width: 40, height: 40,
            icon: iconOff,
            onClick: () async { 
                onClick!(); 
            },
    ),

    Text(" $labelOff", style: const TextStyle(color: Colors.black, fontSize: 10)),
    ]));
  }
}
import 'package:flutter/material.dart';

class SwitchKey extends StatelessWidget {
  final bool value;  
  final VoidCallback? onClick;
  final icon1 = const Icon( Icons.car_repair, color: Colors.white,);
  final icon2 = const Icon( Icons.car_rental, color: Colors.white,);
  const SwitchKey(
      {super.key,
      required this.value,   
      required this.onClick});
  @override
  Widget build(BuildContext context) {
    return 
    value?
    Container(
      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      child: IconButton(icon: icon1, enableFeedback: true, onPressed: onClick),
    )
    :Container(
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      child: IconButton(icon: icon2, enableFeedback: true, onPressed: onClick),
    );
  }
}

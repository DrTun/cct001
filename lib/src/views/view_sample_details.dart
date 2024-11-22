import '../shared/arguments.dart';
import 'package:flutter/material.dart'; 
class ViewDetails extends StatelessWidget { 
  const ViewDetails({super.key});
  static const routeName = '/sample_item';  
  @override
  Widget build(BuildContext context) { 
    final args = ModalRoute.of(context)!.settings.arguments as ArgumentModel01;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Details'),
      ),
      body:  Center(
        //child: Text('Argument is $args'),
        child: Text('Argument is  ${args.a1} ${args.a2}'),
      ),
    );
  } 
}

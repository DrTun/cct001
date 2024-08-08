import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/src/widgets/circularbutton.dart';

// ignore: must_be_immutable
class RefreshCircle extends StatelessWidget {
  final bool value;
  final VoidCallback? onClick;
  const RefreshCircle(
      {super.key,
      required this.value,   
      required this.onClick}
  );
  @override
  Widget build(BuildContext context) {
    return 
    value // cheeck if the map is refreshing
        ? Container( // show rotating circle
            decoration: const BoxDecoration(color: Colors.lightBlue, shape: BoxShape.circle),
            width: 40, height: 40,
            child: SpinKitFadingCircle(
              size: 30.0,
              itemBuilder: (BuildContext context, int index) {  
                return DecoratedBox( decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),);
                },
            )
          )
        : CircularButton( // show refresh icon onclick go refreshing (rotate)
            color: Colors.lightBlue,
            width: 40, height: 40,
            icon: const Icon( Icons.cached, color: Colors.white,),
            onClick: () async { 
                onClick!(); 
            },
          );
  }
}

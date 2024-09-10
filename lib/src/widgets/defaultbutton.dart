import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyButton extends StatelessWidget{
  final bool loading;
  final void Function()? onTap;
  final String text;
  const MyButton({
    super.key,
    required this.loading,
    required this.text,
    required this.onTap  
  });

  @override
  Widget build(BuildContext context) {
    bool loadingText = loading;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 106, 193),
          borderRadius: BorderRadius.circular(6)
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: loadingText? Row(
                  children: [                   
                    Text( text,style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16)),
                    const SizedBox(
                      height: 10, 
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 20,
                      )
                    )
                  ],
                )
                :Text( text,style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
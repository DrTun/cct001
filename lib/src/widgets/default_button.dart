import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DefaultButton extends StatelessWidget{
  final bool loading;
  final void Function()? onTap;
  final String text;
  const DefaultButton({
    super.key,
    required this.loading,
    required this.text,
    required this.onTap  
  });

  @override
  Widget build(BuildContext context) {
    bool loadingText = loading;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      color:  const Color.fromARGB(255, 0, 106, 193), // 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        splashColor: Colors.white.withOpacity(0.2),
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
                        size: 15,
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
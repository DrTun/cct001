import 'package:flutter/material.dart';

class SwitchOn extends StatelessWidget {
  final bool value;  
  final String label;
  final VoidCallback? onClick;
  final icon = const Icon( Icons.car_rental, color: Colors.white,);
  const SwitchOn(
      {super.key,
      required this.value,  
      required this.label,   
      required this.onClick});
  @override
  Widget build(BuildContext context) {
    return 
    GestureDetector( onTap: onClick,
    child: value?
          Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                    child: label.isNotEmpty? Text(label, style: const TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.bold,),):const SizedBox(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                    child: Container(
                      width: 60,height: 32,decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: value? Colors.green: Colors.grey
                      ),
                      child: Stack(
                        children: [
                          const Align(alignment: Alignment.centerLeft,
                              child: Padding( 
                                padding: EdgeInsets.only(left: 12.0),
                                child: Text('ON',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 11.0, ),
                                ),
                              ),
                            ), 
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:const EdgeInsets.only(left: 5, right: 5),
                              child: Container(width: 21.0,height: 21.0,decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white,),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
    :Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                    child: label.isNotEmpty? Text(label, style: const TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.bold,),):const SizedBox(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                    child: Container(
                      width: 60,height: 32,decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: value? Colors.green: Colors.grey
                      ),
                      child: Stack(
                        children: [
                          const Align(alignment: Alignment.centerRight,
                              child: Padding( 
                                padding: EdgeInsets.only(right: 9.0),
                                child: Text('OFF',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 11.0, ),),
                              ),
                            ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:const EdgeInsets.only(left: 5, right: 5),
                              child: Container(width: 21.0,height: 21.0,decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white,),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )

    );
  }
}

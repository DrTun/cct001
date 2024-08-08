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
    Container(
      decoration: const BoxDecoration(shape: BoxShape.rectangle),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(128, 163, 163, 163),
                  borderRadius: BorderRadius.circular(6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                    child: Text(label, style: const TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.bold,),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                    child: Container(
                      width: 80,height: 40,decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: value? Colors.green: Colors.grey
                      ),
                      child: Stack(
                        children: [
                          const Align(alignment: Alignment.centerLeft,
                              child: Padding( 
                                padding: EdgeInsets.only(left: 16.0),
                                child: Text('ON',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 11.0, ),
                                ),
                              ),
                            ), 
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:const EdgeInsets.only(left: 10, right: 10),
                              child: Container(width: 25.0,height: 25.0,decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white,),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),



    )
    :Container(
      decoration: const BoxDecoration(shape: BoxShape.rectangle),

          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(128, 163, 163, 163),
                  borderRadius: BorderRadius.circular(6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                    child: Text(label,style: const TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.bold,),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                    child: Container(
                      width: 80,height: 40,decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: value? Colors.green: Colors.grey
                      ),
                      child: Stack(
                        children: [
                          const Align(alignment: Alignment.centerRight,
                              child: Padding( 
                                padding: EdgeInsets.only(right: 14.0),
                                child: Text('OFF',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 11.0, ),),
                              ),
                            ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:const EdgeInsets.only(left: 10, right: 10),
                              child: Container(width: 25.0,height: 25.0,decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white,),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    )
    );
  }
}

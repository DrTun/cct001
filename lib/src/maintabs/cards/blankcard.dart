import 'package:flutter/material.dart';

Widget blankcard(String title) {
  return  
      Card(elevation: 3,shadowColor: Colors.grey,
        child: 
        Padding(
          padding: const EdgeInsets.all(7.0),
          child: Column(
            children: [
               Text(title,textAlign: TextAlign.center,),
            ],
          ),
        )
      );
}
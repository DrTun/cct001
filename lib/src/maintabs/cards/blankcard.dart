import 'package:flutter/material.dart';

Widget blankcard(String title) {
  return  
      Card(elevation: 3,shadowColor: Colors.grey,
        child: 
        Padding(
          padding: const EdgeInsets.all(7.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
               title,
               textAlign: TextAlign.center,
               style: const TextStyle(fontSize: 15),
               ),
            ],
          ),
        )
      );
}
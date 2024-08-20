import 'package:flutter/material.dart';
import '/src/geolocation/locationnotifier.dart';
import '/src/helpers/helpers.dart';

Widget mapcard(TripData tripdata) {
  return  
      Card(elevation: 3,shadowColor: Colors.grey,
        child: 
        Stack(
          children: [
          Positioned( //  recentre button
                  top: 10,
                  right: 10,
                  child: 
                  tripdata.started
                  ? Image.asset('assets/images/round-green.png',width:15,height: 15,)
                  : Image.asset('assets/images/round-grey.png',width:15,height: 15,)
          ),
           const Positioned( //  recentre button
                  top: 10,
                  left: 10,
                  child: Text("")
          ),

            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Image.asset('assets/images/map.png', width: 50,height: 50,),
                  const SizedBox(height: 5,),
                  Text('${MyHelpers.formatDouble(tripdata.distance)} km', style: const TextStyle(fontFamily: "Digital",fontSize: 18,height: 1.1,color: Colors.red),textAlign: TextAlign.left,),
                  Text('${MyHelpers.formatTime(tripdata.time)} ', style: const TextStyle(fontFamily: "Digital",fontSize: 18,height: 1.1,color: Colors.red),textAlign: TextAlign.left,),
                  Text('MMK ${MyHelpers.formatDouble(tripdata.amount)} ', style: const TextStyle(fontFamily: "Digital",fontSize: 18,height: 1.1,color: Colors.red),textAlign: TextAlign.left,),
                  tripdata.speed>=1? Text('${tripdata.speed.toStringAsFixed(0)} km/h',textAlign: TextAlign.left,):const SizedBox(),
                ],
              ),
            ),


          ]
        )

      );
}
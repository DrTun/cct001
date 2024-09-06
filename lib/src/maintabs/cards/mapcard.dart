import 'package:flutter/material.dart';
import '../../geolocation/geodata.dart';
import '../../widgets/rowdigital.dart';
import '../../widgets/switchontrip.dart';
import '/src/geolocation/locationnotifier.dart';
import '/src/helpers/helpers.dart';

Widget mapcard(TripData tripdata, {bool? transparent, Color? fcolor,double? fsize,int? width,}) {
  transparent ??= false;
  fcolor ??= Colors.green;
    fsize ??= 30;
  return  
      Card(elevation: 3,shadowColor: Colors.grey,color: transparent? Colors.black.withOpacity(0.4):Colors.black,
        child: 
        Stack(
          children: [
          Positioned( //  recentre button
                  bottom: 10,
                  right: 10,
                  child: 
                  GeoData.polyline01.points.length % 2 == 0
                  ? Image.asset('assets/images/round-white.png',width:15,height: 15,)
                  : Image.asset('assets/images/round-grey.png',width:15,height: 15,)
          ),

           const Positioned( //  recentre button
                  top: 0,
                  right: 0,
                  child: SwitchonTrip(label: "",)
          ),

            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  //Image.asset('assets/images/map.png', width: 45,height: 45,),
                  const SizedBox(height: 10),
                  rowDigital(MyHelpers.formatTime(GeoData.tripDuration()),"",fcolor: fcolor,fsize: fsize),
                  rowDigital(MyHelpers.formatDouble(tripdata.distance)," Km",fcolor: fcolor,fsize: fsize), 
                  rowDigital(MyHelpers.formatDouble(tripdata.amount)," Ks",fcolor: fcolor,fsize: fsize),
                  const SizedBox(height:5,),
                  tripdata.speed>=1? Text('${tripdata.speed.toStringAsFixed(0)} km/h',textAlign: TextAlign.left,  style:  const TextStyle(color: Colors.white)) : const SizedBox(),
                ],
              ),
            ),


          ]
        )

      );

      
}


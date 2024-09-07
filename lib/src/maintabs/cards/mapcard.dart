import 'package:flutter/material.dart';
import '../../geolocation/geodata.dart';
import '../../widgets/rowdigital.dart';
import '../../widgets/switchontrip.dart';
import '/src/helpers/helpers.dart';

Widget mapcard({bool? transparent, Color? fcolor,double? fsize,int? width,}) {
  transparent ??= false;
  fcolor ??= Colors.green;
    fsize ??= 30;
  return  
      Card(elevation: 3,shadowColor: Colors.grey,color: transparent? Colors.black.withOpacity(0.4):Colors.black,
        child: 
        Stack(
          children: [
          Positioned( //  recentre button
                  bottom: 0,
                  right: 10,
                  child: 
                  GeoData.points01.length % 2 == 0
                  ? IconButton( // show refresh icon onclick go refreshing
                          icon:  const Icon( Icons.add_location_alt_outlined, color: Colors.white,),
                          onPressed: () async { 
                          },
                  )
                  : IconButton( // show refresh icon onclick go refreshing
                          icon:  const Icon( Icons.add_location_alt, color: Colors.white,),
                          onPressed: () async { 
                          },
                  )
          ),

          const Positioned( //  recentre button
                  top: 0,
                  right: 0,
                  child: SwitchonTrip(label: "",)
          ),
          Positioned( //  recentre button
                  top: 0,
                  left: 0,
                  child: IconButton( // show refresh icon onclick go refreshing
                          icon:  const Icon( Icons.chat_outlined, color: Colors.white,),
                          onPressed: () async { 
                              
                          },
                  )
          ), 
          Positioned( //  recentre button
                  bottom: 0 ,
                  left: 0,
                  child: IconButton( // show refresh icon onclick go refreshing
                          icon:  const Icon( Icons.car_rental, color: Colors.white,),
                          onPressed: () async { 
                          },
                  )
          ),            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  //Image.asset('assets/images/map.png', width: 45,height: 45,),
                  const SizedBox(height: 10),
                  rowDigital(MyHelpers.formatTime(GeoData.tripDuration())," h:m",fcolor: fcolor,fsize: fsize),
                  rowDigital(MyHelpers.formatDouble(GeoData.tripDistance)," km",fcolor: fcolor,fsize: fsize), 
                  rowDigital(MyHelpers.formatDouble(GeoData.tripAmount),  " \$",fcolor: fcolor,fsize: fsize),
                  const SizedBox(height:5,),
                  GeoData.tripSpeedNow>=1? Text('${GeoData.tripSpeedNow.toStringAsFixed(0)} km/h',textAlign: TextAlign.left,  style:  const TextStyle(color: Colors.white)) : const SizedBox(),
                ],
              ),
            ),


          ]
        )

      );

      
}


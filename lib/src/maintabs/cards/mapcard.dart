import 'package:flutter/material.dart';
import '../../geolocation/geodata.dart';
import '../../widgets/rowdigital.dart';
import '../../widgets/switchontrip.dart';
import '../popup.dart';
import '/src/helpers/helpers.dart';

Widget mapcard(BuildContext context,{bool? transparent, Color? fcolor,double? fsize,int? width,}) {
  transparent ??= false;
  fcolor ??= Colors.green;
  fsize ??= 30;
  final GeoData geoData;
   if (GeoData.currentTrip.started) {
      geoData=GeoData.currentTrip;
    } else {
      geoData=GeoData.previousTrip;
   }
   String speed = geoData.currentSpeed>=1? "${geoData.currentSpeed.toStringAsFixed(0)} km/h":"";
  return  
      Card(elevation: 3,shadowColor: Colors.grey,color: transparent? Colors.black.withOpacity(0.4):Colors.black,
        child: 
        Stack(
          children: [
          const Positioned(  
                  top: 0,
                  right: 0,
                  child: SwitchonTrip(label: "",)
          ),
          Positioned(  
                  bottom: 0,
                  right: 0,
                  child: 
                  geoData.points.length % 2 == 0  // showing on and off (even and odd)
                  ? IconButton(  
                          icon:  const Icon( Icons.add_location_alt_outlined, color: Colors.lightBlueAccent,),
                          onPressed: () async { },
                  )
                  : IconButton(  
                          icon:  const Icon( Icons.add_location_alt, color: Colors.lightBlueAccent,),
                          onPressed: () async { },
                  )
          ),
          Positioned(  
                  top: 0,
                  left: 0,
                  child: IconButton(  
                          icon:  const Icon( Icons.chat_outlined, color: Colors.white,),
                          onPressed: () async {  
                          },
                  )
          ), 
          Positioned(  
                  bottom: 0 ,
                  left: 0,
                  child: IconButton(  
                          icon:  const Icon( Icons.car_rental, color: Colors.white,),
                  onPressed: () {
                    showDialog(
                      context: context, builder: (BuildContext context) {
                        return  const CustomPopup(message: "Title of the Pop-up");
                      },
                    );
                  },

                  )
          ),            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  //Image.asset('assets/images/map.png', width: 45,height: 45,),
                  const SizedBox(height: 10),
                  rowDigital(MyHelpers.formatDouble(geoData.distance),speed," km",fcolor: fcolor,fsize: fsize), 
                  rowDigital(MyHelpers.formatTime(GeoData.tripDuration()),""," h:m",fcolor: fcolor,fsize: fsize),
                  rowDigital(MyHelpers.formatDouble(geoData.distanceAmount),  "mmk","",fcolor: fcolor,fsize: fsize),
                  const SizedBox(height:5,),
                  //geoData.currentSpeed>=1? Text('${geoData.currentSpeed.toStringAsFixed(0)} km/h',textAlign: TextAlign.left,  style:  const TextStyle(color: Colors.white)) : const SizedBox(),
                ],
              ),
            ),


          ]
        )

      );

      
}


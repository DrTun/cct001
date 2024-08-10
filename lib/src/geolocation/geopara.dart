import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'geodata.dart';

class GeoPara extends StatefulWidget {
  static const routeName = '/geopara';

  const GeoPara({super.key});
  @override 
  State<GeoPara> createState() => _GeoParaState();
}

class _GeoParaState extends State<GeoPara> {
  int interval = GeoData.interval;
  double distance = GeoData.distance;
  double minDistance = GeoData.minDistance;
  double maxDistance = GeoData.maxDistance;

  @override
  Widget build(BuildContext context) {
    return 
    
    
        Scaffold(
        appBar: AppBar(
        title: const Text('Geo Parameters'),
        ), 
        body:
    
    
    
    Column(
      
      children: [
        
        TextFormField(
          initialValue: interval.toString(),
          onChanged: (value) {
            setState(() {
              interval = int.parse(value);
            });
          },
          decoration: const InputDecoration(labelText: 'Interval'),
        ),
        TextFormField(
          initialValue: distance.toString(),
          onChanged: (value) {
            setState(() {
              distance = double.parse(value);
            });
          },
          decoration: const InputDecoration(labelText: 'Distance'),
        ),
        TextFormField(
          initialValue: minDistance.toString(),
          onChanged: (value) {
            setState(() {
              minDistance = double.parse(value);
            });
          },
          decoration: const InputDecoration(labelText: 'Min Distance'),
        ),
        TextFormField(
          initialValue: maxDistance.toString(),
          onChanged: (value) {
            setState(() {
              maxDistance = double.parse(value);
            });
          },
          decoration: const InputDecoration(labelText: 'Max Distance'),
        ),


      const SizedBox(height: 15), 

      ElevatedButton(
        onPressed: () async {
            GeoData.interval = interval;
            GeoData.distance = distance;
            GeoData.minDistance = minDistance;
            GeoData.maxDistance = maxDistance;
            await GeoData.location.changeSettings(accuracy: LocationAccuracy.high, interval: GeoData.interval, distanceFilter: GeoData.distance);
        },
        child: const Text('Update'),
      ),

      ],


    )


    );


  }
}

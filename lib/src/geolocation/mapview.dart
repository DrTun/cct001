import 'package:flutter/material.dart';
import '/src/geolocation/mapview001.dart';
import 'geodata.dart';
import 'mapview003google.dart'; 
class MapView extends StatelessWidget {
  static const routeName = '/mapview';
  const MapView({super.key});
  @override
  Widget build(BuildContext context) {
      return  Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {Navigator.of(context).pop();},
          ),
        ],
      ),
        body: GeoData.defaultMap==0? const MapView001(): const MapView003(),
      );
   }
}
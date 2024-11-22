import 'package:flutter/material.dart';
import 'map_view_001.dart';
import 'geo_data.dart';
import 'map_view_002google.dart'; 
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
        body: GeoData.mapType==1? const MapView001(): const MapView002Google(),
      );
   }
}
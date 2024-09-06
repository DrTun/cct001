import 'package:flutter/material.dart';
import 'mapview003google.dart'; 
class MapViewGoogle extends StatelessWidget {
  static const routeName = '/mapviewgoogle';
  const MapViewGoogle({super.key});
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
        body: const MapView003(),
      );
   }
}
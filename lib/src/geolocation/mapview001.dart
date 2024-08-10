import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import '/src/shared/appconfig.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/debugcircle.dart';
import '../widgets/recenter.dart'; 
import '../widgets/switchon.dart';
import 'package:provider/provider.dart';
import 'geodata.dart';
//  -------------------------------------    Map001 (Property of Nirvasoft.com)
class MapView001 extends StatefulWidget {
  const MapView001({super.key});

  @override
  MapView001State createState() => MapView001State();
}
class MapView001State extends State<MapView001> {
  late LocationNotifier locationNotifierProvider ;
  final List<Marker> markers = [];
  final List<Polyline> polylines = [];
  //late MapController mapctrl; 
  final  mapctrl = MapController();
  bool refreshing = false; 
  bool switchon = false;
  final ValueNotifier<bool> isStartValue = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    setState(() {
    locationNotifierProvider = Provider.of<LocationNotifier>(context,listen: false);
    });
  }
@override
Widget build(BuildContext context) {
    return Consumer<LocationNotifier>(
      builder: (context, provider , child) {
      double lat =GeoData.currentLat; 
      double lng =GeoData.currentLng;
      return Scaffold(
          body: Stack(
            children: [ 
            FlutterMap(
              mapController: provider.mapController,
              options:   MapOptions(
                initialCenter: LatLng(lat, lng), 
                initialZoom: GeoData.zoom,
                onPositionChanged: (position, hasGesture) {
                  GeoData.zoom=position.zoom;
                  if (hasGesture) {
                    setState(() {GeoData.centerMap=false;});
                  }
                },
                onMapReady: () {
                  GeoData.mapready=true;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:"https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                PolylineLayer(polylines: addPolylines(provider)),   // add markers
                MarkerLayer(rotate: true, markers: addMarkers(provider)), 
              ],
            ),
            Positioned( // refresh button
                  right: 10,
                  top: 0,
                  child: switchOn()),
            Positioned( // refresh button
                  right: 10,
                  bottom: 50,
                  child: debugCircle()),
            Positioned( //  recentre button
                  left: 10,
                  bottom: 50,
                  child: reCenter()),
            Positioned( //  recentre button
                  left: 10,
                  bottom: 10,
                  child: Text("${GeoData.showLatLng?'(${GeoData.counter})':''} ${GeoData.showLatLng?locationNotifierProvider.loc01.lat:''} ${GeoData.showLatLng?locationNotifierProvider.loc01.lng:''} v${AppConfig.shared.appVersion} ", style: const TextStyle(fontSize: 12,color: Colors.red))
                   
                  ),
            ],
          ),
        );
  });
}
  List<Marker> addMarkers(LocationNotifier model) { 
      markers.clear();
      if (GeoData.polyline01Fixed.points.isNotEmpty){
        markers.add(Marker(
          point: LatLng(GeoData.polyline01Fixed.points[0].latitude, GeoData.polyline01Fixed.points[0].longitude), 
          width: 25,height: 25,alignment: Alignment.center,
          child: Image.asset('assets/images/geo/start-blue.png',scale: 1.0,),
          ));
         if (!GeoData.tripStarted) {
           markers.add(Marker(
           point: LatLng(GeoData.polyline01Fixed.points[GeoData.polyline01Fixed.points.length-1].latitude, GeoData.polyline01Fixed.points[GeoData.polyline01Fixed.points.length-1].longitude), 
           width: 25,height: 25,alignment: Alignment.center,
           child: Image.asset('assets/images/geo/end-red.png',scale: 1.0,),
           ));
         }
      }
      if (GeoData.tripStarted) {
        markers.add(Marker(
          point: LatLng(model.loc01.lat, model.loc01.lng), width: 25,height: 25,alignment: Alignment.center,
          child:  Image.asset('assets/images/geo/move-green.png',scale: 0.1,),
        ));
      } else{
        markers.add(Marker(
          point: LatLng(model.loc01.lat, model.loc01.lng), width: 100,height: 100,alignment: Alignment.center,
          child: Image.asset('assets/images/geo/here-red.png',scale: 1.0,),
        ));
        
      }
    return markers;
  }  
  List<Polyline> addPolylines(LocationNotifier model) { 
    polylines.clear();
    if (GeoData.showLatLng) {
      polylines.add(GeoData.polyline01Fixed);
      polylines.add(GeoData.polyline01);
    } else {
      polylines.add(GeoData.polyline01Fixed);
    }
    return polylines;
  }
  Widget reCenter() {
    return 
      ReCenter(
          value: GeoData.centerMap,  
          onClick: ()  {
            setState(() {
                GeoData.centerMap=true;
            });
            locationNotifierProvider.mapController.move(LatLng(locationNotifierProvider.loc01.lat, locationNotifierProvider.loc01.lng),GeoData.zoom); 
          },
      );
  }
  Widget debugCircle() {
    return refreshing // cheeck if on or off
        ? DebugCircle(value: true, onClick: () async {},)
        : DebugCircle(value: false,
            onClick: () async {
              setState(() {});
              setState(() { refreshing = true;}); // start refreshing
              Timer(const Duration(seconds: 3), () {
                  setState(() { refreshing = false;}); // done refreshing
                  if (GeoData.showLatLng) {GeoData.showLatLng=false; } else {GeoData.showLatLng=true;}
                  setState(() {});
                }
              );
            },
          );
  }
  Widget switchOn() {
    return switchon // cheeck if on or off
        ? SwitchOn(value: true, label: "Trip",
            onClick: () async {
              setState(() {switchon = false;  });
              GeoData.endTrip();
              KeepScreenOn.turnOff();
            },
          )
        : SwitchOn(value: false, label: "Trip",
            onClick: () async {
              setState(() {switchon = true;});
              GeoData.polyline01.points.clear();
              GeoData.polyline01Fixed.points.clear();
              GeoData.startTrip();
              KeepScreenOn.turnOn();
            },
          );
  }
}
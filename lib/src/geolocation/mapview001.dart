import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import '../maintabs/cards/mapcard.dart';
import '/src/shared/appconfig.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/debugcircle.dart';
import '../widgets/recenter.dart';  
import 'package:provider/provider.dart';
import 'geodata.dart';
import 'locationnotifier.dart';
//  -------------------------------------    Map001 (Property of Nirvasoft.com)
class MapView001 extends StatefulWidget {
  const MapView001({super.key});

  @override
  MapView001State createState() => MapView001State();
}
class MapView001State extends State<MapView001> {
  //late MyNotifier provider ; 
  late LocationNotifier locationNotifier ;
  final List<Marker> markers = [];
  final List<Polyline> polylines = [];
  //late MapController mapctrl; 
  final  mapctrl = MapController();
  bool refreshing = false; 
  bool switchon = GeoData.tripStarted;
  final ValueNotifier<bool> isStartValue = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    setState(() {
    //provider = Provider.of<MyNotifier>(context,listen: false);
    locationNotifier = Provider.of<LocationNotifier>(context,listen: false);
    });
    if (GeoData.tripStarted){
              KeepScreenOn.turnOn();
    }
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
                  GeoData.mapReady=true;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:"https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                PolylineLayer(polylines: addPolylines()),   // add markers
                MarkerLayer(rotate: true, markers: addMarkers()), 
              ],
            ),
      Positioned( 
            right: 10,
            top: 10,
            child: SizedBox(
                  //width: MediaQuery.of(context).size.width -20,
                  width:220,
                  height: 150,
            child: mapcard(locationNotifier.tripdata,transparent: true, fcolor: Colors.orange, fsize: 32),
            )
      ),
            // Positioned( 
            //       left: 10,
            //       top: 10,
            //       child: 
            //           Container(
            //             width: MediaQuery.of(context).size.width * 0.40,
            //           color: Colors.black.withOpacity(0.8), // Adjust opacity
            //           child: Column(
            //           children: [
            //             const SizedBox(height: 5,),
            //             Text("${provider.tripdata.distance.toStringAsFixed(2)} km", style: const TextStyle(fontFamily: "Digital",fontSize: 30,height: 1.2,color: Colors.green)), 
            //             Text("${MyHelpers.formatTime(GeoData.tripDuration())} ", style: const TextStyle(fontFamily: "Digital",fontSize: 30,height: 1.2,color: Colors.green)),
            //             Text("${MyHelpers.formatDouble(provider.tripdata.amount)} ", style: const TextStyle(fontFamily: "Digital",fontSize: 30,height: 1.2,color: Colors.green)),
            //             provider.tripdata.speed>=1?Text("${provider.tripdata.speed.toStringAsFixed(0)} km/h", style: const TextStyle(fontSize: 12,height: 1.2,color: Colors.green)):const SizedBox(), 
            //             const SizedBox(height: 5,),
            //           ],  
            //           ),
            //       ),
            // ),
            // Positioned( 
            //       right: 10,
            //       top: 0,
            //       child:  GestureDetector(onTap: () {}, child: const SwitchonTrip(label: 'Trip',))
            //       ),
            Positioned( 
                  right: 10,
                  bottom: 50,
                  child: debugCircle()),
            Positioned( 
                  left: 10,
                  bottom: 50,
                  child: reCenter()),
            Positioned( 
                  left: 10,
                  bottom: 10,
                  child: Text("${GeoData.showLatLng?'(${GeoData.counter})':''} ${GeoData.showLatLng?locationNotifier.loc01.lat:''} ${GeoData.showLatLng?locationNotifier.loc01.lng:''} v${AppConfig.shared.appVersion} ", style: const TextStyle(fontSize: 12,color: Colors.red))
                  ),
            ],
          ),
        );
  });
}
  List<Marker> addMarkers() { 
      markers.clear();
      if (GeoData.polyline01Fixed.points.isNotEmpty){
        markers.add(Marker(
          point: LatLng(GeoData.polyline01Fixed.points[0].latitude, GeoData.polyline01Fixed.points[0].longitude), 
          width: 15,height: 15,alignment: Alignment.center,
          child: Image.asset('assets/images/geo/bluedot.png',scale: 1.0,),
          ));
         if (!GeoData.tripStarted) {
           markers.add(Marker(
           point: LatLng(GeoData.polyline01Fixed.points[GeoData.polyline01Fixed.points.length-1].latitude, 
              GeoData.polyline01Fixed.points[GeoData.polyline01Fixed.points.length-1].longitude), 
           width: 15,height: 15,alignment: Alignment.center,
           child: Image.asset('assets/images/geo/reddot.png',scale: 1.0,),
           ));
         }
      }
      if (GeoData.tripStarted) {
        markers.add(Marker(
          point: LatLng(GeoData.currentLat, GeoData.currentLng), width: 100,height: 100,alignment: Alignment.center,
          child:  Image.asset('assets/images/geo/move-car.png',scale: 0.1,),
        ));
      } else{
        markers.add(Marker(
          point: LatLng(GeoData.currentLat, GeoData.currentLng), width: 100,height: 100,alignment: Alignment.center,
          child: Image.asset('assets/images/geo/here-red.png',scale: 1.0,),
        ));
        
      }
    return markers;
  }  
  List<Polyline> addPolylines() { 
    polylines.clear();
    if (GeoData.showLatLng) {
      polylines.add(GeoData.polyline01Fixed);
      polylines.add(GeoData.polyline01);
    } else {
      polylines.add(GeoData.polyline01Fixed);
    }
    return polylines;
  }
  Widget speed() {
    return 
    Text("${GeoData.currentSpeed(GeoData.polyline01,GeoData.dtimeList01,5).toStringAsFixed(0)} km/h", style: const TextStyle(fontSize: 12,color: Colors.red));
  }
  Widget reCenter() {
    return 
      ReCenter(
          value: GeoData.centerMap,  
          onClick: ()  {
            setState(() {
                GeoData.centerMap=true;
            });
            locationNotifier.mapController.move(LatLng(GeoData.currentLat, GeoData.currentLng),GeoData.zoom); 
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
              Timer(const Duration(seconds: 1), () {
                  setState(() { refreshing = false;}); // done refreshing
                  if (GeoData.showLatLng) {GeoData.showLatLng=false; } else {GeoData.showLatLng=true;}
                  setState(() {});
                }
              );
            },
          );
  }
}
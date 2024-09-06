import 'dart:async'; 
import 'package:flutter/material.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart' ;
import '/src/geolocation/geodata.dart';  
import 'package:provider/provider.dart';   
import '../maintabs/cards/mapcard.dart';
import '../shared/appconfig.dart'; 
import '../widgets/toggleicon.dart';
import 'locationnotifier.dart';

class MapView004Google extends StatefulWidget {
  const MapView004Google({super.key});

  @override
  State<MapView004Google> createState() => MapView004GoogleState();
}
class MapView004GoogleState extends State<MapView004Google> {
  // this will hold each polyline coordinate as Lat and Lng pairs
  bool refreshing = false;
  int movingCount =0;
  bool moving=false;
  late LocationNotifier providerLocNoti ;
  BitmapDescriptor icStart = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  @override
  void initState() {
    super.initState();
    // Add polyline
    setState(() {
    providerLocNoti = Provider.of<LocationNotifier>(context,listen: false);
    });
  }

  GoogleMapController? _mapController;

  Future<void> _moveCameraToKeepLocationInView(
    GoogleMapController controller,
    LatLng location,
  ) async {
    //  controller.animateCamera(CameraUpdate.newLatLng(location));
    //final visibleRegion = await controller.getVisibleRegion();
    //if (!visibleRegion.contains(location)) {
      if (GeoData.centerMap){
        if (movingCount>5){
          moving=true;
          controller.moveCamera(CameraUpdate.newLatLng(location));
          movingCount=0;
          Timer(const Duration(seconds: 1), () {moving = false;});
        } else {
          movingCount++;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationNotifier>(
      builder: (consumeContext, model, child) {
        final mapController = _mapController;
        final locationPosition =  LatLng(GeoData.currentLat, GeoData.currentLng);
        if (mapController != null ) {
          _moveCameraToKeepLocationInView(mapController, locationPosition);
        }
        // If we have user's location, then display the google map
        if (GeoData.currentLat!=0 && GeoData.currentLng!=0) { 

          return Scaffold(
            body: Stack(
              children: [
              GoogleMap(
                markers: Set<Marker>.from(addMarkers()),
                polylines: Set<Polyline>.from(addPolylines()),
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: locationPosition,
                  zoom: 18,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                onTap: (LatLng latLng) { 
                  //if (!GeoData.centerMap) {GeoData.centerMap=true;} else {GeoData.centerMap=false;}
                  //  setState(() {});
                },
                onLongPress: (LatLng latLng) { 
                }, 
                onCameraMove: (CameraPosition position) {
                  if (!moving) {
                    GeoData.centerMap = false;
                  }
                },
                onCameraMoveStarted: () { 
                },
                //
                onCameraIdle: () {  
                  //if (!moving){GeoData.centerMap=false;}
                },
                
              ),
              Positioned( 
                    right: 10,
                    top: 10,
                    child: SizedBox(
                          //width: MediaQuery.of(context).size.width -20,
                          width:220,
                          height: 150,
                    child: mapcard(providerLocNoti.tripdata,transparent: true, fcolor: Colors.orange, fsize: 32),
                    )
              ),
              Positioned( 
                          left: 10,
                          bottom: 25,
                          child: reCenter()),
              Positioned( 
                          right: 15,
                          bottom: 100,
                          child: debugGeoData()),
              Positioned( 
                          left: 10,
                          bottom: 10,
                          child: Text("${GeoData.showLatLng?'(${GeoData.counter})':''} ${GeoData.showLatLng?GeoData.currentLat:''} ${GeoData.showLatLng?GeoData.currentLng:''} v${AppConfig.shared.appVersion} ", style: const TextStyle(fontSize: 12,color: Colors.red))
              ),

              ]
            )
          );

        }
        // Else, display container with loading animation
        return const SizedBox(
          width: 400,
          height: 415,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }


  Widget reCenter() {
    return  
      ToggleIcon(
          value: GeoData.centerMap,  
          onClick: ()  {
            setState(() {
                if (!GeoData.centerMap) {GeoData.centerMap=true;} else {GeoData.centerMap=false;}
            });
          },
      );
  }
  Widget debugGeoData() {
    return  
      ToggleIcon(
          value: GeoData.showLatLng, 
          iconOn: const Icon(Icons.closed_caption_off_outlined , color: Colors.white,), 
          iconOff: const Icon(Icons.closed_caption_disabled_outlined, color: Colors.white,),
          onClick: ()  {
            setState(() {
                if (!GeoData.showLatLng) {GeoData.showLatLng=true;} else {GeoData.showLatLng=false;}
            });
          },
      );
  }


  List<Marker> addMarkers() { 
    List<Marker> markers = [];
    if (GeoData.tripStarted){
      if (GeoData.polyline01Fixed.points.isNotEmpty){
        Marker start = Marker(
                  markerId: const MarkerId('Start'),
                  icon: icStart,
                  position: LatLng(GeoData.polyline01Fixed.points[0].latitude, GeoData.polyline01Fixed.points[0].longitude),
                  infoWindow: const InfoWindow(title: 'Start', snippet: '5 Star Rating'),
                );
        markers.add(start);
      }
    } else {
      if (GeoData.polyline01Fixed.points.isNotEmpty){
        Marker start = Marker(
                  markerId: const MarkerId('Start'),
                  icon: icStart,
                  position: LatLng(GeoData.polyline01Fixed.points[0].latitude, GeoData.polyline01Fixed.points[0].longitude),
                  infoWindow: const InfoWindow(title: 'Start', snippet: '5 Star Rating'),
                );
        markers.add(start);
      }
    }
    return markers;
    
    }
  
  List<Polyline> addPolylines() { 
    List<Polyline> polylines = [];
    List<LatLng> plistfixed = [];
    for (var point in GeoData.polyline01Fixed.points) {
      plistfixed.add(LatLng(point.latitude, point.longitude));
    }
    Polyline fixed = Polyline(
      polylineId: const PolylineId('fixed'),
      color: Colors.blue,
      points: plistfixed,
      width: GeoData.fixedThickness.toInt(),
    );
     List<LatLng> plist = [];
    for (var point in GeoData.polyline01.points) {
      plist.add(LatLng(point.latitude, point.longitude));
    }
    Polyline original = Polyline(
      polylineId: const PolylineId('original'),
      color: Colors.red,
      points: plist,
      width: GeoData.oriThickness.toInt(),
    );
    polylines.clear();
    if (GeoData.showLatLng) {
      polylines.add(fixed);
      polylines.add(original);
    } else {
      polylines.add(fixed);
    }
    return polylines;
  }
}
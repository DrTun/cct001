//https://medium.com/@samra.sajjad0001/a-comprehensive-guide-to-using-google-maps-in-flutter-3fbc0f7d469e
//https://pub.dev/packages/google_maps_flutter

import 'dart:async'; 
import 'package:flutter/material.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart' ; 
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:provider/provider.dart';
import '../maintabs/cards/mapcard.dart';
import '../shared/appconfig.dart';
import '../widgets/debugcircle.dart';
import '../widgets/recenter.dart';
import 'geodata.dart';
import 'locationnotifier.dart';

class MapView002Google extends StatefulWidget {
  const MapView002Google({super.key});

  @override
  State<MapView002Google> createState() => MapSampleState();
}

class MapSampleState extends State<MapView002Google> {
  //final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  late LocationNotifier locationNotifier ;
  bool refreshing = false; 
  BitmapDescriptor icStart = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  BitmapDescriptor icEnd = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  BitmapDescriptor icDrive = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

  @override
  void initState() {
    super.initState();
    GeoData.defaultMap=1;
    GeoData.centerMap=true;
    setState(() {
    //provider = Provider.of<MyNotifier>(context,listen: false);
    locationNotifier = Provider.of<LocationNotifier>(context,listen: false);
    });
    if (GeoData.tripStarted){
              KeepScreenOn.turnOn();
    }
    _setCustomMarker();
  }

  // Load the custom marker image
  Future<void> _setCustomMarker() async {
    icStart = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(3, 3)),
      "assets/images/blue.png",
    );
    icEnd = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(3, 3)),
      "assets/images/green.png",
    );
    icDrive = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(3, 3)),
      "assets/images/geo/drive.png",
    );
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    locationNotifier.gmapController = Completer<GoogleMapController>();    
    return Consumer<LocationNotifier>(
      builder: (context, provider , child) { 
    return 
    Scaffold(
      body: Stack(
            children: [
      GoogleMap(
        mapType: MapType.normal,
        //myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
              target: LatLng(GeoData.currentLat, GeoData.currentLng),
              zoom: GeoData.zoom,

        ),
        markers: Set<Marker>.from(addMarkers()),
        polylines: Set<Polyline>.from(addPolylines()),
        onMapCreated: (GoogleMapController controller) { 
          if (locationNotifier.gmapController.isCompleted == false){
            locationNotifier.gmapController.complete(controller);
          } 
          GeoData.gmapReady = true;
        },
        onTap: (LatLng latLng) { 
        },
        onCameraMoveStarted: () {
          GeoData.centerMap = false;
        },
        
        onCameraMove: (CameraPosition position) {
          GeoData.zoom = position.zoom;
        },
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
      Positioned( 
                  left: 10,
                  bottom: 50,
                  child: reCenter()),
      Positioned( 
                  right: 25,
                  bottom: 100,
                  child: debugCircle()),
      Positioned( 
                  left: 10,
                  bottom: 10,
                  child: Text("${GeoData.showLatLng?'(${GeoData.counter})':''} ${GeoData.showLatLng?locationNotifier.loc01.lat:''} ${GeoData.showLatLng?locationNotifier.loc01.lng:''} v${AppConfig.shared.appVersion} ", style: const TextStyle(fontSize: 12,color: Colors.red))
      ),
      ],), 
      // ),
    );
    });
  }

  Widget reCenter() {
    return 
      ReCenter(
          value: GeoData.centerMap,  
          onClick: ()  {
            setState(() {
                GeoData.centerMap=true;
            });
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
        Marker end = Marker(
                  markerId: const MarkerId('End'),
                  icon: icDrive,
                  position: LatLng(GeoData.polyline01Fixed.points[GeoData.polyline01Fixed.points.length-1].latitude, GeoData.polyline01Fixed.points[GeoData.polyline01Fixed.points.length-1].longitude),
                  infoWindow: const InfoWindow(title: 'End', snippet: '5 Star Rating'),
                );
        markers.add(start);
        markers.add(end);
      }
    } else {
      if (GeoData.polyline01Fixed.points.isNotEmpty){
        Marker start = Marker(
                  markerId: const MarkerId('Start'),
                  icon: icStart,
                  position: LatLng(GeoData.polyline01Fixed.points[0].latitude, GeoData.polyline01Fixed.points[0].longitude),
                  infoWindow: const InfoWindow(title: 'Start', snippet: '5 Star Rating'),
                );
        Marker end = Marker(
                  markerId: const MarkerId('End'),
                  icon: icEnd,
                  position: LatLng(GeoData.polyline01Fixed.points[GeoData.polyline01Fixed.points.length-1].latitude, GeoData.polyline01Fixed.points[GeoData.polyline01Fixed.points.length-1].longitude),
                  infoWindow: const InfoWindow(title: 'End', snippet: '5 Star Rating'),
                );
        markers.add(start);
        markers.add(end);
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
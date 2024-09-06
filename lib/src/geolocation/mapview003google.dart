//https://medium.com/@samra.sajjad0001/a-comprehensive-guide-to-using-google-maps-in-flutter-3fbc0f7d469e
//https://pub.dev/packages/google_maps_flutter

import 'dart:async'; 
import 'package:flutter/material.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart' ; 
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:provider/provider.dart';
import '../maintabs/cards/mapcard.dart';
import '../shared/appconfig.dart'; 
import '../widgets/toggleicon.dart';
import 'geodata.dart';
import 'locationnotifier.dart';

class MapView003 extends StatefulWidget {
  const MapView003({super.key});

  @override
  State<MapView003> createState() => MapSampleState();
}

class MapSampleState extends State<MapView003> {
  late LocationNotifier providerLocNoti ;
  bool refreshing = false; 
  final Completer<GoogleMapController> _controller =Completer<GoogleMapController>();
  BitmapDescriptor icStart = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  @override
  void initState() {
    super.initState();
    GeoData.defaultMap=1;
    GeoData.centerMap=true;
    setState(() {
    providerLocNoti = Provider.of<LocationNotifier>(context,listen: false);
    });
    if (GeoData.tripStarted){
              KeepScreenOn.turnOn();
    }
    //_setCustomMarker();
  }

  // Load the custom marker image
  Future<void> _setCustomMarker() async {
    icStart = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(3, 3)),
      "assets/images/blue.png",
    );
    setState(() {});
  }


  @override
  Widget build(BuildContext context) { 

    return Consumer<LocationNotifier>(
      builder: (context, provider , child) { 
    return 
    Scaffold(
      body: Stack(
            children: [
      GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
              target: LatLng(GeoData.currentLat, GeoData.currentLng),
              zoom: GeoData.zoom,

        ),
        markers: Set<Marker>.from(addMarkers()),
        polylines: Set<Polyline>.from(addPolylines()),
        onMapCreated: (GoogleMapController controller) { 
          if (_controller.isCompleted == false){
            _controller.complete(controller);
          } 
          GeoData.gmapReady = true;
        },
        onTap: (LatLng latLng) { 
        },
        onCameraMoveStarted: () { 
        },
        onCameraIdle: () {  
        },
                onLongPress: (LatLng latLng) { 
                  GeoData.centerMap=false;
                  setState(() {
                  });
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
            child: mapcard(providerLocNoti.tripdata,transparent: true, fcolor: Colors.orange, fsize: 32),
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
                  child: Text("${GeoData.showLatLng?'(${GeoData.counter})':''} ${GeoData.showLatLng?GeoData.currentLat:''} ${GeoData.showLatLng?GeoData.currentLng:''} v${AppConfig.shared.appVersion} ", style: const TextStyle(fontSize: 12,color: Colors.red))
      ),
      ],), 
      // ),
    );
    });
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
  Widget debugCircle() {
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


      if (GeoData.centerMap){
        _controller.future.then(
          (controller) {
            controller.moveCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(GeoData.currentLat, GeoData.currentLng), zoom: GeoData.zoom,)
            )); 
          }
        );
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
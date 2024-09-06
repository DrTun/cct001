import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart' ; 
import '/src/geolocation/geodata.dart';  
import 'package:provider/provider.dart';   
import '../maintabs/cards/mapcard.dart';
import '../shared/appconfig.dart'; 
import '../widgets/toggleicon.dart';
import 'locationnotifier.dart';
class MapView002Google extends StatefulWidget {
  const MapView002Google({super.key});
  @override
  State<MapView002Google> createState() => MapView002GoogleState();
}
class MapView002GoogleState extends State<MapView002Google> {  
  int movingCount =0;
  bool moving=false;
  final Completer<GoogleMapController> completer =Completer<GoogleMapController>();
  late LocationNotifier providerLocNoti ;
  BitmapDescriptor icStart = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);

  @override
  void initState() {
    super.initState();
    // Add polyline
    setState(() {
    providerLocNoti = Provider.of<LocationNotifier>(context,listen: false);
    });
  }
  void _moveCamera(){
      if (GeoData.centerMap){
        completer.future.then(
          (controller) {
            if (movingCount>5){
                moving=true;
                controller.moveCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(target: LatLng(GeoData.currentLat, GeoData.currentLng), zoom: GeoData.zoom,)
                ));
            movingCount=0;
            Timer(const Duration(seconds: 1), () {moving = false;});
            } else {
                movingCount++;
            } 
          }
        );
      }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationNotifier>(
      builder: (consumeContext, model, child) {
        _moveCamera();
        if (GeoData.currentLat!=0 && GeoData.currentLng!=0) { 
          return Scaffold(
            body: Stack(
              children: [
              GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: Set<Marker>.from(addMarkers()),
                polylines: Set<Polyline>.from(addPolylines()),
                mapType: MapType.normal,
                minMaxZoomPreference: const MinMaxZoomPreference(10, 17.5),
                initialCameraPosition: CameraPosition(
                  target: LatLng(GeoData.currentLat, GeoData.currentLng),
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) { 
                  if (completer.isCompleted == false){ completer.complete(controller); } 
                },
                onCameraMove: (CameraPosition position) {
                  if (!moving) { GeoData.centerMap = false; }
                },
                onTap: (LatLng latLng) {   },
                onLongPress: (LatLng latLng) {  }, 
                onCameraMoveStarted: () { }, 
                onCameraIdle: () {  },
              ),
              Positioned( 
                    right: 10,
                    top: 10,
                    child: SizedBox( 
                          width:220,
                          height: 150,
                    child: mapcard(providerLocNoti.tripdata,transparent: true, fcolor: Colors.orange, fsize: 32),
                    )
              ),
              Positioned( 
                          left: 15,
                          bottom: 25,
                          child: reCenter()),
              Positioned( 
                          left: 15,
                          bottom: 100,
                          child: debugGeoData()),
              Positioned( 
                          left: 10,
                          bottom: 0,
                          child: GeoData.showLatLng? Text("${GeoData.counter} ${GeoData.currentLat} ${GeoData.currentLng} v${AppConfig.shared.appVersion} ", 
                          style: const TextStyle(fontSize: 12,color: Colors.red, backgroundColor: Colors.white), )
                          : const SizedBox(width: 0, height: 0,)
              ),
             Positioned(
                          right: 10,
                          top: 180,
                          child: SpeedDial(
                              
                              icon: Icons.apps,
                              backgroundColor: const Color.fromARGB(255, 126, 149, 174),
                              foregroundColor: Colors.white,
                              direction: SpeedDialDirection.down,
                              
                              children: [
                                SpeedDialChild(
                                  child: const Icon(Icons.receipt_long_outlined ),
                                  label: 'Receipt',
                                  onTap: () => (),
                                ),SpeedDialChild(
                                  child: const Icon(Icons.difference_outlined ),
                                  label: 'Charges and Fees',
                                  onTap: () => (),
                                ),
                                
                                SpeedDialChild(
                                  child: const Icon(Icons.control_camera ),
                                  label: GeoData.centerMap?'Auto center Off':'Auto center On',
                                  onTap: () => recenter(),
                                ),
                                SpeedDialChild(
                                  visible: !GeoData.tripStarted,
                                  child: const Icon(Icons.delete_outline),
                                  label: 'Clear Trip',
                                  onTap: () => clearTrip(),
                                ), 
                                SpeedDialChild(
                                  child: const Icon(Icons.closed_caption_off ),
                                  label: GeoData.showLatLng?'Debug on':'Debug off',
                                  onTap: () => debug(),
                                ),
                                ],
                          ),
              ),

              ]
            ),

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
  void clearTrip () {  
    GeoData.clearTrip();
  }
  Widget reCenter() {
    return  
      ToggleIcon(
          value: GeoData.centerMap, 
          iconOn: const Icon(Icons.control_camera , color: Colors.white,), 
          iconOff: const Icon(Icons.control_camera_sharp , color: Colors.white,),
          onClick: ()  {recenter();
          },
      );
  }
  void recenter() {
    setState(() {
        if (GeoData.centerMap) {GeoData.centerMap=false ;} else { GeoData.centerMap=true;}
    });
  }
  Widget debugGeoData() {
    return  
      ToggleIcon(
          value: GeoData.showLatLng, 
          iconOn: const Icon(Icons.closed_caption_off_outlined , color: Colors.white,), 
          iconOff: const Icon(Icons.closed_caption_disabled_outlined, color: Colors.white,),
          onClick: ()  { debug();},
      );
  }
  void debug(){
      setState(() {
          if (!GeoData.showLatLng) {GeoData.showLatLng=true;} else {GeoData.showLatLng=false;}
      });
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

 
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../maintabs/cards/mapcard.dart';
import '../widgets/toggleicon.dart';
import '/src/shared/appconfig.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:latlong2/latlong.dart'; 
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
  bool mapReady=false;
  late LocationNotifier providerLocNoti ;
  final List<Marker> markers = [];
  final List<Polyline> polylines = [];
  //late MapController mapctrl; 
  final  mapctrl = MapController(); 
  bool switchon = GeoData.tripStarted;
  final ValueNotifier<bool> isStartValue = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    GeoData.defaultMap=0;
    GeoData.centerMap=true;
    setState(() {
    //provider = Provider.of<MyNotifier>(context,listen: false);
    providerLocNoti = Provider.of<LocationNotifier>(context,listen: false);
    });
    if (GeoData.tripStarted){
              KeepScreenOn.turnOn();
    }
  }
@override
Widget build(BuildContext context) {
    return Consumer<LocationNotifier>(
      builder: (context, provider , child) {
      mapReady=false;
      double lat =GeoData.currentLat; 
      double lng =GeoData.currentLng;
      return Scaffold(
          body: Stack(
            children: [ 
            FlutterMap(
              mapController: mapctrl,
              options:   MapOptions(
                initialCenter: LatLng(lat, lng),                   // Initial zoom level
                minZoom: 9.0,                 // Minimum zoom level
                maxZoom: 18.0,  
                initialZoom: GeoData.zoom,               // Maximum zoom level  
                onPositionChanged: (position, hasGesture) {
                  GeoData.zoom=position.zoom;
                  if (hasGesture) {
                    setState(() {GeoData.centerMap=false;});
                  }
                },
                onMapReady: () {
                  mapReady=true;
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
            top: 5,
            child: SizedBox(
                  width: MediaQuery.of(context).size.width -10,
                  height: 150,
            child: mapcard(transparent: true, fcolor: Colors.lightGreenAccent, fsize: 32),
            )
      ),
            Positioned( 
                  left: 10,
                  bottom: 25,
                  child: reCenter()),
            Positioned( 
                  left: 10,
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
                          top: 160,
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
            ],
          ),
        );
  });
}
    void clearTrip () {  
    GeoData.clearTrip();
  }
  
  List<Marker> addMarkers() { 
      markers.clear();
      if (GeoData.points01Fixed.isNotEmpty){
        markers.add(Marker(
          point: LatLng(GeoData.points01Fixed[0].latitude, GeoData.points01Fixed[0].longitude), 
          width: 15,height: 15,alignment: Alignment.center,
          child: Image.asset('assets/images/geo/bluedot.png',scale: 1.0,),
          ));
         if (!GeoData.tripStarted) {
           markers.add(Marker(
           point: LatLng(GeoData.points01Fixed[GeoData.points01Fixed.length-1].latitude, 
              GeoData.points01Fixed[GeoData.points01Fixed.length-1].longitude), 
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
      if (mapReady && GeoData.centerMap){
        mapctrl.move(LatLng(GeoData.currentLat, GeoData.currentLng),GeoData.zoom);
      }
    return markers;
  }  
  List<Polyline> addPolylines() { 
    polylines.clear();
    if (GeoData.showLatLng) {
      polylines.add(
        

        Polyline(points: GeoData.points01Fixed, color: Colors.blue,strokeWidth: GeoData.fixedThickness,)
      
      );
      polylines.add( 
        Polyline(points: GeoData.points01, color: Colors.red,strokeWidth: GeoData.oriThickness,)
      );
    } else {
      polylines.add(
        Polyline(points: GeoData.points01Fixed, color: Colors.blue,strokeWidth: GeoData.fixedThickness,)
      );
    }
    return polylines;
  }
  Widget speed() {
    return 
    Text("${GeoData.currentSpeed(GeoData.points01,GeoData.dtimeList01,5).toStringAsFixed(0)} km/h", style: const TextStyle(fontSize: 12,color: Colors.red));
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
          onClick: ()  {
            debug();
          },
      );
  }
  void debug(){
      setState(() {
          if (!GeoData.showLatLng) {GeoData.showLatLng=true;} else {GeoData.showLatLng=false;}
      });
  }
}
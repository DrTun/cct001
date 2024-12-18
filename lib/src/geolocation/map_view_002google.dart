import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../modules/flaxi/helpers/group_service.dart';
import '../modules/flaxi/views/rate_scheme_view.dart';
import '../helpers/helpers.dart';
import '../socket/socket_service.dart';
import '../views/view_userinput_fromto.dart';
import 'geo_data.dart';
import 'package:provider/provider.dart';
import '../maintabs/cards/mapcard.dart';
import '../shared/app_config.dart';
import '../widgets/toggle_icon.dart';
import 'location_notifier.dart';

class MapView002Google extends StatefulWidget {
  const MapView002Google({super.key});
  @override
  State<MapView002Google> createState() => MapView002GoogleState();
}

class MapView002GoogleState extends State<MapView002Google> {
  int movingCount = 0;
  bool stillMoving = true;
  final Completer<GoogleMapController> completer =
      Completer<GoogleMapController>();
  late LocationNotifier providerLocNoti;
  BitmapDescriptor icBlue =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  BitmapDescriptor icOrange =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);

  @override
  void initState() {
    super.initState();
    setState(() {
      providerLocNoti = Provider.of<LocationNotifier>(context, listen: false);
    });
  }

  void _moveCamera() {
    if (GeoData.centerMap) {
      completer.future.then((controller) async {
        if (movingCount > 5) {
          stillMoving = true;
          GeoData.zoom = await controller.getZoomLevel();
          controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(GeoData.currentLat, GeoData.currentLng),
            zoom: GeoData.zoom,
          )));
          movingCount = 0;
          Timer(const Duration(seconds: 1), () {
            stillMoving = false;
          });
        } else {
          movingCount++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationNotifier>(
      builder: (consumeContext, model, child) {       
        _moveCamera();
        if (GeoData.currentLat != 0 && GeoData.currentLng != 0) {
          return Scaffold(
            body: Stack(children: [
              GoogleMap(
                padding:GeoData.fromto? const EdgeInsets.only(top: 200,left: 30,right: 30,bottom: 50): const EdgeInsets.all(0),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: Set<Marker>.from(addMarkers()),
                // polylines: Set<Polyline>.from(addPolylines()),
                polylines: Set<Polyline>.from(addPolylines()),
                mapType: MapType.normal,
                //minMaxZoomPreference: const MinMaxZoomPreference(3.9, 17.5),
                initialCameraPosition: CameraPosition(
                  target:LatLng(GeoData.currentLat, GeoData.currentLng)  ,
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) {
                  if (completer.isCompleted == false) {
                    completer.complete(controller);
                  }
                  if(GeoData.fromto) {
                    LatLngBounds bounds = GeoData.getLatLngBounds(GeoData.fromtotrip.pointsfromto);
                    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 5);
                    controller.animateCamera(cameraUpdate);
                  }
                },
                onCameraMove: (CameraPosition position) {
                  if (!stillMoving) {
                    GeoData.centerMap = false;
                  }               
                },
                onTap: (LatLng latLng) {},
                onLongPress: (LatLng latLng) {},
                onCameraMoveStarted: () {},
                onCameraIdle: () {},
              ),
              Positioned(
                  right: 10,
                  top: 5,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 15,
                    height: 150,
                    child: mapcard(context,
                        transparent: true,
                        fcolor: Colors.lightGreenAccent,
                        fsize: 32),
                  )),
              Positioned(left: 15, bottom: 25, child: reCenter()),
              Positioned(left: 15, bottom: 95, child: userInputFromto(context)),
              GroupService.gpType != 0 ? Positioned(left: 15, top: 160, child:GeoData.currentTrip.started?  waitingCharge(context) : const SizedBox()): const SizedBox(),
             // Positioned(left: 15, bottom: 165,child: socketIndicator(),),
              Positioned(
                  left: 10,
                  bottom: 0,
                  child: GeoData.showLatLng
                      ? Text(
                          "${GeoData.counter} ${GeoData.currentLat} ${GeoData.currentLng} v${AppConfig.shared.appVersion} ${GeoData.socketMesStatus} ",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              backgroundColor: Colors.white),
                        )
                      : const SizedBox(
                          width: 0,
                          height: 0,
                        )),
              Positioned(
                  right: 25,
                  top: 220,
                  child: Text(
                    AppConfig.shared.appVersion,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  )),
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
                      child: const Icon(Icons.receipt_long_outlined),
                      label: 'Receipt',
                      onTap: () => (),
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.difference_outlined),
                      label: 'Charges and Fees',
                      onTap: () => (),
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.control_camera),
                      label: GeoData.centerMap
                          ? 'Auto center Off'
                          : 'Auto center On',
                      onTap: () => recenter(),
                    ),
                    SpeedDialChild(
                      visible: !GeoData.currentTrip.started,
                      child: const Icon(Icons.delete_outline),
                      label: 'Clear Trip',
                      onTap: () => clearTrip(),
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.closed_caption_off),
                      label: GeoData.showLatLng ? 'Debug on' : 'Debug off',
                      onTap: () => debug(),
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.monetization_on),
                      label: "Rate",
                      onTap: () {
                        // RateChangeHelper().showRateSelectionDialog(context);
                        Navigator.pushNamed(context, RateSchemeView.routeName);

                      },
                    ),
                  ],
                ),
              ),
            ]),
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

  void clearTrip() {
    GeoData.clearTrip();
  }

  Widget reCenter() {
    return ToggleIcon(
      value: GeoData.centerMap,
      iconOn: const Icon(
        Icons.control_camera,
        color: Colors.white,
      ),
      iconOff: const Icon(
        Icons.control_camera_sharp,
        color: Colors.white,
      ),
      onClick: () {
        recenter();
      },
    );
  }

  void recenter() {
    setState(() {
      if (GeoData.centerMap) {
        GeoData.centerMap = false;
      } else {
        GeoData.centerMap = true;
      }
    });
  }

  Widget userInputFromto(BuildContext context) {
    return CircleAvatar(
      backgroundColor: GeoData.fromto ? Colors.blue : Colors.grey,
      child: IconButton(
        icon: const Icon(
          Icons.directions,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            MyStore.prefs.setBool("fromto", false);
            GeoData.fromtotrip.pointsfromto.clear();
            if (GeoData.fromto) {
              GeoData.fromto = !GeoData.fromto;
            } else {
              Navigator.of(context).pushNamed(UserInputFromTo.routename);
            }
          });
        },
      ),
    );
  }

  Widget waitingCharge(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width  = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {         
          setState((){
              GeoData.waiting = !GeoData.waiting;
          });
          if(GeoData.waiting) {         
            GeoData.waitingTrip.pointsFixed.clear(); 
            GeoData.currentTrip.wdtimer = DateTime.now();
            
          } else {
            GeoData.wtimeadd = GeoData.wtimeadd + GeoData.tmd;
            
          }               
      },
      child: Container(
        padding: const EdgeInsets.only(left:5,right:5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black.withOpacity(0.6),
        ),
        height: height *0.055,
        width:GeoData.waiting?  width*0.4 :width* 0.12,
        child:GeoData.waiting?  Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.timer_outlined,size: 25,color: Colors.lightGreenAccent ,),
            ),
            Text(MyHelpers.formatTime(GeoData.waitduration()+GeoData.wtimeadd,sec: true),style:  const TextStyle(fontFamily: "Digital",fontSize: 32,height: 1,color: Colors.lightGreenAccent), textAlign: TextAlign.right) ,
          ],
        )
        : const Icon( Icons.timer_outlined,size: 25,color: Colors.white ,)
        ,
      ),
    );
  }
  
  Widget debugGeoData() {
    return ToggleIcon(
      value: GeoData.showLatLng,
      iconOn: const Icon(
        Icons.closed_caption_off_outlined,
        color: Colors.white,
      ),
      iconOff: const Icon(
        Icons.closed_caption_disabled_outlined,
        color: Colors.white,
      ),
      onClick: () {
        debug();
      },
    );
  }

  Widget socketIndicator() {
    return ToggleIcon(
      value: GeoData.isTransmitting,
      iconOn: const Icon(
        Icons.cloud_done, // Icon for connected
        color: Colors.white,
      ),
      iconOff: const Icon(
        Icons.cloud_off, // Icon for disconnected
        color: Colors.white,
      ),
      onClick: () {
        GeoData.isTransmitting ? () {} : reConnect();
      },
    );
  }

  void reConnect() {
    SocketService().connect();
  }

  void debug() {
    setState(() {
      if (!GeoData.showLatLng) {
        GeoData.showLatLng = true;
      } else {
        GeoData.showLatLng = false;
      }
    });
  }

  List<Marker> addMarkers() {
    List<Marker> markers = [];
    if (GeoData.currentTrip.started) {
      if (GeoData.currentTrip.pointsFixed.isNotEmpty) {
        Marker start = Marker(
          markerId: const MarkerId('Start'),
          icon: icBlue,
          position: LatLng(GeoData.currentTrip.pointsFixed[0].latitude,
              GeoData.currentTrip.pointsFixed[0].longitude),
          infoWindow: const InfoWindow(title: 'Start', snippet: 'ongoing trip'),
        );
        markers.add(start);
      }
    } else {
      if (GeoData.previousTrip.pointsFixed.isNotEmpty) {
        Marker start = Marker(
          markerId: const MarkerId('Start'),
          icon: icBlue,
          position: LatLng(GeoData.previousTrip.pointsFixed[0].latitude,
              GeoData.previousTrip.pointsFixed[0].longitude),
          infoWindow:
              const InfoWindow(title: 'Start', snippet: 'previous trip'),
        );
        markers.add(start);

        Marker end = Marker(
          markerId: const MarkerId('End'),
          icon: icOrange,
          position: LatLng(
              GeoData
                  .previousTrip
                  .pointsFixed[GeoData.previousTrip.pointsFixed.length - 1]
                  .latitude,
              GeoData
                  .previousTrip
                  .pointsFixed[GeoData.previousTrip.pointsFixed.length - 1]
                  .longitude),
          infoWindow: const InfoWindow(title: 'End', snippet: 'previous trip'),
        );
        markers.add(end);
      }
    }
    return markers;
  }

  List<Polyline> addPolylines() {
    List<Polyline> polylines = [];

    List<LatLng> plistfixed = [];
    for (var point in GeoData.currentTrip.pointsFixed) {
      plistfixed.add(LatLng(point.latitude, point.longitude));
    }
    Polyline fixed = Polyline(
      polylineId: const PolylineId('fixed'),
      color: Colors.blue,
      points: plistfixed,
      width: GeoData.fixedThickness.toInt(),
    );

    List<LatLng> plist = [];
    for (var point in GeoData.currentTrip.points) {
      plist.add(LatLng(point.latitude, point.longitude));
    }
    Polyline original = Polyline(
      polylineId: const PolylineId('original'),
      color: Colors.red,
      points: plist,
      width: GeoData.oriThickness.toInt(),
    );

    List<LatLng> plistpre = [];
    for (var point in GeoData.previousTrip.pointsFixed) {
      plistpre.add(LatLng(point.latitude, point.longitude));
    }
    Polyline previous = Polyline(
      polylineId: const PolylineId('previous'),
      color: Colors.purple,
      points: plistpre,
      width: GeoData.fixedThickness.toInt(),
    );

    List<LatLng> fromto = [];
    for (var point in GeoData.fromtotrip.pointsfromto) {
      fromto.add(LatLng(point.latitude, point.longitude));
    }
    Polyline fromt = Polyline(
      polylineId: const PolylineId('fromto'),
      color: Colors.green,
      points: fromto,
      width: GeoData.fixedThickness.toInt(),
    );
    polylines.clear();
    if (GeoData.fromto) {
      polylines.add(fromt);
    }
    if (GeoData.showLatLng) {
      if (GeoData.currentTrip.started) {
        polylines.add(fixed);
        polylines.add(original);
      } else {
        polylines.add(previous);
      }
    } else {
      if (GeoData.currentTrip.started) {
        polylines.add(fixed);
      } else {
        polylines.add(previous);
      }
    }
    return polylines;
  }
}

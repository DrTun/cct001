import 'package:flutter/material.dart';
import '/src/geolocation/geodata.dart';
import '/src/geolocation/locationnotifier.dart';
import '/src/helpers/helpers.dart';
import '/src/widgets/switchon.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:provider/provider.dart';

class SwitchonTrip extends StatefulWidget {
  final String label;
  const SwitchonTrip({required this.label, super.key,});

  @override
  SwitchonTripState createState() => SwitchonTripState();
}
class SwitchonTripState extends State<SwitchonTrip> {
  // Initialize the switch state based on GeoData
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationNotifier>(
        builder: (context, locationNotifier, child) {
      return SwitchOn(
        value: locationNotifier.tripdata.started,
        label: widget.label,
        onClick: () async {
        //  setState(() {
            if (locationNotifier.tripdata.started) {
              if (GeoData.tripDuration()>(60)){
                MyHelpers.getBool(context, "Are you sure to end trip?").then((value) => {
                      if (value != null && value) {
                          endIt(locationNotifier)
                      }
                });
              } else {
                          endIt(locationNotifier); 
              }
            } else {
              // MyHelpers.getBool(context, "Are you sure to start trip?").then((value) => {
              //       if (value != null && value) {
              //           startIt(locationNotifier)
              //       }
              // });
              startIt(locationNotifier);
            }
         // });
        },
      );
    });
  }
  void endIt(LocationNotifier locationNotifier){
              GeoData.endTrip();
              locationNotifier.updateTripStatus(false);
              MyStore.prefs.setBool("tripStarted", false);
              KeepScreenOn.turnOff();
  }
  
  void startIt(LocationNotifier locationNotifier){
              GeoData.polyline01.points.clear();
              GeoData.polyline01Fixed.points.clear();
              GeoData.dtimeList01.clear();
              GeoData.dtimeList01Fixed.clear();
              locationNotifier.updateTripData(true, 0, 0, 0, 0);
              GeoData.startTrip(locationNotifier);
              MyStore.prefs.setBool("tripStarted", true);
              KeepScreenOn.turnOn();
  }
}



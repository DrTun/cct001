import 'package:flutter/material.dart';
import '../shared/appconfig.dart';
import '/src/geolocation/geodata.dart';
import '/src/geolocation/locationnotifier.dart';
import '/src/helpers/helpers.dart';
import '/src/widgets/switchon.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:provider/provider.dart';

class SwitchonTrip extends StatefulWidget {
  final String label;
  const SwitchonTrip({
    required this.label,
    super.key,
  });

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
        value: GeoData.currentTrip.started,
        label: widget.label,
        onClick: () async {
          if (GeoData.currentTrip.started) {
              if (GeoData.tripDuration()>(GeoData.mintripDuration)){    // more than 60s
              // more than 60s
              MyHelpers.getBool(context, "Are you sure to end trip?")
                  .then((value) => {
                        if (value != null && value)
                          {
                            endIt(locationNotifier),
                            if (AppConfig.shared.saveTrip)
                              {
                                MyTripDBOperator().saveTripToDB(),
                              }

                            // The Trip Data is to be saved in the database
                          }
                      });
            } else {
              GeoData.clearTripPrevious;
              GeoData.clearTrip();
              setState(() {}); // discard the current data
              endIt(locationNotifier); // less than 60s, GeoData.mintripDuration
            }
          } else {
            startIt(locationNotifier);
          }
        },
      );
    });
  }

  void endIt(LocationNotifier locationNotifier) {
    GeoData.endTrip();
    locationNotifier.notify();
    MyStore.prefs.setBool("currentTrip.started", false);
    KeepScreenOn.turnOff();
    setState(() {});
  }

  void startIt(LocationNotifier locationNotifier) {
    GeoData.centerMap = true;
    GeoData.clearTrip();
    locationNotifier.notify();
    GeoData.startTrip(locationNotifier);
    MyStore.prefs.setBool("currentTrip.started", true);
    KeepScreenOn.turnOn();
    setState(() {});
  }
}

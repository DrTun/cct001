import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../geolocation/geo_address.dart';
import '../../geolocation/geo_data.dart';
import '../../geolocation/map_widget.dart';
import '../../geolocation/map_widget_google.dart';
import '../../helpers/helpers.dart';
import '../../shared/app_config.dart';
import '../../sqflite/trip_model.dart';


class Tripdetails extends StatefulWidget {
  static const routeName = '/tripsDetail';
  final TripModel trip;

  const Tripdetails({super.key, required this.trip});

  @override
  State<Tripdetails> createState() => _TripdetailsState();
}

class _TripdetailsState extends State<Tripdetails> {
  GeoAddress geo = GeoAddress();
  String startLocName = '';
  String endLocName = '';

  @override
  void initState() {
    getLocName(widget.trip.route.first, widget.trip.route.last);
    super.initState();
  }

  Future<void> getLocName(LatLng startPoint, LatLng endPoint) async {
    startLocName =
        await geo.getPlacemarks(startPoint.latitude, startPoint.longitude);
    endLocName = await geo.getPlacemarks(endPoint.latitude, endPoint.longitude);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final textColor = Theme.of(context).colorScheme.onSurface;
    final iconColorFrom = Colors.blue.shade300;
    final iconColorTo = Colors.orange.shade300;

    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const SizedBox(height: 12.0),
              const Text(
                'Trip Info',
              ),
              const SizedBox(height: 2.0),
              Text(
                AppConfig.shared.appVersion,
                style: const TextStyle(fontSize: 9.0, color: Colors.yellow),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Icon(Icons.location_pin, color: iconColorFrom),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      startLocName,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Icon(Icons.location_pin, color: iconColorTo),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      endLocName,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              GeoData.mapType == 1
                  ? mapWidget(
                      trip: widget.trip,
                      imageWidth: MediaQuery.of(context).size.width,
                      imageHeight: MediaQuery.of(context).size.height * 0.25)
                  : mapWidgetGoogle(
                      padding: const EdgeInsets.all(0),
                      trip: widget.trip,
                      imageWidth: MediaQuery.of(context).size.width,
                      imageHeight: MediaQuery.of(context).size.height * 0.25,
                      showMarker: true,
                      setMargin: 45,
                      lineThickness: 5,
                    ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              Center(
                child: Column(
                  children: [
                    Text(
                      'Ks ${MyHelpers.formatInt(int.parse(widget.trip.totalAmount))}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: AppConfig.shared.primaryColor,
                      ),
                    ),
                    Text(
                      'Total Cost',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        MyHelpers.formatDuration(
                            int.parse(widget.trip.tripDuration)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.047,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.grey,
                  ),
                  Column(
                    children: [
                      Text(
                        '${MyHelpers.formatDouble(double.parse(widget.trip.distance))} km',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.047,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Distance',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              Column(
                children: [
                  rowofOneValue(
                      context,
                      MyHelpers.formatTripDate(widget.trip.startTime),
                      'Date & Time',
                      MediaQuery.of(context).size.width * 0.04,
                      textColor),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  rowofOneValue(context, widget.trip.tripID, 'ID',
                      MediaQuery.of(context).size.width * 0.04, textColor)
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),

              //Extras charges
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cost',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.047,
                      )),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  rowofOneValue(
                      context,
                      '${MyHelpers.formatInt(int.parse(widget.trip.initial))} Ks',
                      'Intial',
                      MediaQuery.of(context).size.width * 0.04,
                      textColor),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  rowofOneValue(context, '+ ${widget.trip.rate} Ks', 'Waiting',
                      MediaQuery.of(context).size.width * 0.04, textColor)
                ],
              ),
            ]),
          ),
        ));
  }
}

Widget rowofOneValue(
  BuildContext context,
  String value,
  String label,
  double fontSize,
  Color textColor,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: fontSize, color: const Color(0xFF6B7280)),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

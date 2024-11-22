import 'package:flutter/material.dart';
import '../../geolocation/geo_address.dart';
import '../../geolocation/geo_data.dart';
import '../../geolocation/map_widget.dart';
import '../../geolocation/map_widget_google.dart';
import '../../helpers/helpers.dart';
import '../../shared/app_config.dart';
import '../../sqflite/trip_model.dart';
import 'package:latlong2/latlong.dart';


class Tripdetails extends StatefulWidget {
  static const routeName = '/tripsDetail';
  final TripModel trip;

  const Tripdetails({super.key, required this.trip});

  @override
  State<Tripdetails> createState() => _TripdetailsState();
}

class _TripdetailsState extends State<Tripdetails> {
  GeoAddress geo = GeoAddress();
  String startLocName = "";
  String endLocName = "";
  bool showDropdown = false;
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

    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const SizedBox(height: 12.0),
              const Text(
                "Trip Info",
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
                padding: EdgeInsets.all(MediaQuery.of(context).size.width *
                    0.04), // Responsive padding
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tripInfoRow(
                          context,
                          MyHelpers.formatTripDate(widget.trip.startTime),
                          'Date & Time',
                          MediaQuery.of(context).size.width * 0.04,
                          const Color(0xFF6B7280)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      GeoData.mapType == 1
                          ? mapWidget(
                              trip: widget.trip,
                              imageWidth: MediaQuery.of(context).size.width,
                              imageHeight:
                                  MediaQuery.of(context).size.height * 0.25)
                          : mapWidgetGoogle(
                              trip: widget.trip,
                              imageWidth: MediaQuery.of(context).size.width,
                              imageHeight:
                                  MediaQuery.of(context).size.height * 0.25,
                              showMarker: true,
                              setMargin: 45,
                              lineThickness: 5,
                              padding: const EdgeInsets.all(12)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Text(
                        'Trip Details',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            // color: Color(0xFF6B7280),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TripID',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                color: const Color(0xFF6B7280)),
                          ),
                          Flexible(
                            child: Text(
                              widget.trip.tripID,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'From',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                color: const Color(0xFF6B7280),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // const SizedBox(width: 5),
                          Text(
                            startLocName,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'To',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                color: const Color(0xFF6B7280),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // const SizedBox(width: 5),
                          Text(
                            endLocName,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      tripInfoRow(
                          context,
                          'MMK ${MyHelpers.formatInt(int.parse(widget.trip.totalAmount))}',
                          'Total(incl. Extras)',
                          MediaQuery.of(context).size.width * 0.04,
                          const Color(0xFF6B7280)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showDropdown = !showDropdown;
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('View Details'),
                                  Icon(showDropdown
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: showDropdown
                                  ? MediaQuery.of(context).size.height * 0.02
                                  : MediaQuery.of(context).size.height * 0.01,
                            ),
                            Visibility(
                              visible: showDropdown,
                              child: Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.02),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Description',
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.045,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          'Amount',
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            fontWeight: FontWeight.normal,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Extras', // Replace with your actual content
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                        Text(
                                          'MMK 1,000',
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (showDropdown)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ]))));
  }
}

Widget tripInfoRow(
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
        style: TextStyle(fontSize: fontSize, color: textColor),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.02,
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: fontSize,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

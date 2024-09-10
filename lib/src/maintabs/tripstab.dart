import 'package:flutter/material.dart';

import '../geolocation/geodata.dart';
import '../helpers/helpers.dart';
import '../sqflite/sqf_trip_helpers.dart';
import '../sqflite/sqf_trip_model.dart';
import '../widgets/datefilter.dart';
import '../widgets/mapImageWidget.dart';

class Trips extends StatefulWidget {
  const Trips({super.key});

  @override
  State<Trips> createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  final db = TripsDatabaseHelper.instance;
  String startDate = MyHelpers.ymdDateFormat(DateTime.now());
  String endDate = MyHelpers.ymdDateFormat(DateTime.now());
  final now = DateTime.now();
  bool isMapView = false;

  @override
  void initState() {
    getTrips(startDate, endDate);
    super.initState();
  }

  Future<List<TripModel>> getTrips(String startDate, String endDate) async {
    List<TripModel> trips = await db.getTripsByDate(startDate, endDate);
    //db.getTodayTrips();
    return trips;
  }

  void weekTriplist() {
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startDate = MyHelpers.ymdDateFormat(firstDayOfWeek);
    endDate = MyHelpers.ymdDateFormat(
        DateTime(now.year, now.month, now.day, 23, 59, 59));
    setState(() {
      getTrips(startDate, endDate);
    });
  }

  void monthTriplist() {
    final firstDayOfMonth =
        MyHelpers.ymdDateFormat(DateTime(now.year, now.month, 1));
    final lastDayOfMonth = MyHelpers.ymdDateFormat(
        DateTime(now.year, now.month + 1, 0, 23, 59, 59));
    startDate = firstDayOfMonth;
    endDate = lastDayOfMonth;
    setState(() {
      getTrips(firstDayOfMonth, lastDayOfMonth);
    });
  }

  void customFromTo(String fromDate, String toDate) async {
    startDate = fromDate;
    endDate = toDate;
    setState(() {
      getTrips(startDate, endDate);
    });
  }

  void todayTripList() async {
    startDate = MyHelpers.ymdDateFormat(DateTime.now());
    endDate = MyHelpers.ymdDateFormat(DateTime.now());
    setState(() {
      getTrips(startDate, endDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 15),
                  child: Popbutton(
                    today: todayTripList,
                    week: weekTriplist,
                    month: monthTriplist,
                    onDateRangeSelected: customFromTo,
                  ),
                ),
                GeoData.defaultMap == 0
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10, right: 15),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isMapView = !isMapView;
                            });
                          },
                          child: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).secondaryHeaderColor,
                              foregroundColor:
                                  Theme.of(context).cardTheme.surfaceTintColor,
                              child: Icon(
                                  size: 25,
                                  isMapView ? Icons.map : Icons.list,
                                  color: Colors.grey.shade500)),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                  future: getTrips(startDate, endDate),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<TripModel>> snapshot) {
                    if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return const Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            'Empty Trip!',
                            style: TextStyle(fontSize: 20),
                          ));
                    }

                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width *
                              0.02, // Dynamic horizontal padding
                          vertical: MediaQuery.of(context).size.height *
                              0.02, // Dynamic vertical padding
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width *
                                    0.04), // Dynamic padding
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01,
                                horizontal: MediaQuery.of(context).size.width *
                                    0.02), // Dynamic margin
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset:
                                      const Offset(0, 2), // Position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Map view widget
                                isMapView
                                    ? Padding(
                                        padding: EdgeInsets.only(right: MediaQuery.of(context).size.width *0.02), // Dynamic padding
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width *0.3, // Responsive width for map view
                                          height: MediaQuery.of(context).size.width *0.2, // Responsive height for map view
                                          child: mapImageView(
                                              trip: snapshot.data![index],
                                              imageWidth: 120,
                                              imageHeight: 70),
                                        ),
                                      )
                                    : const SizedBox(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      tripInfoRow(context,MyHelpers.formatTripDate(snapshot.data![index].startTime),Icons.calendar_today_outlined),
                                      SizedBox(height: MediaQuery.of(context).size.height *0.01), // Dynamic height
                                      tripInfoRow(context,"${MyHelpers.formatDouble(double.parse(snapshot.data![index].distance))} km",Icons.directions),
                                      SizedBox(height: MediaQuery.of(context).size
                                                  .height *0.01),
                                      tripInfoRow(context,MyHelpers.formatDuration(int.parse(snapshot.data![index].tripDuration)),Icons.access_time_sharp,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  }),
            ),
          ],
        ));
  }
}
Widget tripInfoRow(
  BuildContext context,
  String value,
  IconData icon,
) {
  return Row(
    children: [
      Icon(icon,color: Colors.grey,size: MediaQuery.of(context).size.width * 0.05, // Responsive icon size
      ),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          value,
        style: TextStyle(fontSize: MediaQuery.of(context).size.width *0.04, // Responsive text size
          ),
          overflow: TextOverflow.ellipsis, // Handle long text gracefully
        ),
      ),
    ],
  );
}

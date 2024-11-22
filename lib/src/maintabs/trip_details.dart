import 'package:flutter/material.dart';
import '../geolocation/geo_data.dart';
import '../geolocation/map_widget.dart';
import '../geolocation/map_widget_google.dart';
import '../helpers/helpers.dart';
import '../shared/app_config.dart';
import '../sqflite/extras_model.dart';
import '../sqflite/trip_model.dart';
import '../sqflite/trips_database_helper.dart';

class Tripdetails extends StatefulWidget {
  static const routeName = '/tripsDetail';
  final TripModel trip;

  const Tripdetails({super.key, required this.trip});

  @override
  State<Tripdetails> createState() => _TripdetailsState();
}

class _TripdetailsState extends State<Tripdetails> {
  final db = TripsDatabaseHelper.instance;
  List<ExtrasModel> extraList = [];
  bool isLoading = true;
  String wt = 'Waiting Time';
  String wg = 'Waiting Charges';

  @override
  void initState() {
    getExtra(widget.trip.tripID);
    super.initState();
  }

  Future<void> getExtra(id) async {
    extraList = await db.getExtrasByTripID(id);
    setState(() {
      isLoading = false;
    });
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
          padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.04), // Responsive padding
          child: isLoading
              ? const LinearProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        MyHelpers.formatTripDate(widget.trip.startTime),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: textColor, // Use theme text color
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Column(
                      children: [
                        
                        Row(
                          children: [
                            Icon(Icons.location_pin, color: iconColorFrom),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                widget.trip.startLocName,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        Row(
                          children: [
                            Icon(Icons.location_pin, color: iconColorTo),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                widget.trip.endLocName,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        buildCostRow(
                            context,
                            textColor,
                            textColor,
                            15,
                            FontWeight.w400,
                            15,
                            FontWeight.normal,
                            'Distance',
                            '${MyHelpers.formatDouble(double.parse(widget.trip.distance))} km'),
                        buildCostRow(
                            context,
                            textColor,
                            textColor,
                            15,
                            FontWeight.w400,
                            15,
                            FontWeight.normal,
                            "Duration",
                            MyHelpers.formatDuration(
                                int.parse(widget.trip.tripDuration))),
                        if (extraList.isNotEmpty)
                          ...extraList.map((extra) =>extra.name== wt? buildCostRow(
                                context,
                                textColor,
                                textColor,
                                15, // Font size for names
                                FontWeight.normal,
                                15, // Font size for amount
                                FontWeight.normal,
                              'Waiting Time', // Display the name of the extra
                              MyHelpers.formatWaitingTime(int.parse(extra.subTotal)), // Display formatted amount
                              ):const SizedBox()   ),
                        widget.trip.distanceAmount != "" &&
                                (int.parse(widget.trip.distanceAmount) >
                                    int.parse(widget.trip.initial))
                            ? buildCostRow(
                                context,
                                textColor,
                                textColor,
                                15,
                                FontWeight.w400,
                                15,
                                FontWeight.normal,
                                "Initial",
                                " ${MyHelpers.formatInt(int.parse(widget.trip.initial))} ${widget.trip.currency} ")
                            : const SizedBox(),
                        widget.trip.distanceAmount != "" &&
                                (int.parse(widget.trip.distanceAmount) >
                                    int.parse(widget.trip.initial))
                            ? buildCostRow(
                                context,
                                textColor,
                                textColor,
                                15,
                                FontWeight.w400,
                                15,
                                FontWeight.normal,
                                "Distance Charges",
                                " ${MyHelpers.formatInt(int.parse(widget.trip.distanceAmount) - int.parse(widget.trip.initial))} ${widget.trip.currency}")
                            : const SizedBox(),
                        if (extraList.isNotEmpty)
                          ...extraList.map((extra) =>extra.name== wg? buildCostRow(
                                context,
                                textColor,
                                textColor,
                                15, // Font size for names
                                FontWeight.normal,
                                15, // Font size for amount
                                FontWeight.normal,
                                extra.name , // Display the name of the extra
                              '${MyHelpers.formatInt(int.parse(extra.subTotal))} MMK', // Display formatted amount
                              ): const SizedBox()),
                        if (extraList.isNotEmpty)
                          ...extraList.map((extra) =>extra.name!= wg && extra.name != wt? buildCostRow(
                                context,
                                textColor,
                                textColor,
                                15, // Font size for names
                                FontWeight.normal,
                                15, // Font size for amount
                               // "${extra.name} x ${extra.qty}"
                                FontWeight.normal,
                                extra.type=='0'?  extra.name :"${extra.name} x ${extra.qty}", // Display the name of the extra
                              '${MyHelpers.formatInt(int.parse(extra.subTotal))} MMK', // Display formatted amount
                              ) : const SizedBox()),
                        widget.trip.totalAmount != "0"
                            ? Divider(thickness: 0.3, color: Colors.grey[400])
                            : const SizedBox(),
                        widget.trip.totalAmount != "0"
                            ? buildCostRow(
                                context,
                                textColor,
                                textColor,
                                MediaQuery.of(context).size.width * 0.05,
                                FontWeight.w500,
                                MediaQuery.of(context).size.width * 0.05,
                                FontWeight.w500,
                                "Total",
                                '${MyHelpers.formatInt(int.parse(widget.trip.totalAmount))} ${widget.trip.currency}')
                            : const SizedBox(),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    GeoData.mapType == 1
                        ? mapWidget(
                            trip: widget.trip,
                            imageWidth: MediaQuery.of(context).size.width,
                            imageHeight:
                                MediaQuery.of(context).size.height * 0.25)
                        : mapWidgetGoogle(
                            padding: const EdgeInsets.only(
                                top: 50, left: 40, right: 40, bottom: 30),
                            trip: widget.trip,
                            imageWidth: MediaQuery.of(context).size.width,
                            imageHeight:
                                MediaQuery.of(context).size.height * 0.25,
                            showMarker: true,
                            setMargin: 45,
                            lineThickness: 5,
                          ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              color: textColor),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

Widget buildCostRow(
    BuildContext context,
    Color labelColor,
    Color valueColor,
    double labelFSize,
    FontWeight labelFWeight,
    double valueFSize,
    FontWeight valueFWeight,
    String label,
    String value) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: 0, vertical: MediaQuery.of(context).size.width * 0.01),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFSize,
            fontWeight: labelFWeight,
            color: labelColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFSize,
            fontWeight: valueFWeight,
            color: valueColor,
          ),
        ),
      ],
    ),
  );
}

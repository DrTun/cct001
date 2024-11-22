import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/flaxi/api_data_models/groups_models.dart';
import '../modules/flaxi/helpers/group_service.dart';
import '../modules/flaxi/helpers/trip_service.dart';
import '../geolocation/geo_data.dart';
import '../geolocation/map_widget_google.dart';
import '../helpers/helpers.dart';
import '../modules/flaxi/api_data_models/rateby_groups_models.dart';
import '../modules/flaxi/helpers/wallet_helper.dart';
import '../providers/network_service_provider.dart';
import '../shared/app_config.dart';
import '../shared/global_data.dart';
import '../sqflite/trips_database_helper.dart';
import '../sqflite/trip_model.dart';
import '../widgets/date_filter.dart';
import '../geolocation/map_widget.dart';
import 'trip_details.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TripList extends StatefulWidget {
  const TripList({super.key});

  @override
  State<TripList> createState() => _TripListState();
}

class _TripListState extends State<TripList> with WidgetsBindingObserver {
  final db = TripsDatabaseHelper.instance;
  final networkService = NetworkServiceProvider();
  String startDate = '';
  String endDate = '';
  final now = DateTime.now();
  List<Icon> mapIcon = [
    Icon(size: 25, Icons.list, color: Colors.grey.shade500),
    Icon(size: 25, Icons.grid_on_rounded, color: Colors.grey.shade500),
    Icon(size: 25, Icons.map, color: Colors.grey.shade500),
  ];
  String date = 'Today';
  String domainID = '';
  List<Group>? groupDatalist = [];
  bool showall = true;
  int mapView = 1;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _loadSavedDates();
    _loadGroupList();
    if (GlobalAccess.userID.isNotEmpty) {
      getSavedTripAndSend();
    }

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      _clearSavedDates();
    }
  }

  void _loadGroupList() async {
    List<Group>? groupDataliststore = await MyStore.retrieveGroupList('GroupList');
    if(mounted){  
      setState(() {
      groupDatalist = groupDataliststore;
    });
  }
  }

  Future<void> _clearSavedDates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('startDate');
    await prefs.remove('endDate');
    await prefs.remove('dateText');
    await prefs.remove('tabint');
  }

  void _loadSavedDates() async {
    Group? groupId = await MyStore.retriveDrivergroup('drivergroupsys');
    if(mounted){
    setState(() {
      date = MyStore.prefs.getString('dateText') ?? 'Today';
      startDate = MyStore.prefs.getString('startDate') ??
          MyHelpers.ymdDateFormat(DateTime.now());
      endDate = MyStore.prefs.getString('endDate') ??
          MyHelpers.ymdDateFormat(DateTime.now());
      domainID = groupId!.syskey;
    });
    }
  }

  void _saveDates(String startDate, String endDate, date) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('dateText', date);
    prefs.setString('startDate', startDate);
    prefs.setString('endDate', endDate);
  }

  Future<List<TripModel>> getTrips(
      String startDate, String endDate, datet, domainID) async {
    _saveDates(startDate, endDate, date);
    List<TripModel> trips = await db.getTripsByDatewithDriverGroup(startDate, endDate, domainID);
    
    return trips;
  }

  Future<void> getSavedTripAndSend() async {
    List<TripModel> trips = await db.getSavedTrip();
    for (var trip in trips) {
      List<Extra> extras = await db.getExtraByTripID(trip.tripID);
      await NetworkServiceProvider.checkConnectionStatus();
      if (networkService.isOnline.value) {
        await TripService.sendTrip(trip,extras,true);
      }
      logger.i("Saved Trips: ${trips.length}");
    }
     updateWalletBalance();
    if (mounted) {
      setState(() {});
    }
  }

  void updateWalletBalance() {
    if (networkService.isOnline.value) {
    GroupService.fetchAndStoreGroups().then((_) {
      WalletData().initializeWallet();
    });
    }
  }

  void weekTriplist() {
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startDate = MyHelpers.ymdDateFormat(firstDayOfWeek);
    endDate = MyHelpers.ymdDateFormat(DateTime(now.year, now.month, now.day, 23, 59, 59));
    setState(() {
      date = 'This Week';
      getTrips(startDate, endDate, date, domainID);
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
      date = 'This Month';
      getTrips(firstDayOfMonth, lastDayOfMonth, date, domainID);
    });
  }

  void customFromTo(String fromDate, String toDate) async {
    startDate = fromDate.replaceAll(RegExp(r'-'), '');
    endDate = toDate.replaceAll(RegExp(r'-'), '');
    setState(() {
      date = 'Custom';
      getTrips(startDate, endDate, date, domainID);
    });
  }

  void todayTripList() async {
    startDate = MyHelpers.ymdDateFormat(DateTime.now());
    endDate = MyHelpers.ymdDateFormat(DateTime.now());
    setState(() {
      date = 'Today';
      getTrips(startDate, endDate, date, domainID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15),
                  child: Text(date,style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 5),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {setState(() {showall = !showall;});},
                          child: CircleAvatar(
                              backgroundColor: Colors.transparent,radius: 15,
                              child: Icon(showall ? Icons.arrow_right : Icons.arrow_left,color: AppConfig.shared.primaryColor,size: 28,))),
                    ),
                    Visibility(
                      visible: showall,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, right: 15),
                        child: GestureDetector(
                          onTap: () {
                            _showGroupList(context);
                          },
                          child: CircleAvatar(
                              backgroundColor:Theme.of(context).secondaryHeaderColor,
                              foregroundColor:Theme.of(context).cardTheme.surfaceTintColor,
                              child: Icon(size: 25,Icons.drive_eta_rounded,color: Colors.grey.shade500)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 15),
                      child: Popbutton(
                        today: todayTripList,
                        week: weekTriplist,
                        month: monthTriplist,
                        onDateRangeSelected: customFromTo,
                      ),
                    ),
                    Visibility(
                        visible: showall,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, right: 15),
                          child: GestureDetector(
                            onTap: () {
                              if (mapView == 2) {
                                setState(() { mapView = 0; });
                              } else {
                                setState(() { mapView += 1; });
                              }
                            },
                            child: CircleAvatar(
                                backgroundColor:Theme.of(context).secondaryHeaderColor,
                                foregroundColor: Theme.of(context).cardTheme.surfaceTintColor,
                                child: mapIcon[mapView]),),
                        ))
                  ],
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                  future: getTrips(startDate, endDate, date, domainID),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<TripModel>> snapshot) {
                    if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return Align(
                          alignment: Alignment.center,
                          child: Text(AppLocalizations.of(context)!.emptyTrip,style: const TextStyle(fontSize: 18),));
                          }
                    if (snapshot.hasData) {
                      return mapView == 0
                          ? TriplistListView(snapshot: snapshot, mapView: mapView)
                          : mapView == 1
                              ? TripListGridView( snapshot: snapshot, )
                              : mapView == 2
                                  ? TriplistListView( snapshot: snapshot, mapView: mapView)
                                  : const SizedBox();
                    }
                    return const SizedBox();
                  }),
            ),
          ],
        ));
  }
  Future<dynamic> _showGroupList(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return groupDatalist != null && groupDatalist!.isNotEmpty
              ? AlertDialog(
                  title: const Text("Select Group"),
                  content: SizedBox(
                    width: double.maxFinite, 
                    child: ListView.builder(
                      shrinkWrap:true, 
                      itemCount: groupDatalist!.length,
                      itemBuilder: (context, index) {
                        final list = groupDatalist?[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Card(
                            child: RadioListTile<String>(
                              title: Text(list!.name,style: const TextStyle(fontSize: 18),),
                              subtitle: Text(list.id),
                              value: list.syskey,
                              groupValue: domainID,
                              onChanged: (String? value) {
                                setState(() {domainID = value!;
                                  MyStore.storeDrivergroup(
                                      list, 'drivergroupsys');
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: const Text("Close"),
                    ),
                  ],
                )
              : const AlertDialog(
                  title: Text("Select Group"),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SizedBox(
                      height: 70,
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            Text("Data is Loading...")
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        });
  }
}

class TripListGridView extends StatelessWidget {
  final AsyncSnapshot<List<TripModel>> snapshot;
  const TripListGridView({
    required this.snapshot,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: snapshot.data!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (BuildContext context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                Tripdetails.routeName,
                arguments: snapshot.data![index],
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: snapshot.data![index].cloudStatus == "saved"
                      ? const Border(
                          top: BorderSide(width: 1.5, color: Colors.amber))
                      : const Border(),
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.surface, // Background adapts to light/dark mode
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(-1, -1),
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // Dark mode shadow
                      blurRadius: 1.0,
                    ),
                    BoxShadow(
                      offset: const Offset(1, 1),
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), // Dark mode shadow
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Map view widget
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.25,
                      child: GeoData.mapType == 1
                          ? mapWidget(trip: snapshot.data![index],imageWidth: 120,imageHeight: 70)
                          : mapWidgetGoogle(padding: const EdgeInsets.all(0),trip: snapshot.data![index],imageWidth: 120,imageHeight: 70,showMarker: false,setMargin: 1,lineThickness: 3,),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions,color: Colors.grey,size: MediaQuery.of(context).size.width * 0.05,),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  "${MyHelpers.formatDouble(double.parse(snapshot.data![index].distance))} km",
                                  style: TextStyle(fontSize:MediaQuery.of(context).size.width * 0.04,),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          snapshot.data![index].totalAmount != "0"
                              ? tripInfoRow(
                                  context,
                                  "${MyHelpers.formatInt(int.parse(snapshot.data![index].totalAmount))} ${snapshot.data![index].currency}",
                                  Icons.monetization_on_outlined,
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class TriplistListView extends StatefulWidget {
  final AsyncSnapshot<List<TripModel>> snapshot;
  final int mapView;
  const TriplistListView({
    super.key,
    required this.snapshot,
    required this.mapView,
  });

  @override
  State<TriplistListView> createState() => _TriplistListViewState();
}

class _TriplistListViewState extends State<TriplistListView> {
  @override
  Widget build(BuildContext context) {
    List<TripModel>? data = widget.snapshot.data!;
    return ListView.builder(
      itemCount: data.length,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      itemBuilder: (context, index) {
        final startlocName = data[index].startLocName.split(',')[0].trim();
        final endlocName = data[index].endLocName.split(',')[0].trim();
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context,Tripdetails.routeName,arguments: data[index],);
          },
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01,horizontal: MediaQuery.of(context).size.width * 0.01),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15.0),
              // refactor later
              border: data[index].cloudStatus == "saved"
                  ? const Border(top: BorderSide(width: 1.5, color: Colors.amber))
                  : const Border(),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.3),spreadRadius: 1,blurRadius: 5,offset: const Offset(0, 2),),
              ],
            ),
            child: widget.mapView == 2
                ? Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.25,
                      child: GeoData.mapType == 1
                          ? mapWidget(trip: data[index],imageWidth: 120,imageHeight: 70)
                          : mapWidgetGoogle(padding: const EdgeInsets.all(0),trip: data[index],imageWidth: 120,imageHeight: 70,showMarker: false,setMargin: 1,lineThickness: 3,),
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tripInfoRow(context,MyHelpers.formatTripDate(data[index].startTime),Icons.calendar_today_outlined),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        tripInfoRows(context,"${MyHelpers.formatDouble(double.parse(data[index].distance))} km",Icons.directions,MyHelpers.formatDuration(int.parse(data[index].tripDuration)),Icons.access_time_sharp,),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        Row(
                          children: [
                            Icon(Icons.monetization_on_outlined,color: Colors.grey,size: MediaQuery.of(context).size.width * 0.05,),
                            const SizedBox(width: 5),
                            data[index].totalAmount != "0"
                                ? Flexible(
                                    child: Text("${MyHelpers.formatInt(int.parse(data[index].totalAmount,))}  MMK",
                                      style: TextStyle(fontSize:MediaQuery.of(context).size.width * 0.04,),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ],
                    ))
                  ])
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(startlocName,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                                const Text( "  to  ",style: TextStyle(fontSize: 16,),),
                                Flexible(child: Text(endlocName,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600),overflow: TextOverflow.ellipsis,))
                              ],
                            ),
                            SizedBox(height:MediaQuery.of(context).size.height * 0.01),
                            tripInfoRow(context,MyHelpers.formatTripDate(data[index].startTime),Icons.calendar_today_outlined),
                            SizedBox(height:MediaQuery.of(context).size.height * 0.01),
                            Row(
                              children: [
                                Icon(Icons.directions,color: Colors.grey,size:MediaQuery.of(context).size.width * 0.05,),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    "${MyHelpers.formatDouble(double.parse(data[index].distance))} km",style: TextStyle(fontSize:MediaQuery.of(context).size.width * 0.04,),overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                Icon(Icons.access_time_sharp,color: Colors.grey,size:MediaQuery.of(context).size.width * 0.05,),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(MyHelpers.formatDuration(int.parse(data[index].tripDuration)),
                                    style: TextStyle(fontSize:MediaQuery.of(context).size.width *0.04,),overflow: TextOverflow.ellipsis,),
                                ),
                                const SizedBox(width: 10,),
                                Icon(Icons.monetization_on_outlined,color: Colors.grey,size:MediaQuery.of(context).size.width * 0.05,),
                                const SizedBox(width: 5),
                                data[index].totalAmount != "0"
                                    ? Flexible(
                                        child: Text("${MyHelpers.formatInt(int.parse(data[index].totalAmount,))}  MMK",
                                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04,),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

Widget tripInfoRow(BuildContext context,String value,IconData icon,) {
  return Row(
    children: [
      Icon(icon,color: Colors.grey,size: MediaQuery.of(context).size.width * 0.05,),
      const SizedBox(width: 5),
      Flexible(
        child: Text(value,style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04,),overflow: TextOverflow.ellipsis,),
      ),
    ],
  );
}

Widget tripInfoRows(BuildContext context,String value1,IconData icon1,String value2,IconData icon2,) {
  return Row(
    children: [
      Icon(icon1,color: Colors.grey,size: MediaQuery.of(context).size.width * 0.05,),
      const SizedBox(width: 5),
      Flexible(
        child: Text(value1,style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04,),overflow: TextOverflow.ellipsis,),
      ),
      const SizedBox(width: 10),
      Icon(icon2,color: Colors.grey,size: MediaQuery.of(context).size.width * 0.05,),
      const SizedBox(width: 5),
      Flexible(
        child: Text(value2,style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04,),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

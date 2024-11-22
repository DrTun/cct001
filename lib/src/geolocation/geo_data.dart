import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:uuid/uuid.dart';
import '../modules/flaxi/api/api_data_service_flaxi.dart';
import '../modules/flaxi/api_data_models/rateby_groups_models.dart';
import '../modules/flaxi/helpers/rate_change_helpers.dart';
import '../shared/app_config.dart';
import '../shared/global_data.dart';
import '../socket/socket_data_model.dart';
import '../socket/socket_service.dart';
import 'location_notifier.dart';
import 'package:latlong2/latlong.dart';
import '/src/helpers/helpers.dart';
import 'package:location/location.dart';

//  -------------------------------------    GeoData (Property of Nirvasoft.com)
class GeoData {
  // Properties
  String tripId = "";
  String source = "";
  String destination = "";
  String rate = "";
  String initial = "";
  String domainId = "";
  double distance = 0;
  double currentSpeed = 0;
  int duration = 0;
  int distanceAmount = 0;
  DateTime startTime = DateTime.now();
  bool started = false;
  DateTime endTime = DateTime.now();
  bool ended = false;
  String tripStatus = "1"; // 1 = notrip, 2= ongoing trip, 3= tripended
  List<LatLng> points = []; // Previous Trip
  List<DateTime> dtimeList = [];
  List<LatLng> pointsFixed = []; // Previous Trip
  List<LatLng> waitingPoints = [];
  double totalWdistance = 0;

  static bool fromto = false;
  List<LatLng> pointsfromto = [];
  List<dynamic> listforplaces = [];
  PolylinePoints polylinePoints = PolylinePoints();

  List<DateTime> dtimeListFixed = [];
  void clear() {
    points.clear();
    dtimeList.clear();
    pointsFixed.clear();
    dtimeListFixed.clear();
  }

  // GPS Data
  static int counter = 0; // debugging purpose
  List<LatLng> raws = [];
  static int socketMesStatus = 0;

  // Send to Server and local location updates
  static double currentLat = 0;
  static double currentLng = 0;
  static DateTime currentDtime = DateTime.now(); // time of the last update
  static bool isTransmitting = false;

  // Trip Data
  static GeoData currentTrip = GeoData();
  static GeoData previousTrip = GeoData();
  static GeoData fromtotrip = GeoData();
  static GeoData waitingTrip = GeoData();

  // Shared
  static Location location = Location();
  static late StreamSubscription<LocationData> locationSubscription;
  static Timer? timer;

  // App Parameters
  static int waitingCharge = 0;
  static int wchargebyGroup = 0;
  static int waitcount = 0;
  static int tm = 0;
  static bool waiting = false;
  static bool showLatLng = false;
  static bool centerMap = true;
  static bool listenChanges = true;
  static bool useTimer = false;
  static double zoom = 16;
  static int interval = 1000;
  static double distanceFilter = 0;
  static double minDistance = 10;
  static double maxDistance = 30;
  static double oriThickness = 3;
  static double fixedThickness = 6;
  static const double defaultLat = 1.2926;
  static const double defaultLng = 103.8448;
  static const int timerInterval = 1000;
  static const int mintripDuration = 30; // to save the trip or not
  static int mapType = 2; //1 open street, 2 google map
  static DateTime lastSentLocationTime =
      DateTime.now(); //last location update time
  static DateTime socketLastReceivedTime =
      DateTime.now(); // to handle for socket idle

  static SocketService socketService = SocketService();

  static void clearTrip() {
    currentTrip.points.clear();
    currentTrip.dtimeList.clear();
    currentTrip.pointsFixed.clear();
    currentTrip.dtimeListFixed.clear();
  }

  static void clearWaiting() {
    waitingTrip.pointsFixed.clear();
    waitingTrip.totalWdistance = 0;
  }

  static void clearTripPrevious() {
    previousTrip.points.clear();
    previousTrip.dtimeList.clear();
    previousTrip.pointsFixed.clear();
    previousTrip.dtimeListFixed.clear();
    previousTrip.clear();
  }

  static void resetTripStatus(LocationNotifier locationNotifier) {
    currentTrip.tripId = "";
    currentTrip.tripStatus = "1";
    locationNotifier.notify();
  }

  static void copyPreviousTrip() {
    previousTrip.points = List.from(currentTrip.points);
    previousTrip.dtimeList = List.from(currentTrip.dtimeList);
    previousTrip.pointsFixed = List.from(currentTrip.pointsFixed);
    previousTrip.dtimeListFixed = List.from(currentTrip.dtimeListFixed);
    previousTrip.distance = currentTrip.distance;
    previousTrip.duration = currentTrip.duration;
    previousTrip.distanceAmount = currentTrip.distanceAmount;
    previousTrip.rate = currentTrip.rate;
    previousTrip.initial = currentTrip.initial;
    previousTrip.tripId = currentTrip.tripId;
    previousTrip.tripStatus = currentTrip.tripStatus;
    previousTrip.domainId = currentTrip.domainId;
  }

  static double estimateSpeed(
      List<LatLng> points, List<DateTime> dt, int range) {
    double speed = 0;
    int range = 10;
    double dist = 0;
    int time = 0;
    FlutterMapMath fmm = FlutterMapMath();
    if (points.length > range && dt.length > range) {
      time = dt[dt.length - 1].difference(dt[dt.length - range]).inSeconds;
      for (int i = points.length - range; i < points.length - 1; i++) {
        dist += fmm
            .distanceBetween(
                points[i].latitude, //latest points
                points[i].longitude,
                points[i - 1].latitude,
                points[i - 1].longitude,
                "meters")
            .round();
      }
      speed = dist / time * 60 * 60 / 1000;
    }
    return speed;
  }

  static int tripDurationOf(List<DateTime> dt) {
    if (dt.isEmpty) return 0;
    Duration difference = dt[dt.length - 1].difference(dt[0]);
    return (difference.inSeconds).round();
  }

  static double waitingTimeDistance(points) {
    FlutterMapMath fmm = FlutterMapMath();
    double dist2 = 0;
    dist2 += fmm
        .distanceBetween(
            points[points.length - 1].latitude,
            points[points.length - 1].longitude,
            points[0].latitude,
            points[0].longitude,
            "meters")
        .round();

    return (dist2 / 1000);
  }

  static double totalDistance(List<LatLng> points) {
    double dist = 0;
    FlutterMapMath fmm = FlutterMapMath();
    for (int i = 1; i < points.length - 1; i++) {
      dist += fmm
          .distanceBetween(
              points[i].latitude, //latest points
              points[i].longitude,
              points[i - 1].latitude,
              points[i - 1].longitude,
              "meters")
          .round();
    }
    return (dist / 1000);
  }

  static void updateLocation(double lat, double lng, DateTime dt,
      {LocationNotifier? providerLocNoti}) {
    if (lat != 0 && lng != 0) {
      GeoData.counter++;
      GeoData.currentLat = lat;
      GeoData.currentLng = lng;
      GeoData.currentDtime = dt;
      if (currentTrip.started) {
        if (waiting) {
          if (waitingTrip.pointsFixed.isEmpty ||
              waitingTrip.pointsFixed.last != LatLng(lat, lng - 0.000003)) {
            waitingTrip.pointsFixed.add(LatLng(lat, lng - 0.000003));
            waitingTrip.distance = waitingTimeDistance(waitingTrip.pointsFixed);
            if (waitingTrip.distance > 0.05) {
              MyHelpers.msg(
                  message: "Please disable 'Waiting' mode while driving.",
                  backgroundColor: Colors.red);
            }
          }
        } else {
          waitingTrip.totalWdistance =
              waitingTrip.distance + waitingTrip.totalWdistance;
          waitingTrip.distance = 0;
          currentTrip.pointsFixed.add(LatLng(lat, lng - 0.000003));
          currentTrip.dtimeListFixed.add(dt);
          currentTrip.points.add(LatLng(lat, lng));
          currentTrip.dtimeList.add(dt);
          // Geo Data Optimization
          FlutterMapMath fmm = FlutterMapMath();
          double dist = fmm.distanceBetween(
              currentTrip.points[currentTrip.points.length - 1]
                  .latitude, //latest points
              currentTrip.points[currentTrip.points.length - 1].longitude,
              currentTrip.points[currentTrip.points.length - 2].latitude,
              currentTrip.points[currentTrip.points.length - 2].longitude,
              "meters");
          int time = currentTrip.dtimeList[currentTrip.dtimeList.length - 1]
              .difference(
                  currentTrip.dtimeList[currentTrip.dtimeList.length - 2])
              .inSeconds;
          double speed = dist / time;
          //if (AppConfig.shared.log>=3)
          logger.i("Speed: $speed  ($dist / $time)");

          currentTrip.pointsFixed.add(LatLng(lat, lng - 0.000003));
          currentTrip.dtimeListFixed.add(dt);
          // ---------(C or -3)-------(B or -2)--------(A or -1 of original or last point)
          if (currentTrip.pointsFixed.length >= 3) {
            double dist2 = fmm.distanceBetween(
                currentTrip.pointsFixed[currentTrip.pointsFixed.length - 1]
                    .latitude, //latest points
                currentTrip
                    .pointsFixed[currentTrip.pointsFixed.length - 1].longitude,
                currentTrip
                    .pointsFixed[currentTrip.pointsFixed.length - 2].latitude,
                currentTrip
                    .pointsFixed[currentTrip.pointsFixed.length - 2].longitude,
                "meters");
            double dist1 = fmm.distanceBetween(
                currentTrip
                    .pointsFixed[currentTrip.pointsFixed.length - 2].latitude,
                currentTrip
                    .pointsFixed[currentTrip.pointsFixed.length - 2].longitude,
                currentTrip
                    .pointsFixed[currentTrip.pointsFixed.length - 3].latitude,
                currentTrip
                    .pointsFixed[currentTrip.pointsFixed.length - 3].longitude,
                "meters");

            if ((dist1 < minDistance && dist2 < minDistance) ||
                (dist1 > maxDistance && dist2 > maxDistance)) {
              currentTrip.pointsFixed.removeAt(
                  currentTrip.pointsFixed.length - 2); // Remove point B
              currentTrip.dtimeListFixed
                  .removeAt(currentTrip.dtimeListFixed.length - 2);
              //if (AppConfig.shared.log>=3)
              logger.i("Remove: $dist1 $dist2 ");
            } else {
              //if (AppConfig.shared.log>=3)
              logger.i("Keep: $dist1 $dist2 ");
            }
          }
        }
      }
      MyStore.storePolyline(currentTrip.points, "points01");
      MyStore.storeDateTimeList(currentTrip.dtimeList, "dtimeList01");
      MyStore.storePolyline(currentTrip.pointsFixed, "points01Fixed");
      MyStore.storeDateTimeList(currentTrip.dtimeListFixed, "dtimeList01Fixed");
      var dst = totalDistance(currentTrip.pointsFixed);
      if (dst < waitingTrip.totalWdistance) {
        currentTrip.distance = dst - dst;
      } else {
        var curdst = (dst - waitingTrip.totalWdistance).toStringAsFixed(2);
        currentTrip.distance = double.parse(curdst);
      }

      // - waitingTrip.distance;
      currentTrip.duration = tripDurationOf(currentTrip.dtimeListFixed);
      currentTrip.currentSpeed =
          estimateSpeed(currentTrip.pointsFixed, currentTrip.dtimeListFixed, 5);
      currentTrip.distanceAmount =
          calculateAmount(currentTrip.distance, currentTrip.duration);
      currentTrip.rate = RateChangeHelper.ratePerKm.toString();
      currentTrip.initial = RateChangeHelper.initial.toString();
      storeTripData(currentTrip.rate, currentTrip.initial,
          currentTrip.distanceAmount, currentTrip.currentSpeed);
      // GeoData.wtimeadd =  GeoData.tmd;
      if(waiting){ addWaitingCharge(false);}
      providerLocNoti?.notify(); // notify the provider there have been changes
    }
  }

  static storeTripData(rate, init, amount, speed) async {
    MyStore.prefs.setString('rate', rate);
    MyStore.prefs.setString('initial', init);
    MyStore.prefs.setInt('amount', amount);
    MyStore.prefs.setDouble('speed', speed);
  }

  static int calculateAmount(double distance, int time) {
    // replace it with real calculation
    double ret = 0;
    int tamount = 0;
    if (distance > 0 && RateChangeHelper.ratePerKm != 0) {
      // ret = 2500 + (distance * 2500);
      ret = RateChangeHelper.initial + (distance * RateChangeHelper.ratePerKm);
      tamount = RateChangeHelper.increment *
          ((ret / RateChangeHelper.increment).ceil());
    } else {
      tamount = 0;
    }
    return tamount;
  }

  static void startTrip(LocationNotifier locationNotifier) {
    GeoData.wtimeadd = 0;
    GeoData.tmd = 0;
    GeoData.waitingCharge = 0;
    currentTrip.startTime = DateTime.now();
    if (!useTimer) startTimer(locationNotifier);
    clearTrip();
    clearTripPrevious();
    currentTrip.started = true;
    currentTrip.tripId = const Uuid().v4();
    currentTrip.tripStatus = "2";
    MyStore.retriveDrivergroup('drivergroup').then((value) {
      value != null ? currentTrip.domainId = value.syskey : "";
      MyStore.prefs.setString(
          'currentTrip.domainId', (value != null ? value.syskey : ""));
    });
  }

  static void startTimer(LocationNotifier locationNotifier) {
    timer = Timer.periodic(const Duration(milliseconds: GeoData.timerInterval),
        (timer) {
      locationNotifier.notify();
    });
  }

  static int tripDuration() {
    int tm = 0;
    if (GeoData.currentTrip.started) {
      tm = DateTime.now().difference(currentTrip.startTime).inSeconds;
    } else {
      tm = tripDurationOf(previousTrip.dtimeListFixed);
    }
    return tm;
  }

  DateTime wdtimer = DateTime.now();
  static int wtimeadd = 0;
  static int tmd = 0;
  static int waitduration() {
    if (GeoData.waiting) {
      GeoData.tmd = DateTime.now().difference(currentTrip.wdtimer).inSeconds;
    }
    return GeoData.tmd;
  }

 static void addWaitingCharge(bool isEnd) async {
  List<Rate>? rate = await MyStore.retrieveRatebyGroup('ratebydomain');
  if (rate == null || rate.isEmpty) return;
  GeoData.wchargebyGroup = int.parse(rate[0].waitingCharge);
  final int wtimebyGroup = rate[0].waitingTime;
  final int waitGroupSec = wtimebyGroup * 60;
  if (GeoData.wchargebyGroup == 0 || wtimebyGroup == 0) return;
  int waitTimeToConsider = isEnd ? GeoData.wtimeadd : GeoData.wtimeadd + GeoData.tmd;
  if (waitTimeToConsider > waitGroupSec) {
    GeoData.waitcount = (waitTimeToConsider - waitGroupSec) ~/ 60;
    GeoData.waitingCharge = GeoData.wchargebyGroup * GeoData.waitcount;
  } else if (!isEnd && GeoData.tmd > waitGroupSec) {
    GeoData.waitcount = (GeoData.tmd - waitGroupSec) ~/ 60;
    GeoData.waitingCharge = GeoData.wchargebyGroup * GeoData.waitcount;
  }
}


  static void endTrip() {
    if (fromto) {
      fromto = !fromto;
    }
    if (waiting) {
      waiting = !waiting;
      GeoData.wtimeadd = GeoData.wtimeadd + GeoData.tmd;

    }
    addWaitingCharge(true);
    MyStore.prefs.setBool("fromto", false);
    GeoData.fromtotrip.pointsfromto.clear();
    currentTrip.started = false;
    currentTrip.tripStatus = "3";
    if (!useTimer) timer?.cancel();
    copyPreviousTrip();
    clearTrip();
    clearWaiting();
  }

  Future<void> addPoint(
      PolylineResult result, LocationNotifier provider) async {
    for (var point in result.points) {
      double lat = point.latitude;
      double long = point.longitude;

      LatLng fromto = LatLng(lat, long);
      GeoData.fromtotrip.pointsfromto.add(fromto);
    }
    provider.notify();
    MyStore.storePolyline(fromtotrip.pointsfromto, "points02");
  }

  static Future<bool> chkPermissions(Location location) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (serviceEnabled) {
          logger.i("Service Enabled");
        } else {
          logger.i("Service Disabled");
          return false;
        }
      }
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted == PermissionStatus.granted) {
          logger.i("Permission Granted");
        } else {
          logger.i("Permission Denined");
          return false;
        }
      }
    } catch (e) {
      logger.e("Permission Exception (getCurrentLocation)");
      return false;
    }
    return true;
  }

  static Future<LocationData?> getCurrentLocation(Location location) async {
    LocationData locationData;
    bool serviceEnabled = await chkPermissions(location);
    if (serviceEnabled) {
      locationData = await location.getLocation();
      GeoData.updateLocation(
          locationData.latitude!, locationData.longitude!, DateTime.now());
      return locationData;
    } else {
      return null;
    }
  }

  static void updateDistanceAmount([LocationNotifier? notifier]) {
    currentTrip.distanceAmount =
        calculateAmount(currentTrip.distance, currentTrip.duration);
    if (notifier != null) {
      notifier.notify();
    }
  }

  static List<gmap.LatLng> convertLatLngList(List<LatLng> route) {
    List<gmap.LatLng> plistfixed = [];
    for (var point in route) {
      plistfixed.add(gmap.LatLng(point.latitude, point.longitude));
    }
    return plistfixed;
  }

  // Method to calculate the LatLngBounds for the polyline
  static gmap.LatLngBounds getLatLngBounds(List<LatLng> points) {
    assert(points.isNotEmpty);

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return gmap.LatLngBounds(
      southwest: gmap.LatLng(minLat, minLng),
      northeast: gmap.LatLng(maxLat, maxLng),
    );
  }

  static Future<void> updateLocationToServer(
      double dist, LocationData currentLocation) async {
    if (dist > 0) {
      GeoData.sendCurLoc(currentLocation.latitude!, currentLocation.longitude!);
    } else {
      DateTime dt = DateTime.now();
      int time = dt.difference(GeoData.lastSentLocationTime).inSeconds;
      int timeRange = AppConfig.shared.curlocByApi ? 30 : 5;
      //logger.i("lastsending: $time");
      if (time > timeRange) {
        GeoData.sendCurLoc(
            currentLocation.latitude!, currentLocation.longitude!);
        GeoData.lastSentLocationTime = GeoData.currentDtime;
      }
    }
  }

  // function to send current location with websocket
  static Future<void> sendCurLoc(double lat, double lng, [int? status]) async {
    String uuid = MyStore.prefs.getString('uuid');
    int tripStatus = status ?? int.parse(currentTrip.tripStatus);
    SocketDataBody body = SocketDataBody(
        syskey: "",
        tripid: currentTrip.tripId,
        userid: GlobalAccess.userID,
        appid: AppConfig.shared.appID,
        domainid: "",
        vehicleid: "",
        datetime: DateTime.now().toUtc().toIso8601String(),
        latitude: lat,
        longitude: lng,
        type: "car",
        status: tripStatus,
        uuid: uuid);
    SocketDataModel data = SocketDataModel(action: "curloc", body: body);
    String jsonString = jsonEncode(data.toJson());
    AppConfig.shared.curlocByApi
        ? ApiDataServiceFlaxi().sendCurLoc(data.body)
        : socketService.sendCurrentLocation(
            jsonString); // Send the JSON string through WebSocket
  }

  static double distBetweenTwoPoints(LatLng point1, LatLng point2) {
    double dist = 0;
    FlutterMapMath fmm = FlutterMapMath();
    // for (int i = 1; i < points.length - 1; i++) {
    dist += fmm
        .distanceBetween(
            point2.latitude, //latest points
            point2.longitude,
            point1.latitude,
            point1.longitude,
            "meters")
        .round();
    // }
    return (dist / 1000);
  }
}

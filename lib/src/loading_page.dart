//  -------------------------------------    Loading
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong2/latlong.dart';
import 'api/token.dart';
import 'modules/flaxi/api_data_models/groups_models.dart';
import 'modules/flaxi/api_data_models/rateby_groups_models.dart';
import 'modules/flaxi/helpers/extras_helper.dart';
import 'modules/flaxi/helpers/group_service.dart';
import 'modules/flaxi/helpers/trip_service.dart';
import 'modules/flaxi/helpers/wallet_helper.dart';
import 'root_page.dart';
import 'package:location/location.dart';
import '/src/helpers/helpers.dart';
import 'geolocation/geo_data.dart';
import 'package:provider/provider.dart';
import 'modules/flaxi/helpers/rate_change_helpers.dart';
import 'modules/flaxi/rates/rate_schemes.dart';
import 'geolocation/location_notifier.dart';
import 'shared/app_config.dart';
import 'shared/global_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'socket/socket_service.dart';

//  -------------------------------------    Loading (Property of Nirvasoft.com)
class LoadingPage extends StatefulWidget {
  static const routeName = '/loading';
  const LoadingPage({super.key});
  @override
  State<LoadingPage> createState() => _LoadingState();
}

class _LoadingState extends State<LoadingPage> {
  // 1) Geo Declaration >>>>
  late LocationNotifier providerLocNoti; // Provider Declaration and init
  SocketService socketService = SocketService();

  // 2) Init State
  @override
  void initState() {
    super.initState();
    loading(context).then((_) {
      initRateSchemesData(); //2.3) Rate Init Function
    }); // 2.1) Loading Function
    initGeoData(); // 2.2) Geo Init Function
  }

  // 2.1) Loading Function
  Future loading(BuildContext context) async {
    // 2.1.1) Shared Preferences
    await MyStore.init();
    MyStore.getMapType();
    GeoData.fromto = MyStore.prefs.getBool("fromto") ?? false;
    if (GeoData.fromto) {
      List<LatLng>? polyline;
      polyline = (await MyStore.retrievePolyline("points02"));
      if (polyline != null) {
        GeoData.fromtotrip.pointsfromto = polyline;
      }
    }
    GeoData.currentTrip.started =
        MyStore.prefs.getBool('currentTrip.started') ?? false;
    if (GeoData.currentTrip.started) {
      GeoData.currentTrip.tripId =
          await MyStore.prefs.getString('currentTrip.tripID') ?? "0";
      GeoData.currentTrip.domainId =
          await MyStore.prefs.getString('currentTrip.domainId') ?? "";
      ExtrasData.curExtrasData.currentExtrasList =
          await MyStore.getExtrasList();
      ExtrasData.calculateExtra();
      logger.i(ExtrasData.curExtrasData.currentExtrasList.toString());
      if (GeoData.currentTrip.tripId == "0") {
        GeoData.currentTrip.started = false;
      } else {
        GeoData.currentTrip.tripStatus = "2";
      }
    }
    if (GeoData.currentTrip.started) {
      List<LatLng>? pline;
      List<DateTime> dtlist = [];
      pline = (await MyStore.retrievePolyline("points01"));
      if (pline != null) {
        GeoData.currentTrip.points = pline;
        pline = (await MyStore.retrievePolyline("points01Fixed"));
        if (pline != null) {
          GeoData.currentTrip.pointsFixed = pline;
          dtlist = (await MyStore.retrieveDateTimeList("dtimeList01"));
          if (dtlist.isNotEmpty) {
            GeoData.currentTrip.startTime = dtlist[0];
            GeoData.currentTrip.dtimeList = dtlist;
            dtlist = (await MyStore.retrieveDateTimeList("dtimeList01Fixed"));
            if (dtlist.isNotEmpty) {
              GeoData.currentTrip.dtimeListFixed = dtlist;

              // end the trip if it is more than 30 minute, it will be ended.
              DateTime currenttime = DateTime.now();
              if (currenttime.difference(dtlist[dtlist.length - 1]) >
                  const Duration(minutes: 30)) {
                savecurrentTrip();
              }
              //
            } else {
              GeoData.endTrip();
            }
          } else {
            GeoData.endTrip();
          }
        } else {
          GeoData.endTrip();
        }
      } else {
        GeoData.endTrip();
      }
    }
    // 2.1.2) Read Global Data from Secure Storage
    await GlobalAccess.readSecToken();
    await Token().getDeviceUUID();

    /** closed for now because it clean global data */
    // if (GlobalAccess.accessToken.isNotEmpty) {
    //   // should not refresh if guest coming back. let sign in again
    //   await ApiAuthService.checkRefreshToken();
    // }
    /** closed for now because it clean global data */

    // 2.1.3) Group and Rate Schemes if User
    final hasUserOrToken = GlobalAccess.userID.isNotEmpty;
    if (hasUserOrToken ) {
      await GroupService.fetchAndStoreGroups();
      GroupService.fetchAndStoreRate();
      WalletData().initializeWallet();
    }
    

    // 2.1.4 Decide where to go based on Global Data read from secure storage.

    Timer(const Duration(seconds: 2), () {
      setState(() {
        if (AppConfig.shared.gotoRootDirect) {
          _navigateToRoot();
          return;
        }
        if (hasUserOrToken) {
          int signinType = MyStore.prefs.getInt('signintype') ?? 0;
          // Compare signinType and navigate accordingly
          if (AppConfig.shared.signinType == signinType) {
            _navigateToRoot();
          } else {
            _resetData();
            AppConfig.signIn(context);
          }
        } else {
          AppConfig.signIn(context);
        }
      });
    });
  }

  void _navigateToRoot() {
    Navigator.pushReplacementNamed(context, RootPage.routeName);
  }

  void _resetData() {
    GlobalAccess.reset(); // Reset global data
    GlobalAccess.resetSecToken(); // Reset secure storage with global data
    MyStore.clearSignInDetails(); // Clear shared preferences
  }

  // 2.2) Geo Init Function
  Future<void> initGeoData() async {
    GeoData.currentLat = GeoData.defaultLat;
    GeoData.currentLng = GeoData.defaultLng;
    try {
      providerLocNoti = Provider.of<LocationNotifier>(context, listen: false);
      if (await GeoData.chkPermissions(GeoData.location)) {
        await GeoData.location.changeSettings(
            accuracy: LocationAccuracy.high,
            interval: GeoData.interval,
            distanceFilter: GeoData.distanceFilter);
        GeoData.locationSubscription = GeoData.location.onLocationChanged
            .listen((LocationData currentLocation) {
          changeLocations(currentLocation);
        });
        if (GeoData.listenChanges == false) {
          GeoData.locationSubscription.pause();
        }
      } else {
        logger.i("Permission Denied");
      }
    } catch (e) {
      logger.i("Exception (initGeoData): $e");
    }
  }

  // 2.2.1) GPS Listener Method
  void changeLocations(LocationData currentLocation) {
    //listen to location changes
    try {
      DateTime dt = DateTime.now();
      LatLng prevLoc = LatLng(GeoData.currentLat, GeoData.currentLng);
      LatLng currentLoc =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);
      GeoData.updateLocation(
          currentLocation.latitude!, currentLocation.longitude!, dt);
      providerLocNoti.notify();
      double dist = GeoData.distBetweenTwoPoints(prevLoc, currentLoc);
      logger.i("Distance: $dist");

      //send current location with websocket
      GeoData.updateLocationToServer(dist, currentLocation);

      // No need. above method will notify the provider
      if (AppConfig.shared.log == 3) {
        logger.i(
            "(${GeoData.counter}) ${currentLocation.latitude} x ${currentLocation.longitude}");
      }
    } catch (e) {
      logger.i("Exception (changeLocations): $e");
    }
  }

  // 2.1.2) Current Location Method

  // 2.3) Rate Init Function
  Future<void> initRateSchemesData() async {
    if ((GlobalAccess.userID.isEmpty && AppConfig.shared.gotoRootDirect) || (GlobalAccess.userID.isEmpty && AppConfig.shared.allowGuest)) {
      Map<String, dynamic>? selectedRateSchemes =
          RateSchemes().getSelectedRateScheme() ??
              await MyStore.getRateScheme();
      if (selectedRateSchemes!.isNotEmpty) {
        RateChangeHelper.updateRateData(
          selectedRateSchemes["initialAmount"] ?? 2000,
          selectedRateSchemes["ratePerKm"] ?? 800,
          selectedRateSchemes["increment"] ?? 100,
          selectedRateSchemes["groupCurrency"] ?? 'MMK',
        );
      }
    } else {
      List<Rate>? rateData = await MyStore.retrieveRatebyGroup('ratebydomain');
      if (rateData != null) {
        int initialAmount = int.parse(rateData[0].initial);
        int ratePerKm = int.parse(rateData[0].rate);
        int increment = 100;
        String groupCurrency = rateData[0].symbol;
        RateChangeHelper.updateRateData(
            initialAmount, ratePerKm, increment, groupCurrency);
      } else {
        Group? group = await MyStore.retriveDrivergroup('drivergroup');
        if (group != null) {
          await GroupService.fetchAndStoreRate();
          List<Rate>? rateData =
              await MyStore.retrieveRatebyGroup('ratebydomain');
          if (rateData != null) {
            int initialAmount = int.parse(rateData[0].initial);
            int ratePerKm = int.parse(rateData[0].rate);
            String groupCurrency = rateData[0].symbol;
            int increment = 100;
            RateChangeHelper.updateRateData(
                initialAmount, ratePerKm, increment, groupCurrency);
          } else {
            RateChangeHelper.updateRateData(0, 0, 0, 'MMK');
          }
        } else {
          await GroupService.fetchAndStoreGroups();
          await GroupService.fetchAndStoreRate();
          WalletData().initializeWallet();
          List<Rate>? rateData =
              await MyStore.retrieveRatebyGroup('ratebydomain');
          if (rateData != null) {
            int initialAmount = int.parse(rateData[0].initial);
            int ratePerKm = int.parse(rateData[0].rate);
            String groupCurrency = rateData[0].symbol;
            int increment = 100;
            RateChangeHelper.updateRateData(
                initialAmount, ratePerKm, increment, groupCurrency);
          } else {
            RateChangeHelper.updateRateData(0, 0, 0, 'MMK');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: const Image(
            image: AssetImage("assets/images/logo.png"),
            width: 150,
            height: 150,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Text(
          ' ${AppLocalizations.of(context)!.welcome} ${AppConfig.shared.appName}',
        ),
        const SizedBox(
          height: 50,
        ),
        Center(
          child: SizedBox(
            height: 30,
            child: SpinKitWave(
              color: Colors.grey[400],
              type: SpinKitWaveType.start,
              size: 40.0,
              itemCount: 5,
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
        ),
        Text(
          'Version ${AppConfig.shared.appVersion}',
        ),
      ]),
    );
  }

  void savecurrentTrip() async {
    GeoData.currentTrip.distance =
        GeoData.totalDistance(GeoData.currentTrip.pointsFixed);
    GeoData.currentTrip.duration =
        GeoData.tripDurationOf(GeoData.currentTrip.dtimeListFixed);
    GeoData.currentTrip.currentSpeed =
        await MyStore.prefs.getDouble('speed') ?? 0;
    GeoData.currentTrip.distanceAmount =
        await MyStore.prefs.getInt('amount') ?? 0.0;
    GeoData.currentTrip.rate = await MyStore.prefs.getString('rate') ?? 800;
    GeoData.currentTrip.initial =
        await MyStore.prefs.getString('initial') ?? 2000;   
    providerLocNoti.notify();
    endIt(providerLocNoti);
    saveandsendTrip();
  }

  void endIt(LocationNotifier locationNotifier) {
    GeoData.endTrip();
    GeoData.sendCurLoc(
      GeoData.currentLat,
      GeoData.currentLng,
      3,
    ).then((_) {
      GeoData.resetTripStatus(locationNotifier);
    });
    locationNotifier.notify();
    MyStore.prefs.setBool("currentTrip.started", false);
    setState(() {});
  }

  void saveandsendTrip() {
    TripService.getTripModel().then((trip) {
      MyTripDBOperator().saveTripToDB(trip).then((_) {
        if (GlobalAccess.userID.isNotEmpty) {
          //TripService.sendTrip(trip);
        }
      });
    });
  }
}

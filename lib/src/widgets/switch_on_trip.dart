import 'package:flutter/material.dart';
import '../modules/flaxi/helpers/extras_helper.dart';
import '../modules/flaxi/helpers/group_service.dart';
import '../modules/flaxi/helpers/log_model.dart';
import '../modules/flaxi/helpers/log_service.dart';
import '../modules/flaxi/helpers/trip_service.dart';
import '../geolocation/geo_data.dart';
import '../geolocation/location_notifier.dart';
import '../modules/flaxi/helpers/wallet_helper.dart';
import '../shared/global_data.dart';
import '../sqflite/trip_model.dart';
import '/src/helpers/helpers.dart';
import 'switch_on.dart';
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
          if(int.parse(WalletData.curWalletData.currentBalance) < int.parse(WalletData.curWalletData.restrictAmount)) {
            MyHelpers.msg( message: "You don't have enough balance to start a trip", backgroundColor: Colors.red);
            return;
          }
         
          if (GeoData.currentTrip.started) {
            if (GeoData.tripDuration() > (GeoData.mintripDuration)) {
              // more than 30s
              MyHelpers.getBool(context, "Are you sure to end trip?")
                  .then((value) => {
                        if (value != null && value)
                          {
                            endIt(locationNotifier,false),
                            saveAndSendTrip(),
                            
                          }
                      });
            } else {
              GeoData.clearTripPrevious;
              GeoData.clearTrip();
              ExtrasData.clearPrevExtras();
              ExtrasData.clearExtras();
              MyStore.clearExtraList();
              setState(() {}); // discard the current data
              endIt(locationNotifier,true); // less than 60s, GeoData.mintripDuration
            }
          } else {
             if((int.parse(WalletData.curWalletData.currentBalance) < int.parse(WalletData.curWalletData.notiAmount)) && (int.parse(WalletData.curWalletData.currentBalance) > int.parse(WalletData.curWalletData.restrictAmount))) {
            MyHelpers.msg(message: "Your balance is lower than ${WalletData.curWalletData.notiAmount}. Pleas fill the balance");
            }
            startIt(locationNotifier);
          }
        },
      );
    });
  }

  void endIt(LocationNotifier locationNotifier,bool isDelete) {
    GeoData.endTrip();
    GeoData.sendCurLoc(
      GeoData.currentLat,
      GeoData.currentLng,
      3,
    ).then((_) {
      GeoData.resetTripStatus(locationNotifier);
    });
    ExtrasData.copyPreviousExtra();
    if(GroupService.gpType != 0 && !isDelete ){
    WalletData.calCurBalance().then((_) {
    WalletData.copyPreviousWallet();
    });
    }  
    WalletData.resetInitialCurBalance();
    locationNotifier.notify();
    MyStore.prefs.setBool("currentTrip.started", false);
    MyStore.clearExtraList();
    KeepScreenOn.turnOff();
    setState(() {});
  }

  void startIt(LocationNotifier locationNotifier) {
    GeoData.centerMap = true;
    GeoData.clearTrip();
    ExtrasData.clearExtras();
    locationNotifier.notify();
    GeoData.startTrip(locationNotifier);
    MyStore.prefs.setBool("currentTrip.started", true);
    MyStore.prefs.setString("currentTrip.tripID", GeoData.currentTrip.tripId);
    KeepScreenOn.turnOn();
    setState(() {});
  }
}

// void saveandsendTrip() {
//     String  timestamp = DateTime.now().toIso8601String();
//     try{
//       TripService.getTripModel().then((trip) {
//       MyTripDBOperator().saveTripToDB(trip).then((_) {
//         calAndSaveExtras( trip.tripID).then((_){
//            if (GlobalAccess.userID.isNotEmpty) {
//           TripService.sendTrip(trip,ExtrasData.prevExtrasData.previousExtrasList);
//         }
//         });

//       });
//     });
//   } catch(e) {
//     LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace:' saveAndsendTrip(SwitchOnTrip )', timestamp: timestamp));
//   }
// }

Future<void> saveAndSendTrip() async {
  String timestamp = DateTime.now().toIso8601String();
  try {
    await Future.microtask(() async {
      TripModel trip = await TripService.getTripModel();
      await MyTripDBOperator().saveTripToDB(trip);
      await calAndSaveExtras(trip.tripID);
      if (GlobalAccess.userID.isNotEmpty) {
        TripService.sendTrip(trip, ExtrasData.prevExtrasData.previousExtrasList,false);
      }
    });
  } catch (e) {
    LogService.writeLog(LogModel(errorMessage: e.toString(),stackTrace: 'saveAndSendTrip (SwitchOnTrip)',timestamp: timestamp,));
  }
}


Future<void> calAndSaveExtras(String tripID) async{
  //ExtrasData.getPrevExtraList().then((List<Extra> extras){
    MyTripDBOperator().saveExtrasToDB(ExtrasData.prevExtrasData.previousExtrasList, tripID);
    if(GeoData.waitcount > 0 && GeoData.waitingCharge > 0){
         MyTripDBOperator().saveWaitingChargeToDB(tripID,0);
    MyTripDBOperator().saveWaitingChargeToDB(tripID,1);
    }
 
  //});
}

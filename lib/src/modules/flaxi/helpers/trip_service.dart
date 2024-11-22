import '../../../api/token.dart';
import '../../../geolocation/geo_address.dart';
import '../../../geolocation/geo_data.dart';
import '../../../helpers/helpers.dart';
import '../../../shared/app_config.dart';
import '../../../shared/global_data.dart';
import '../../../sqflite/trip_model.dart';
import '../api/api_data_service_flaxi.dart';
import '../api_data_models/groups_models.dart';
import '../api_data_models/rateby_groups_models.dart';
import '../api_data_models/trip_data_models.dart';
import 'extras_helper.dart';
import 'rate_change_helpers.dart';
import 'wallet_helper.dart';

class TripService {
  static Future<void> sendTrip(
    TripModel trip,
    List<Extra> previousExtrasList,
    bool isResend,
  ) async {
    final vehicle = MyStore.prefs.getString('vehicle') ?? '';
    final vehicleno = MyStore.prefs.getString('vehicleno') ?? '';
    String uuid =
        MyStore.prefs.getString('uuid') ?? await Token().getDeviceUUID();
    //Group? selectedGp = await MyStore.retriveDrivergroup('drivergroup');
    //String domain = selectedGp != null ? selectedGp.syskey:'';
    double initial = trip.initial != "" ? double.parse(trip.initial) : 0.0;
    double rate = trip.rate != "" ? double.parse(trip.rate) : 0.0;
    double distance = trip.distance != "" ? double.parse(trip.distance) : 0.0;
    int walletInitial =
        int.parse(trip.walletInitial == "" ? "0" : trip.walletInitial);
    int amount = int.parse(trip.walletAmount == "" ? "-0" : trip.walletAmount);
    int total = int.parse(trip.walletTotal == "" ? "0" : trip.walletTotal);
    WalletBalance walletBalance =
        WalletBalance(initial: walletInitial, amount: amount, total: total);
    int waitingTime = isResend
        ? previousExtrasList.isNotEmpty
            ? previousExtrasList
                .singleWhere((e) => e.name == "Waiting Time",
                    orElse: () => Extra(
                        name: "", amount: "", type: "", qty: 0, subTotal: 0))
                .subTotal
            : 0
        : GeoData.waitcount;
    int waitingCharge = isResend
        ? previousExtrasList.isNotEmpty
            ? previousExtrasList
                .singleWhere((e) => e.name == "Waiting Charges",
                    orElse: () => Extra(
                        name: "", amount: "", type: "", qty: 0, subTotal: 0))
                .subTotal
            : 0
        : GeoData.waitingCharge;

    TripDetailData tripDetailData = TripDetailData(
      initial: initial,
      rate: rate,
      distance: distance,
      driverid: GlobalAccess.driverID,
      waitingtime: waitingTime,
      waitingcharge: waitingCharge.toDouble(),
      symbol: trip.currency != "" ? trip.currency : 'MMK',
      total: trip.totalAmount != "" ? int.parse(trip.totalAmount) : 0,
      subtotal: trip.distanceAmount,
      duration: trip.tripDuration != ""
          ? MyHelpers.formatTime(int.parse(trip.tripDuration))
          : '0',
      startname: trip.startLocName,
      endname: trip.endLocName,
      domainid: trip.domainID,
      vehicleno: vehicleno,
      vehicle: vehicle,
      extras: previousExtrasList,
      walletBalance: walletBalance,
    );

    TripDataModel tripModel = TripDataModel(
      sysKey: '',
      tripID: trip.tripID,
      userID: trip.userID,
      appID: AppConfig.shared.appID,
      uuID: uuid,
      domainID: trip.domainID,
      vehicleID: '',
      fromDateTime: trip.startTime,
      toDateTime: trip.endTime,
      route: trip.route,
      type: 'car',
      status: trip.tripStatus == "" ? 3 : int.parse(trip.tripStatus),
      refNo: '',
      timeData: trip.dateTimeList,
      tripDetailData: tripDetailData,
    );
    logger.i(tripModel.toJson());

    final response = await ApiDataServiceFlaxi().sendTrip(tripModel);
    if (response['status'] == 200) {
      logger.i("Trip sent successfully.");
      MyTripDBOperator().updateCloudStatus(trip.tripID, "posted");
    } else {
      logger.e("Trip send error:${response['status']}");
    }
  }

  // static Future<void> sendSavedTrips(List<TripModel> trips) async {
  //   for (int i = 0; i < trips.length; i++) {

  //     await sendTrip(trips[i]);
  //   }
  // }

  static Future<TripModel> getTripModel() async {
    String date = MyHelpers.ymdDateFormat(DateTime.now());
    List<String> dateTimeList =
        MyHelpers.dateTimeListToStringList(GeoData.previousTrip.dtimeListFixed);
    List<String> orgDateTimeList =
        MyHelpers.dateTimeListToStringList(GeoData.previousTrip.dtimeList);
    String startLocName = await GeoAddress().getPlacemarks(
        GeoData.previousTrip.pointsFixed.first.latitude,
        GeoData.previousTrip.pointsFixed.first.longitude);
    String endLocName = await GeoAddress().getPlacemarks(
        GeoData.previousTrip.pointsFixed.last.latitude,
        GeoData.previousTrip.pointsFixed.last.longitude);
    Group? group = await MyStore.retriveDrivergroup('drivergroup');
    String groupID = group != null ? group.id : '';
    int totalAmount = GeoData.previousTrip.distanceAmount +
        ExtrasData.prevExtrasData.extraTotal +
        GeoData.waitingCharge;
    TripModel trip = TripModel(
      userID: GlobalAccess.userID,
      tripID: GeoData.previousTrip.tripId,
      startTime: GeoData.previousTrip.dtimeListFixed.first.toString(),
      endTime: DateTime.now().toString(),
      route: GeoData.previousTrip.pointsFixed,
      originalRoute: GeoData.previousTrip.points,
      dateTimeList: dateTimeList,
      originalDateTimeList: orgDateTimeList,
      tripStatus: GeoData.previousTrip
          .tripStatus, // wip (can add fees etc) , complete (cant edit data. can print receipt)
      tripDuration: GeoData.previousTrip.duration.toString(),
      distance: GeoData.previousTrip.distance.toString(),
      orgDistance:
          GeoData.totalDistance(GeoData.previousTrip.points).toString(),
      startLocName: startLocName,
      endLocName: endLocName,
      distanceAmount: GeoData.previousTrip.distanceAmount.toString(),
      extrasTotalAmount: ExtrasData.prevExtrasData.extraTotal.toString(),
      totalAmount: totalAmount.toString(),
      rate: GeoData.previousTrip.rate,
      initial: GeoData.previousTrip.initial,
      createdDate: date,
      cloudStatus:
          "saved", //saved:save to db not posted , posted:posted to server
      domainID: GeoData.previousTrip.domainId,
      groupID: groupID,
      currency: RateChangeHelper.groupCurrency,
      walletInitial: WalletData.prevWalletData.initialCurrentBalance,
      walletAmount: WalletData.prevWalletData.tripFee.toString().toString(),
      walletTotal: WalletData.prevWalletData.currentBalance,
    );
    // logger.i(trip.toJson());
    // logger.i("Group ID: ${trip.groupID}");
    return trip;
  }
}

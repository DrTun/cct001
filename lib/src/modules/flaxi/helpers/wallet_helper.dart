import '../../../geolocation/geo_data.dart';
import '../../../helpers/helpers.dart';
import '../../../providers/network_service_provider.dart';
import '../api_data_models/groups_models.dart';
import 'extras_helper.dart';

class WalletData {
  String initialCurrentBalance = MyStore.prefs.getString('curBal') ?? "0";
  String currentBalance = MyStore.prefs.getString('curBal') ?? "0";
  int feeType = 0;
  String fee = "0";
  String notiAmount = "0";
  String restrictAmount = "-0";
  int tripFee = -0;
  static WalletData curWalletData = WalletData();
  static WalletData prevWalletData = WalletData();

  final networkService = NetworkServiceProvider();

  Future<void> initializeWallet() async {
    await NetworkServiceProvider.checkConnectionStatus();
    Group? group = await MyStore.retriveDrivergroup('drivergroup');

    if (networkService.isOnline.value) {
      if (group != null) {
        curWalletData.initialCurrentBalance = group.balance;
        curWalletData.currentBalance = group.balance;
        curWalletData.feeType = group.feeType;
        curWalletData.fee = group.fee;
        curWalletData.notiAmount = group.notiAmount;
        curWalletData.restrictAmount = group.restrictAmount;
        MyStore.prefs.setString('curBal', curWalletData.currentBalance);
      }
    }else{
      if(group != null){
       initializeOfflineWallet(group);
      }
    }

    // providerLocNoti.notify();
  }

  Future<void> initializeOfflineWallet(Group group) async {
      curWalletData.initialCurrentBalance = MyStore.prefs.getString('curBal') ?? "0";
      curWalletData.currentBalance = MyStore.prefs.getString('curBal') ?? "0";
      curWalletData.feeType = group.feeType;
      curWalletData.fee = group.fee;
      curWalletData.notiAmount = group.notiAmount;
      curWalletData.restrictAmount = group.restrictAmount;
    
    // providerLocNoti.notify();
  }

  static Future<void> calCurBalance() async {
    switch (curWalletData.feeType) {
      case 1:
        calFixedFee();
      case 2:
        calPercentageFee();
        break;
      default:
    }

    // providerLocNoti.notify();
  }

  static void calPercentageFee() {
    int curBal = int.parse(curWalletData.currentBalance);
    int feePercentage = int.parse(curWalletData.fee);
    int totalAmount = GeoData.previousTrip.distanceAmount +
        ExtrasData.prevExtrasData.extraTotal;
    int tripFee = ((totalAmount * feePercentage) / 100).round();
    logger.i("Trip fee: $tripFee");
    curWalletData.currentBalance = (curBal - tripFee).toString();
    curWalletData.tripFee = -tripFee;
    MyStore.prefs.setString('curBal', curWalletData.currentBalance);
  }

  static void calFixedFee() {
    int curBal = int.parse(curWalletData.currentBalance);
    int fee = int.parse(curWalletData.fee);
    curWalletData.currentBalance = (curBal - fee).toString();
    curWalletData.tripFee = -fee;
    MyStore.prefs.setString('curBal', curWalletData.currentBalance);
  }

  static void copyPreviousWallet() {
    prevWalletData.initialCurrentBalance = curWalletData.initialCurrentBalance;
    prevWalletData.currentBalance = curWalletData.currentBalance;
    prevWalletData.feeType = curWalletData.feeType;
    prevWalletData.fee = curWalletData.fee;
    prevWalletData.notiAmount = curWalletData.notiAmount;
    prevWalletData.restrictAmount = curWalletData.restrictAmount;
    prevWalletData.tripFee = curWalletData.tripFee;
  }

  static void resetInitialCurBalance() {
    curWalletData.initialCurrentBalance = curWalletData.currentBalance;
  }
}

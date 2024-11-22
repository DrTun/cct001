import 'dart:convert';
import '../../../helpers/helpers.dart';
import '../../../providers/mynotifier.dart';
import '../api_data_models/rateby_groups_models.dart';

class ExtrasData {
  // List to hold extra items
  List<Extra> currentExtrasList = [];
  List<Extra> previousExtrasList = [];
  List<bool> selectedExtras = [];

  static ExtrasData curExtrasData = ExtrasData();
  static ExtrasData prevExtrasData = ExtrasData();
  static ExtrasData emptyExtras = ExtrasData();
  int extraTotal = 0;

  void addExtra(Extra extra) {
    currentExtrasList.add(extra);
    selectedExtras.add(false); 
  }

  void toggleExtra(int index, MyNotifier notifier) {
    if (index >= 0 && index < selectedExtras.length) {

      selectedExtras[index] = !selectedExtras[index];

      if (selectedExtras[index]) {
        increaseCount(index, notifier);
      } else {
        if (currentExtrasList[index].qty > 0) {
          decreaseCount(index, notifier);
        } else {
          currentExtrasList[index].qty = 0;
        }

        MyStore.saveExtrasList(currentExtrasList); // Save updated list
      }
      notifier.notify();
    } 
  }

  void increaseCount(int index, MyNotifier notifier) {
    if (index >= 0 && index < currentExtrasList.length) {
      currentExtrasList[index].qty++;
      calculateSubTotal(index);
      notifier.notify();
      extraTotal += int.parse(currentExtrasList[index].amount);
      MyStore.saveExtrasList(currentExtrasList);
      notifier.notify();
    }
  }

  void decreaseCount(int index, MyNotifier notifier) {
    if (index >= 0 &&
        index < currentExtrasList.length &&
        currentExtrasList[index].qty > 0) {
      currentExtrasList[index].qty--;
      calculateSubTotal(index);
      notifier.notify();
      extraTotal -= int.parse(currentExtrasList[index].amount);
      MyStore.saveExtrasList(currentExtrasList);
      notifier.notify();
    }
  }

  void calculateSubTotal(int index) {
    if (index >= 0 && index < currentExtrasList.length) {
      int amount = int.parse(currentExtrasList[index].amount);
      currentExtrasList[index].subTotal = currentExtrasList[index].qty * amount;
    }
  }

  static void clearExtras() {
    curExtrasData.currentExtrasList.clear();
    curExtrasData.extraTotal = 0;
      curExtrasData.selectedExtras =
        List.generate(curExtrasData.currentExtrasList.length, (index) => false);
  }

  static void clearPrevExtras() {
    prevExtrasData.previousExtrasList.clear();
    prevExtrasData.extraTotal = 0;
        
  }

  static void copyPreviousExtra() {
    // Create a deep copy of currentExtrasList
    prevExtrasData.previousExtrasList = curExtrasData.currentExtrasList
        .map((extra) => Extra(
              name: extra.name,
              amount: extra.amount,
              qty: extra.qty,
              type: extra.type,   
            ))
        .toList();

    prevExtrasData.extraTotal = curExtrasData.extraTotal;
    logger.i("Extras ${jsonEncode(prevExtrasData.previousExtrasList)}");
  }

  static Future<void> calculateExtra() async {
    ExtrasData.curExtrasData.extraTotal = 0;
    for (var extra in ExtrasData.curExtrasData.currentExtrasList) {
      int amount = int.parse(extra.amount);
      int qty = extra.qty;
      int total = amount * qty;
      ExtrasData.curExtrasData.extraTotal += total;
    }
    logger.i("Extras ${ExtrasData.curExtrasData.extraTotal}");
  }
}

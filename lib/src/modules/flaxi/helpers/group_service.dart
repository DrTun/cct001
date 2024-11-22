import '../../../helpers/helpers.dart';
import '../../../shared/global_data.dart';
import '../api/api_data_service_flaxi.dart';
import '../api_data_models/error_models.dart';
import '../api_data_models/groups_models.dart';
import '../api_data_models/rateby_groups_models.dart';

class GroupService {
  static int gpType = 0;

  static Future<void> fetchAndStoreGroups() async {
    dynamic response =
        await ApiDataServiceFlaxi().getGroups(GlobalAccess.driverID);
    if (response is GroupsModels) {
      GroupsModels groupsModels = response;
      Group? group = await MyStore.retriveDrivergroup('drivergroup');
      Group selectedGroup;
      if (group != null) {
        selectedGroup = groupsModels.dataList!.singleWhere(
            (element) => element.syskey == group.syskey,
            orElse: () => groupsModels.dataList!.first);
       List<Group> allGroups = groupsModels.dataList!;
       MyStore.storeDriverGroupList(allGroups, 'GroupList');
      } else {
        selectedGroup = groupsModels.dataList!.first; 
        List<Group> allGroups = groupsModels.dataList!;
       MyStore.storeDriverGroupList(allGroups, 'GroupList');
      }
      gpType = selectedGroup.type;
      MyStore.storeDrivergroup(selectedGroup, 'drivergroup');
      MyStore.storeDrivergroup(selectedGroup, 'drivergroupsys');
      logger.i(("SelectedGp ${selectedGroup.toJson()}"));
    } else if (response is ErrorModel) {
      ErrorModel errorModel = response;
      logger.i(errorModel.toJson());
    }
  }

  static Future<void> fetchAndStoreRate() async {
    Group? group = await MyStore.retriveDrivergroup('drivergroup');
    if (group == null) {
      await GroupService.fetchAndStoreGroups();
      group = await MyStore.retriveDrivergroup('drivergroup');
      if (group == null) {
        //throw Exception('Driver group data or syskey not found');
        return;
      }
      dynamic response = await ApiDataServiceFlaxi().ratebyGroups(group.syskey);
      if (response is RatebyGroups) {
        RatebyGroups ratebyGroups = response;
        await MyStore.storeRatebyGroup(ratebyGroups.dataList, 'ratebydomain');
        //Rate selectedRate;

        logger.i(("SelectedRate ${ratebyGroups.toJson()}"));  
      } else if (response is ErrorModel) {
        ErrorModel errorModel = response;
        logger.i(errorModel.toJson());
      }
    } else {
      dynamic response = await ApiDataServiceFlaxi().ratebyGroups(group.syskey);
      if (response is RatebyGroups) {
        RatebyGroups ratebyGroups = response;
        await MyStore.storeRatebyGroup(ratebyGroups.dataList, 'ratebydomain');
        //Rate selectedRate;

        logger.i(("SelectedRate ${ratebyGroups.toJson()}"));
      } else if (response is ErrorModel) {
        ErrorModel errorModel = response;
        logger.i(errorModel.toJson());
      }
    }
  }
}

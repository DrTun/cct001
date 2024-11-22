import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../geolocation/geo_data.dart';
import '../geolocation/location_notifier.dart';
import '../modules/flaxi/api/api_data_service_flaxi.dart';
import '../helpers/helpers.dart';
import '../modules/flaxi/api_data_models/groups_models.dart';
import '../modules/flaxi/api_data_models/rateby_groups_models.dart';
import '../modules/flaxi/helpers/extras_helper.dart';
import '../modules/flaxi/helpers/group_service.dart';
import '../modules/flaxi/helpers/rate_change_helpers.dart';
import '../modules/flaxi/helpers/wallet_helper.dart';
import '../providers/network_service_provider.dart';
import '../shared/global_data.dart';

class ViewDriverGroupList extends StatefulWidget {
  static const routeName = '/drivergrouplist';
  const ViewDriverGroupList({super.key});

  @override
  State<ViewDriverGroupList> createState() => _ViewDriverGroupListState();
}

class _ViewDriverGroupListState extends State<ViewDriverGroupList> {

  final networkService = NetworkServiceProvider();
  late List<dynamic>? _groupList = [];
  String? _selectedId;
  bool isloading = true;
  bool loading = true;
  String text = 'Empty Driver Group!';
  Group? storedGroup;

  Future<void> driverGroupList() async {
    await NetworkServiceProvider.checkConnectionStatus();
    String driverID = GlobalAccess.driverID;
    final hasUserOrToken =
        GlobalAccess.userID.isNotEmpty && GlobalAccess.accessToken.isNotEmpty;
    try {
      if(networkService.isOnline.value) {
        if (hasUserOrToken ) {
          final response = await ApiDataServiceFlaxi().getGroups(driverID);
          if (response.status == 200) {
            setState(() {
              _groupList = response.dataList!;
              isloading = false;
            });
            await _loadSelectedGroup();
            logger.i('data ${response.dataList}');
          } else {
            setState(() {
              isloading = false;
            });
          }
        } else {
          setState(() {
            isloading = false;           
          });
       }
      } else {
        setState(() {
            isloading = false;
            text = 'Connection lost!';
          });
        
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  Future<void> _loadSelectedGroup() async {
    storedGroup = await MyStore.retriveDrivergroup('drivergroup');
    if (storedGroup != null) {
      setState(() {
        _selectedId = storedGroup!.id;
      });
    } else {
      setState(() {
        _selectedId = _groupList!.first.id;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    driverGroupList();
  }

  @override
  Widget build(BuildContext context) {
    LocationNotifier notifier =
        Provider.of<LocationNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group List'),
      ),
      body: Column(
        children: [
          isloading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Expanded(
                  child: _groupList!.isNotEmpty
                      ? ListView.builder(
                          itemCount: _groupList?.length,
                          itemBuilder: (context, index) {
                            final list = _groupList![index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                              child: Card(
                                shape: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 0.4, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(6)),
                                child: RadioListTile<String>(
                                  title: Text(
                                    '${list.name}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  subtitle: Text('${list.id}'),
                                  value: list.id,
                                  groupValue: _selectedId,
                                  onChanged: (String? value) {
                                    if (GeoData.currentTrip.started) {
                                      MyHelpers.msg( message:"The group cannot be changed during an ongoing trip.");
                                      return;
                                    }
                                    setState(() {
                                      _selectedId = value; 
                                      GroupService.gpType = list.type;
                                      MyStore.storeDrivergroup(
                                          list, 'drivergroupsys');
                                      MyStore.storeDrivergroup(
                                              list, 'drivergroup')
                                          .then((_) {
                                        GroupService.fetchAndStoreRate()
                                            .then((_) {
                                          upDateRateByGroup(notifier);
                                          WalletData().initializeWallet();
                                          ExtrasData.clearExtras();
                                          MyStore.clearExtraList();
                                        });
                                      });
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ) 
                      : Center(
                          child: Text(
                          text,
                          style: const TextStyle(fontSize: 20),
                        //  textScaler : TextScaler.linear(1) ,
                        )))
        ],
      ),
    );
  }
}

Future<void> upDateRateByGroup([LocationNotifier? notifier]) async {
  List<Rate>? rateData = await MyStore.retrieveRatebyGroup('ratebydomain');
  if (rateData != null) {
    int initialAmount = int.parse(rateData[0].initial);
    int ratePerKm = int.parse(rateData[0].rate);
    String groupCurrency = rateData[0].symbol;
    int increment = 100;
    RateChangeHelper.updateRateData(
        initialAmount, ratePerKm, increment, groupCurrency, notifier);
  } else {
    RateChangeHelper.updateRateData(0, 0, 0,'MMK');
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/helpers.dart';
import '../modules/flaxi/api/api_data_service_flaxi.dart';
import '../modules/flaxi/api_data_models/driver_transaction.dart';
import '../modules/flaxi/api_data_models/groups_models.dart';
import '../providers/network_service_provider.dart';
import '../shared/app_config.dart';
import '../shared/global_data.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/date_filter.dart';

class ViewTransactions extends StatefulWidget {
  static const routeName = '/transaction';
  const ViewTransactions({super.key});

  @override
  State<ViewTransactions> createState() => _ViewTransactionsState();
}

class _ViewTransactionsState extends State<ViewTransactions> {
  final networkService = NetworkServiceProvider();
  final ScrollController _controller = ScrollController();
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();
  final driverId = GlobalAccess.driverID;
  late String domain = '';
  late String groupName = 'Driver Group';
  bool isloading = true;
  bool scrollloaddata = true;
  List<TransactionData> dataTList = [];
  List<String> date = ['Today', 'This Week', 'This Month', 'Custom'];
  int curCount = 1;
  int totalCount = 0;
  final now = DateTime.now();
  String datevalue = 'Today';
  late Group? selectedGroup;
  List<Group>? _groupList = [];
  String text = 'No Transactions!';
  bool onTapDate = false;
  bool onTapGroup = false;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    _controller.addListener(_scrollforaddData);
    await driverGroupList();
    await transactionsData(from, to, curCount);
  }

  _scrollforaddData() {
    final alldata = dataTList.length;
    bool loaddata = alldata < totalCount;
    if (loaddata && !scrollloaddata) {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 400) {
        curCount = curCount + 1;
        transactionsData(from, to, curCount);
      }
    }
  }

  Future<void> transactionsData(startdate, enddate, curCount) async {
    if (mounted) {
      setState(() {
        scrollloaddata = true;
      });
    }

    final startDate = MyHelpers.ymdDateFormatdashboard(startdate);
    final endDate = MyHelpers.ymdDateFormatdashboard(enddate);
    await NetworkServiceProvider.checkConnectionStatus();
    if (networkService.isOnline.value) {
      try {
        if (driverId.isNotEmpty && domain.isNotEmpty) {
          final response = await ApiDataServiceFlaxi().driverTranscation(
              DriverTransactionReq(
                  driverId: '',
                  startDate: startDate,
                  endDate: endDate,
                  domain: domain),
              curCount);
          if (response.status == 200) {
            List<TransactionData> datalist = response.dataList;
            totalCount = response.totalCount;
            dataTList.addAll(datalist);
            if (mounted) {
              setState(() {
                datalist = [];
                isloading = false;
                scrollloaddata = false;
                from = startdate;
                to = enddate;
                text = 'No Transactions!';
              });
            }
          } else {
            setState(() {
              text = 'Oops, something went wrong!';
              isloading = false;
              scrollloaddata = false;
              from = startdate;
              to = enddate;
            });
          }
        }
      } catch (e) {
        setState(() {
          text = 'Oops, something went wrong!';
          isloading = false;
          scrollloaddata = false;
          from = startdate;
          to = enddate;
        });
      }
    } else {
      setState(() {
        text = 'Connection lost!';
        isloading = false;
        scrollloaddata = false;
        from = startdate;
        to = enddate;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CustomDropdownMenu<String>(
                    selectedValue: datevalue,
                    items: date,
                    label: 'Date',
                    isHighlighted: onTapDate,
                    onSelected: (value) async {
                      if (value != "Custom") {
                        if (mounted) {
                          setState(() {
                            datevalue = value;
                            isloading = true;
                            onTapDate = true;
                          });
                        }
                        await transcationDatabyDate(value);
                      } else {
                        if (mounted) {
                          setState(() {
                            datevalue = value;
                            onTapDate = true;
                          });
                        }
                        await transcationDatabyDate(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: CustomDropdownMenu<Group>(
                    selectedValue: groupName,
                    items: _groupList!,
                    label: 'Group',
                    isHighlighted: onTapGroup,
                    onSelected: (value) async {
                      if (mounted) {
                        setState(() {
                          onTapGroup = true;
                          domain = value.syskey;
                          isloading = true;
                          groupName = value.name;
                          curCount = 1;
                          dataTList = [];
                          transactionsData(from, to, curCount);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            isloading
                ? const Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: dataTList.isNotEmpty
                        ? ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(
                                parent: dataTList.length < totalCount
                                    ? const ClampingScrollPhysics()
                                    : const BouncingScrollPhysics()),
                            controller: _controller,
                            itemCount: dataTList.length,
                            itemBuilder: (context, index) {
                              final data = dataTList[index];
                              final startName = data.startName
                                  .split(',Yangon Region')[0]
                                  .trim();
                              final endName = data.endName
                                  .split(',Yangon Region')[0]
                                  .trim();
                              final totalamount = MyHelpers.formatInt(
                                  int.tryParse(data.total)?.toInt() ?? 0);
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: height * 0.185,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(-1, -1),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.1),
                                          blurRadius: 1.0,
                                        ),
                                        BoxShadow(
                                          offset: const Offset(1, 1),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.2),
                                          blurRadius: 8.0,
                                        ),
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              MyHelpers.ymdDateFormatTran(
                                                  data.fDatetime),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface
                                                      .withOpacity(0.8)),
                                            ),
                                            Text(
                                                MyHelpers.ymdDateFormatTranTime(
                                                    data.fDatetime),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .inverseSurface
                                                        .withOpacity(0.8))),
                                          ],
                                        ),
                                        const Divider(
                                          color: Colors.blueGrey,
                                          thickness: 0.15,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_pin,
                                                color: Colors.blue.shade300),
                                            Flexible(
                                                child: Text(
                                              startName,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface
                                                      .withOpacity(0.8),
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            )),
                                            SizedBox(
                                              width: width * 0.23,
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: height * 0.01,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_pin,
                                                color: Colors.orange.shade300),
                                            Flexible(
                                                fit: FlexFit.tight,
                                                child: Text(
                                                  endName,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .inverseSurface
                                                          .withOpacity(0.8),
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                )),
                                            SizedBox(
                                              width: width * 0.1,
                                            ),
                                            Text(
                                              '${data.distance} km',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface
                                                      .withOpacity(0.8)),
                                            )
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.blueGrey,
                                          thickness: 0.15,
                                          height: height * 0.01,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '$totalamount ${data.symbol}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface
                                                      .withOpacity(0.9)),
                                            ),
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                    color: AppConfig
                                                        .shared.primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                child: Text(
                                                  '${data.reduceAmount} ${data.symbol}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })
                        : Center(
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 20),
                            ),
                          )),
          ],
        ),
      ),
    );
  }

  Future<void> driverGroupList() async {
    _groupList = await MyStore.retrieveGroupList('GroupList');
    selectedGroup = await MyStore.retriveDrivergroup('drivergroup');
    domain = selectedGroup?.syskey ?? _groupList!.first.syskey;
    groupName = selectedGroup?.name ?? _groupList!.first.name;
  }

  transcationDatabyDate(value) async {
    curCount = 1;
    switch (value) {
      case 'Today':
        DateTime startday = DateTime.now();
        DateTime endOfDay = DateTime.now();
        dataTList = [];
        return await transactionsData(startday, endOfDay, curCount);
      case 'This Week':
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfDay = firstDayOfWeek;
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        dataTList = [];
        return await transactionsData(startOfDay, endOfDay, curCount);
      case 'This Month':
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        dataTList = [];
        return await transactionsData(
            firstDayOfMonth, lastDayOfMonth, curCount);
      case 'Custom':
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            DateTime localFromDate = from;
            DateTime localToDate = to;
            dataTList = [];
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: const Text('Filter'),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
                  content: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: localFromDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (selectedDate != null) {
                              if (mounted) {
                                setState(() {
                                  localFromDate = selectedDate;
                                });
                              }
                            }
                          },
                          child: InputDecorator(
                            decoration: buildDatePickerInputDecoration('From'),
                            child: Text(
                              DateFormat("dd/MM/yyyy").format(localFromDate),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: localToDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (selectedDate != null) {
                              if (mounted) {
                                setState(() {
                                  localToDate = selectedDate;
                                });
                              }
                            }
                          },
                          child: InputDecorator(
                            decoration: buildDatePickerInputDecoration('To'),
                            child: Text(
                              DateFormat("dd/MM/yyyy").format(localToDate),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        transactionsData(from, to, curCount);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                      ),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isloading = true;
                          datevalue = value;
                          from = localFromDate;
                          to = localToDate;
                          transactionsData(from, to, curCount);
                        });

                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                );
              },
            );
          },
        );
    }
  }
}

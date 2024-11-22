import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/helpers.dart';
import '../modules/flaxi/api/api_data_service_flaxi.dart';
import '../modules/flaxi/api_data_models/dashboard_models.dart';
import '../modules/flaxi/api_data_models/groups_models.dart';
import '../shared/global_data.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/date_filter.dart';
import 'view_dashboard_details.dart';

class ViewDashboard extends StatefulWidget {
  static const routeName = '/dashboard';
  const ViewDashboard({super.key});
  @override
  State<ViewDashboard> createState() => _ViewDashboardState();
}

class _ViewDashboardState extends State<ViewDashboard> {
  late List<Data> _dashboardData = [];
  late String totalamount = '0';

  final hasUserOrToken =
      GlobalAccess.userID.isNotEmpty && GlobalAccess.accessToken.isNotEmpty;
  final driverID = GlobalAccess.driverID;
  late String domain = '';
  String dtype = 'self';
  late int admin = 0;

  final now = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  String datevalue = 'Today';

  List<Group>? _groupList = [];
  String? _selectedname;

  bool isloading = true;
  bool onTapDate = false;
  bool onTapGroup = false;
  bool onTapType = false;

  List<String> date = ['Today', 'This Week', 'This Month', 'Custom'];
  List<String> type2 = ['self', 'all'];
  List<String> type1 = ['self'];
  late List<String> type = [];

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    try {
      await driverGroupList();
      await dashBoarddata(fromDate, toDate);
      setState(() {
        isloading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  Future<void> dashBoarddata(startDate, endDate) async {
    final startdate = MyHelpers.ymdDateFormatdashboard(startDate);
    final enddate = MyHelpers.ymdDateFormatdashboard(endDate);
    final type = dtype;
    if (hasUserOrToken) {
      final response = await ApiDataServiceFlaxi().driverDashboard(
          DashboardReqModel(
              driverid: driverID,
              startdate: startdate,
              enddate: enddate,
              domain: domain,
              type: type));
      if (response.status == 200) {
        _dashboardData = response.driverdata;
        totalamount = MyHelpers.formatInt(
            int.tryParse(_dashboardData.first.totalAmount)?.toInt() ?? 0);
        if (mounted) {
          setState(() {
            isloading = false;
            fromDate = startDate;
            toDate = endDate;
          });
        }
      }
    }
  }

  dashboardData(value) async {
    switch (value) {
      case 'Today':
        DateTime startday = DateTime.now();
        DateTime endOfDay = DateTime.now();
        return await dashBoarddata(startday, endOfDay);
      case 'This Week':
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfDay = firstDayOfWeek;
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return await dashBoarddata(startOfDay, endOfDay);
      case 'This Month':
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return await dashBoarddata(firstDayOfMonth, lastDayOfMonth);
      case 'Custom':
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            DateTime localFromDate = fromDate;
            DateTime localToDate = toDate;
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
                              setState(() {
                                localFromDate = selectedDate;
                              });
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
                          datevalue = value;
                          fromDate = localFromDate;
                          toDate = localToDate;
                          dashBoarddata(fromDate, toDate);
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

  Future<void> driverGroupList() async {
    _groupList = await MyStore.retrieveGroupList('GroupList');
    await _loadSelectedGroup();
  }

  Future<void> _loadSelectedGroup() async {
    final storedGroup = await MyStore.retriveDrivergroup('drivergroup');
    try {
      if (storedGroup!.isAdmin == 1) {
        setState(() {
          domain = storedGroup.syskey;
          _selectedname = storedGroup.name;
        });
      } else {
        setState(() {
          domain = storedGroup.syskey;
          _selectedname = storedGroup.name;
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

  Future<void> _adminChange() async {
    final storedGroup = await MyStore.retriveDrivergroup('drivergroup');
    try {
      if (storedGroup!.isAdmin == 1) {
        setState(() {
          admin = 1;
          type = type2;
        });
      } else {
        setState(() {
          //  dtype = 'self';
          admin = 0;
          type = type1;
        });
        //await  dashBoarddata(fromDate, toDate);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder(
        future: _adminChange(),
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomDropdownMenu<String>(
                        selectedValue: datevalue,
                        items: date,
                        label: 'Date',
                        isHighlighted: onTapDate,
                        onSelected: (value) async {
                          if (value != "Custom") {
                            setState(() {
                              datevalue = value;
                              isloading = true;
                              onTapDate = true;
                            });
                            await dashboardData(value);
                          } else {
                            setState(() {
                              datevalue = value;
                              onTapDate = true;
                            });
                            await dashboardData(value);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: width * 0.05),
                    Expanded(
                      flex: 2,
                      child: CustomDropdownMenu<Group>(
                        selectedValue: _selectedname ?? 'Group',
                        items: _groupList!,
                        label: 'Group',
                        isHighlighted: onTapGroup,
                        onSelected: (value) async {
                          if (mounted) {
                            setState(() {
                              isloading = true;
                              _selectedname = value.name;
                              domain = value.syskey;
                              onTapGroup = true;
                            });
                          }

                          await dashBoarddata(fromDate, toDate);
                        },
                      ),
                    ),
                    SizedBox(width: width * 0.05),
                    Expanded(
                      flex: 2,
                      child: CustomDropdownMenu<String>(
                        selectedValue: dtype,
                        items: type,
                        label: 'Type',
                        isHighlighted: onTapType,
                        onSelected: (value) async {
                          if (mounted) {
                            setState(() {
                              isloading = true;
                              dtype = value;
                              onTapType = true;
                            });
                          }
                          await dashBoarddata(fromDate, toDate);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                isloading
                    ? const Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator()),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          DashboardBox(
                            text: 'Total Trips',
                            data: _dashboardData.isNotEmpty
                                ? _dashboardData.first.tripCount
                                : '0',
                          ),
                          DashboardBox(
                            text: 'Distance by km',
                            data: _dashboardData.isNotEmpty &&
                                    _dashboardData.first.distance != ' km'
                                ? _dashboardData.first.distance
                                : '0 km',
                          ),
                          DashboardBox(
                            text: 'Trip Duration',
                            data: _dashboardData.isNotEmpty
                                ? _dashboardData.first.duration
                                : '0 min(s)',
                          ),
                          DashboardBox(
                            text: 'Total Amount',
                            data: _dashboardData.isNotEmpty
                                ? "$totalamount  Ks"
                                : '0 Ks',
                          ),
                          Visibility(
                            visible:
                                admin == 1 && dtype == 'all' ? true : false,
                            child: InkWell(
                                onTap: () {
                                  String fromdate =
                                      MyHelpers.ymdDateFormatdashboard(
                                          fromDate);
                                  String todate =
                                      MyHelpers.ymdDateFormatdashboard(toDate);
                                  Navigator.pushNamed(
                                      context, ViewDashboardDetails.routeName,
                                      arguments: DriverDashBoardDetailsReq(
                                          driverid: driverID,
                                          startdate: fromdate,
                                          enddate: todate,
                                          domain: domain));
                                },
                                child: DashboardBox(
                                  text: 'Total Drivers',
                                  data: _dashboardData.isNotEmpty
                                      ? _dashboardData.first.driverCount
                                      : '0 of 0 drivers',
                                )),
                          ),
                        ],
                      ),
              ],
            ),
          );
        });
  }
}

class DashboardBox extends StatefulWidget {
  const DashboardBox({
    super.key,
    required this.text,
    required this.data,
  });

  final String text;
  final String data;

  @override
  State<DashboardBox> createState() => _DashboardBoxState();
}

class _DashboardBoxState extends State<DashboardBox> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                offset: const Offset(-1, -1),
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                blurRadius: 1.0,
              ),
              BoxShadow(
                offset: const Offset(1, 1),
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                blurRadius: 8.0,
              ),
            ]),
        height: height * 0.1,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              widget.text,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            Text(widget.data,
                style: const TextStyle(
                  fontSize: 20,
                ))
          ],
        ),
      ),
    );
  }
}

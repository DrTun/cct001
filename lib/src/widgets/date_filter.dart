import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helpers.dart';
import '../shared/app_config.dart';

class Popbutton extends StatefulWidget {
  final void Function() today;
  final void Function() week;
  final void Function() month;
  final Function(String fromDate, String toDate) onDateRangeSelected;
  const Popbutton(
      {super.key,
      required this.today,
      required this.week,
      required this.month,
      required this.onDateRangeSelected});

  @override
  State<Popbutton> createState() => _PopbuttonState();
}

class _PopbuttonState extends State<Popbutton> {
  
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  int tabdatechoose =0;
  String formatDate(DateTime date) {
    return DateFormat('yyyyMMdd').format(date); // Ensure correct format
  }

  @override
  void initState() {
    tabdatechoose =  MyStore.prefs.getInt('tabint') ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            _popItems(context);
          },
          child: CircleAvatar(
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              foregroundColor: Theme.of(context).cardTheme.surfaceTintColor,
              child: Icon(
                  size: 25,
                  Icons.calendar_month_outlined,
                  color: Colors.grey.shade500)),
        ),
      ],
    );
  }

  Future<dynamic> calendarbox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create a local state for the dialog to handle date changes
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
                          setState(() {
                            localToDate = selectedDate;
                          });
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      tabdatechoose =3;
                      _saveInt(tabdatechoose );
                      fromDate = localFromDate;
                      toDate = localToDate;
                    });
                    widget.onDateRangeSelected(
                      fromDate.toIso8601String().split('T')[0],
                      toDate.toIso8601String().split('T')[0],
                    );
                    log(" dte${fromDate.toIso8601String().split('T')[0]}");
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
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
  void _saveInt(tabdatechoose) async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    prefs.setInt('tabint',tabdatechoose);
  });
}
  Future<void> _popItems(BuildContext context) async {
      Color iconcolor =  AppConfig.shared.primaryColor.shade600;
    await showMenu(
      color: Theme.of(context).colorScheme.surface,
      context: context,
      position: const RelativeRect.fromLTRB(100, 90, 0, 0),
      items: [
        PopupMenuItem(
            onTap:(){
              tabdatechoose = 0;
              widget.today();
              resetCustomSelectedDate();
              _saveInt(tabdatechoose );
            } ,
            child: DatepopItem(
              icon: Icons.calendar_today,
              text : 'Today',
              popColor: tabdatechoose==0?  iconcolor : Theme.of(context).colorScheme.onSurface,
              borderColor: tabdatechoose==0?  iconcolor : Theme.of(context).colorScheme.surface,
              )),
        PopupMenuItem(
            onTap: () {
              tabdatechoose = 1;
              widget.week();
              resetCustomSelectedDate();
              _saveInt(tabdatechoose );
            },
            child:DatepopItem(
              icon: Icons.calendar_month,
              text : 'This Week',
              popColor: tabdatechoose==1?  iconcolor : Theme.of(context).colorScheme.onSurface,
              borderColor: tabdatechoose==1?  iconcolor : Theme.of(context).colorScheme.surface,
              )),
        PopupMenuItem(
            onTap: () {
              tabdatechoose =2;
              widget.month();
              resetCustomSelectedDate();
              _saveInt(tabdatechoose );
            },
            child: DatepopItem(
              icon: Icons.calendar_view_month_sharp,
              text : 'This Month',
              popColor: tabdatechoose==2?  iconcolor : Theme.of(context).colorScheme.onSurface,
              borderColor: tabdatechoose==2?  iconcolor : Theme.of(context).colorScheme.surface,
              )),
        PopupMenuItem(
            onTap: () { 
              calendarbox(context);
              setState(() {});
            },
            child: DatepopItem(
              icon: Icons.calendar_view_day_sharp,
              text: 'Custom',
              popColor: tabdatechoose==3?  iconcolor : Theme.of(context).colorScheme.onSurface,
              borderColor: tabdatechoose==3?  iconcolor : Theme.of(context).colorScheme.surface,
              
              ))
      ],
    );
  }

  void resetCustomSelectedDate() {
    return setState(() {
      fromDate = DateTime.now();
      toDate = DateTime.now();
    });
  }
}

class DatepopItem extends StatelessWidget {
  final String text;
  final Color popColor;
  final IconData  icon;
  final Color borderColor;
  const DatepopItem({
    super.key,
    required this.text, 
    required this.popColor,
    required this.icon, 
    required this.borderColor,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: BorderDirectional(bottom: BorderSide(color : borderColor,width: 1))
      ),
      child: Row(
      children: [
        Icon(
          icon,color: popColor,
        ),
        const SizedBox(width: 5),
        Text(
          text,style: TextStyle(color: popColor),
        ),
      ],
    )
    );
  }
}

InputDecoration buildDatePickerInputDecoration(String hint) {
  return InputDecoration(
    border: const UnderlineInputBorder(
      borderSide: BorderSide.none,
    ),
    isDense: true,
    labelText: hint,
    hintText: hint,
    prefixIcon: const Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.calendar_month,
          color: Colors.blueAccent,
          size: 20,
        ),
        SizedBox(width: 10),
      ],
    ),
    prefixIconConstraints: const BoxConstraints(
      minHeight: 10,
      minWidth: 10,
    ),
    filled: true,
    fillColor: Colors.transparent,
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide.none,
    ),
  );
}


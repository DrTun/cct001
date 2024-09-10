import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String formatDate(DateTime date) {
    return DateFormat('yyyyMMdd').format(date); // Ensure correct format
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

  Future<void> _popItems(BuildContext context) async {
    await showMenu(
      color: Theme.of(context).colorScheme.surface,
      context: context,
      position: const RelativeRect.fromLTRB(100, 90, 0, 0),
      items: [
        PopupMenuItem(
            onTap:(){
              widget.today();
              resetCustomSelectedDate();
            } ,
            child: const NewWidget(
              text: 'Today',
              icon: Icons.calendar_today,
            )),
        PopupMenuItem(
            onTap: () {
              widget.week();
              resetCustomSelectedDate();
            },
            child:
                const NewWidget(icon: Icons.calendar_month, text: 'This week')),
        PopupMenuItem(
            onTap: () {
              widget.month();
              resetCustomSelectedDate();
            },
            child: const NewWidget(
                icon: Icons.calendar_view_month_sharp, text: 'This Month')),
        PopupMenuItem(
            onTap: () {
              calendarbox(context);
              setState(() {});
            },
            child: const NewWidget(
                icon: Icons.calendar_view_day_sharp, text: 'Custom'))
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

class NewWidget extends StatelessWidget {
  final IconData? icon;
  final String text;
  const NewWidget({
    required this.icon,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
        ),
        const SizedBox(width: 5),
        Text(
          text,
        ),
      ],
    );
  }
}

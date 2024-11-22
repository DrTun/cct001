import 'package:flutter/material.dart';

import '../shared/app_config.dart';

class CustomDropdownMenu<T> extends StatelessWidget {
  final String selectedValue;
  final List<T> items;
  final String label;
  final void Function(T) onSelected;
  final bool isHighlighted;

  const CustomDropdownMenu({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.label,
    required this.onSelected,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.05,
      width: width * 0.3,
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
        ],
      ),
      child: PopupMenuButton<T>(
        padding: const EdgeInsets.all(0),
        constraints: BoxConstraints(minWidth: width * 0.29),
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return items.map((item) {
            String itemLabel = item is String ? item : (item as dynamic).name;
            return PopupMenuItem<T>(
              height: height * 0.05,
              value: item,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  itemLabel,
                  style: TextStyle(color: itemLabel == selectedValue ? AppConfig.shared.primaryColor : null),
                ),
              ),
            );
          }).toList();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text(
                  selectedValue,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: isHighlighted ? AppConfig.shared.primaryColor : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
               Icon(Icons.arrow_drop_down_sharp, color: AppConfig.shared.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
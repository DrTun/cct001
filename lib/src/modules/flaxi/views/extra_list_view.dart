
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helpers/helpers.dart';
import '../../../providers/mynotifier.dart';
import '../api_data_models/rateby_groups_models.dart';
import '../helpers/extras_helper.dart';

class ExtraListView extends StatefulWidget {
  static const routeName = '/extrasList';

  const ExtraListView({super.key});

  @override
  State<ExtraListView> createState() => _ExtraListViewState();
}

class _ExtraListViewState extends State<ExtraListView> {
  late MyNotifier notifier;
  bool isEmpty = false;
  ExtrasData extrasData = ExtrasData.curExtrasData;

  @override
  void initState() {
    notifier = Provider.of<MyNotifier>(context, listen: false);
    super.initState();
    _loadRate(); 
    _loadSelectedExtras(); 
  }


  Future<void> _loadSelectedExtras() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedExtras = prefs.getStringList('selectedExtras');

    if (savedExtras != null) {
      setState(() {
        extrasData.selectedExtras =
            savedExtras.map((e) => e == 'true').toList();
      });
    } else {
      extrasData.selectedExtras =
          List.generate(extrasData.currentExtrasList.length, (index) => false);
    }
  }

  Future<void> _loadRate() async {
    if (extrasData.currentExtrasList.isEmpty) {
      List<Rate>? rate = await MyStore.retrieveRatebyGroup('ratebydomain');
      if (rate != null && rate[0].extras != null) {
        List<Extras> extras = rate[0].extras!;
        if (extras.isNotEmpty) {
          extrasData.currentExtrasList = extras
              .map((e) => Extra(
                    name: e.name,
                    amount: e.amount,
                    type: e.type.toString(),
                  ))
              .toList();
        }
      } else {
        extrasData.currentExtrasList = [];
        isEmpty = true;
      }
       extrasData.selectedExtras =
          List.generate(extrasData.currentExtrasList.length, (index) => false);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyNotifier>(
        builder: (BuildContext context, MyNotifier value, Widget? child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Extras List'),
        ),
        body: extrasData.currentExtrasList.isNotEmpty
            ? ListView.builder(
                itemCount: extrasData.currentExtrasList.length,
                itemBuilder: (context, index) {
                  final item = extrasData.currentExtrasList[index];
                  bool showButtons = item.type == "1";

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Checkbox(
                          value: index < extrasData.selectedExtras.length
                              ? extrasData.selectedExtras[index]
                              : false,
                          onChanged: (bool? value) {
                            if (index < extrasData.selectedExtras.length) {
                              setState(() {
                                extrasData.toggleExtra(index, notifier);
                                MyStore.saveSelectedExtras(); 
                              });
                            }
                          },
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount: ${MyHelpers.formatInt(int.parse(item.amount))}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (showButtons)
                              Text(
                                'Count: ${item.qty}',
                                style: const TextStyle(fontSize: 14),
                              ),
                          ],
                        ),
                        trailing: (showButtons &&
                                index < extrasData.selectedExtras.length &&
                                extrasData.selectedExtras[index])
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.1,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4.0, vertical: 0.0),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                              extrasData.decreaseCount(
                                                  index, notifier);
                                              setState(() {
                                                if (item.qty == 0) {
                                                  extrasData.selectedExtras[
                                                      index] = false;
                                                }
                                              });
                                              MyStore.saveSelectedExtras(); // Save to SharedPreferences after change
                                            })),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.1,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 0.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        shape: BoxShape.rectangle,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            extrasData.increaseCount(
                                                index, notifier);
                                            setState(() {
                                              if (item.qty > 0) {
                                                extrasData
                                                        .selectedExtras[index] =
                                                    true;
                                              }
                                            });
                                            MyStore.saveSelectedExtras(); 
                                          }),
                                    ),
                                  ],
                                ),
                              )
                            : null, 
                      ),
                    ),
                  );
                },
              )
            : isEmpty
                ? const Center(
                    child: Text(
                      'There are no extras available.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : const LinearProgressIndicator(), 
      );
    });
  }
}

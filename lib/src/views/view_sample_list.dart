import 'package:flutter/material.dart'; 
import 'view_sample_details.dart'; 
import '../shared/arguments.dart';
class ViewList extends StatelessWidget {
  const ViewList({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });
  static const routeName = '/sample';
  final List<SampleItem> items;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form List'),
      ), 
      body: ListView.builder( 
        restorationId: 'sampleItemListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          return ListTile(
            title: Text('List Item ${item.id}'), 
            onTap: () { 
              Navigator.pushNamed( 
                context,ViewDetails.routeName, arguments: ArgumentModel01('ID #','${item.id}'), 
              );
            }
          );
        },
      ),
    );
  }
}
class SampleItem {
  const SampleItem(this.id);
  final int id;
}

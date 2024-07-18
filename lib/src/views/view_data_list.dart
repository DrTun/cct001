import 'package:flutter/material.dart';  
import 'view_data_details.dart';
//  -------------------------------------    Databases (Property of Nirvasoft.com)
class ViewDataList extends StatefulWidget {
  static const routeName = '/formdatalist';
  const ViewDataList({super.key});
  @override
  State<ViewDataList> createState() => _ViewDataListState();
}
class _ViewDataListState extends State<ViewDataList> { 
  final dataController = TextEditingController(); 
  @override
  void initState() {
    super.initState();   
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List'),
      ), 
      body: Column(
        children: <Widget>[
          const SizedBox(height: 10), 
          const Text("Show the list"),
          const SizedBox(height: 10), 
          ElevatedButton(
            onPressed: () async {
              Navigator.pushNamed(context,ViewDataDetails.routeName, );  
            },
            child: const Text('Go to Details'),
          ),
        ],
      )
    );
  }
  Future<void> doIt() async { 
  }
}
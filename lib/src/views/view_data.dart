import '/src/helpers/env.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'view_data_list.dart';
//  -------------------------------------    Databases (Property of Nirvasoft.com)
class ViewData extends StatefulWidget {
  static const routeName = '/formdata';
  const ViewData({super.key});
  @override
  State<ViewData> createState() => _ViewDataState();
}
class _ViewDataState extends State<ViewData> { 
  final dataController = TextEditingController(); 
  @override
  void initState() {
    super.initState();   
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database'),
      ), 
      body: Column(
        children: <Widget>[
          TextField(
            controller: dataController,
            decoration: const InputDecoration(
              hintText: 'Type something...',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              var db = await openDatabase('my_db.db');
              await db.insert('my_table', {'data': dataController.text});
              await db.close();
              dataController.clear();
            },
            child: const Text('Insert Test'),
          ),
          ElevatedButton(
            onPressed: () async {
              var db = await openDatabase('my_db.db');
              var data = await db.query('my_table');
              await db.close();
              logger.i(data);
            },
            child: const Text('Read Test'),
          ),
          ElevatedButton(
            onPressed: () async {
              var db = await openDatabase('my_db.db');
              var data = await db.query('my_table');
              await db.close();
              logger.i(data);
            },
            child: const Text('Create Table'),
          ),
          const SizedBox(height: 50), 
          ElevatedButton(
            onPressed: () async {
              Navigator.pushNamed(context,ViewDataList.routeName, );  
            },
            child: const Text('Go to List'),
          ),
        ],
      )
    );
  }
  Future<void> doIt() async { 
  }

  void initData() async {
    var db = await openDatabase('my_db.db');
    await db.execute('CREATE TABLE IF NOT EXISTS my_table (id INTEGER PRIMARY KEY, data TEXT)');
    await db.close();
  } 
  void sampleData() async {
    var db = await openDatabase('my_db.db');
    await db.insert('my_table', {'data': 'Hello, World!'});
    await db.close();
  }
}
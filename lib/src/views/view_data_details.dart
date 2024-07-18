import 'package:flutter/material.dart';  
//  -------------------------------------    Databases (Property of Nirvasoft.com)
class ViewDataDetails extends StatefulWidget {
  static const routeName = '/formdatadetails';
  const ViewDataDetails({super.key});
  @override
  State<ViewDataDetails> createState() => _ViewDataDetailsState();
}
class _ViewDataDetailsState extends State<ViewDataDetails> { 
  final dataController = TextEditingController(); 
  @override
  void initState() {
    super.initState();   
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ), 
      body: const Column(
        children: <Widget>[
          SizedBox(height: 10), 
          Text("Edit Records")
        ],
      )
    );
  }
  Future<void> doIt() async { 
  }
}
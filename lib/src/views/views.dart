import '../views/view_data.dart';
import '../views/view_sample_list.dart';

import '../shared/appconfig.dart';

import '../signin/signinpage.dart';

import '../providers/mynotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_data.dart'; 
import '../helpers/helpers.dart';   
//  -------------------------------------    Forms (Property of Nirvasoft.com)
class ViewBlank extends StatelessWidget {
  const ViewBlank({super.key});
  @override
  Widget build(BuildContext context) {
    // Consumer Declaration #1
    return Consumer<MyNotifier>(
      builder: (context, provider , child) {
    // Consumer #1 
      return  const Text(" ");
      },
    );
   }
}
class ViewApps extends StatelessWidget {
  const ViewApps({super.key});
  @override
  Widget build(BuildContext context) {
    return Column( children: [ 
        const SizedBox(height: 20),
        const Text('Samples Apps', style: TextStyle(fontSize: 20),),
        

        const SizedBox(height: 20), 
        TextButton( onPressed: () => throw Exception(), child: const Text('Crash Test', 
          style: TextStyle(decoration: TextDecoration.underline)),),

        const SizedBox(height: 20), 
        TextButton( onPressed: () { Navigator.pushNamed(context,ViewList.routeName, ); }, child: const Text('Form List', 
          style: TextStyle(decoration: TextDecoration.underline)),),

        
        const SizedBox(height: 20), 
        TextButton( onPressed: () { Navigator.pushNamed(context,ViewData.routeName, ); }, child: const Text('SQFlite', 
          style: TextStyle(decoration: TextDecoration.underline)),),

        const SizedBox(height: 20), 
        TextButton( onPressed: () { Navigator.pushNamed(context,View001.routeName, ); }, child: const Text('API Data', 
          style: TextStyle(decoration: TextDecoration.underline)),),
    ]
    );
  }
}

class View001 extends StatefulWidget {
  static const routeName = 'form001';
  const View001({super.key});
  @override
  State<View001> createState() => _View001State();
}
class _View001State extends State<View001> {
  late final ApiDataService apiDataService;  
  final dataController = TextEditingController(); 
  @override
  void initState() {
    super.initState();
    apiDataService = ApiDataService(); 
  }
  @override
  Widget build(BuildContext context) { 
    // add this for Consumer *************************************** //
    return  Consumer<MyNotifier>(
      builder: (BuildContext context, MyNotifier value, Widget? child) { 
      // add this for Consumer *************************************** //
      return 
        Scaffold(
        appBar: AppBar(
        title: const Text('Database'),
        ), 
        body:

        Column(
        children: [
        const SizedBox(height: 10),
        const Text('Form 001', style: TextStyle(fontSize: 20),),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: getList,child: const Text('Data API'),),      
        TextField(controller: dataController,maxLines: 8,),
        TextButton(onPressed: (){dataController.text="";},child: const Text('Clear', style: TextStyle(decoration: TextDecoration.underline)),),
        const SizedBox(height: 50),
        const View002(), 
        ],
        )
        );
      // add this for Consumer *************************************** //
      }
    );
    // add this for Consumer *************************************** //
  }
    Future<void> getList() async {
    try {
      final apiDataResponse = await apiDataService.getList(); 
      if (apiDataResponse['status'] == 200 || apiDataResponse['status'] == 201) {
         if (apiDataResponse['status'] == 201) MyHelpers.msg("Refreshed and Retried Successful.",sec:5,bcolor: Colors.lightBlueAccent); 
        dataController.text = apiDataResponse['data'].map((user) => user['user_id'].toString()).join('\n'); 
      } else if (apiDataResponse['status'] == 500) { // Other Exceptions from Class
        MyHelpers.msg("Connectivity [50x]"); 
      } else { 
        setState(() { Navigator.pushReplacementNamed(context,SigninPage.routeName, );}); 
        MyHelpers.msg("Session Expired. Sign In");
      }
    } catch (e, stacktrace) { // Other Exceptions from Widget
      if (AppConfig.shared.log>=1) logger.e("Connectivity #50xx (Data List): $e\n$stacktrace");
      MyHelpers.msg("Connectivity [50xx]"); 
    }
    }
}

class View002 extends StatelessWidget {
  static const routeName = '/root/form002';
  const View002({super.key});
  @override
  Widget build(BuildContext context) {
    // Consumer Declaration #1
    return Consumer<MyNotifier>(
      builder: (context, provider , child) {
    // Consumer #1 
      return 
          Column(children: [
            const SizedBox(height: 10),
            const Text("Form 002", style:  TextStyle(fontSize: 20),),
            const SizedBox(height: 10),
            const Text("Root Page  >  Form 001  > Form 002"),
            const SizedBox(height: 10),
            const Text("Consumer"),
            const SizedBox(height: 10),
            Text(' ${provider.data01.name}',style: const TextStyle(color: Colors.red),),
          ]); // Comsumming provider data 
    // Consumer #2
      },
    );
    // Consumer 
   }
}




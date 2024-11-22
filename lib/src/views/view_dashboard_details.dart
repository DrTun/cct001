import 'package:flutter/material.dart';

import '../modules/flaxi/api/api_data_service_flaxi.dart';
import '../modules/flaxi/api_data_models/dashboard_models.dart';

class ViewDashboardDetails extends StatefulWidget{
  static const routeName = '/dashboarddetails';


  final DriverDashBoardDetailsReq dashBoardDetailsReq;
  const ViewDashboardDetails({super.key, required this.dashBoardDetailsReq});

  @override
  State<ViewDashboardDetails> createState() => _ViewDashboardDetailsState();
}

class _ViewDashboardDetailsState extends State<ViewDashboardDetails> {

  List<Detailsdata> detailsData= [];
  bool isloading = true;

  driverGroupDetails() async{
      final response = await ApiDataServiceFlaxi().driverDashboardDetails(widget.dashBoardDetailsReq);      
      if (response.status == 200) {
        setState(() {
          detailsData = response.data;
        });
      }  
  }

  loadData() async {
    try {
      await driverGroupDetails();
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

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    //final width  = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Details'),),
      body: isloading
      ? const Center(child: CircularProgressIndicator(),)
      : Column(
        children: [
          Expanded(
            child: detailsData.isEmpty 
            ?  const Center(child: Text('Empty Driver Details!',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),))
            : ListView.builder(
              itemCount: detailsData.length,
              itemBuilder: (context,index) {
              final Detailsdata  data = detailsData[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: height *0.13,
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context)
                      .colorScheme
                      .surface, 
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(-1, -1),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.1), 
                      blurRadius: 1.0,
                    ),
                    BoxShadow(
                      offset: const Offset(1, 1),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2), 
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                  child: 
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(data.name,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(data.vehicleno),Text(data.taxigroup)],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DataIcon(icon: Icons.time_to_leave_sharp,text: data.tripCount,),
                            DataIcon(icon:  Icons.directions,text: '${data.distance} km',),
                            DataIcon(icon: Icons.access_time_sharp,text:data.duration,),
                          ],
                          )
                      ],
                    ),
                  ),
                ),
              );
            }) 
          ),
        ],
      )
    );
  }
}

class DataIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const DataIcon({
    super.key, required this.icon, required this.text,
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20,color: Colors.blue,),
        const SizedBox(width: 3,),
        Text(text),
      ],
    );
  }
}


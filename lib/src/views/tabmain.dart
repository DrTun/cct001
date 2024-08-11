import 'package:flutter/material.dart';
import '../geolocation/mapview.dart';

class MainTab extends StatefulWidget {
  const MainTab({super.key});

  @override
  MainTabState createState() => MainTabState();
}
class MainTabState extends State<MainTab> {
  @override
  void initState() {
    super.initState();
    setState(() { 
    });
  }
  @override
  Widget build(BuildContext context) { 
        return   Scaffold(
          body: 
          Padding(
          padding:  const EdgeInsets.all(8.0),
          child:
          GridView.count(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children:  [ 
                        GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, MapView.routeName);
                        },
                        child:
                            Card(elevation: 3,shadowColor: Colors.grey,
                              child: 
                              Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Column(
                                  children: [
                                    Image.asset('assets/images/map.png', width: 100,height: 100,),
                                    const Text('Route Management',textAlign: TextAlign.center,),
                                  ],
                                ),
                              )
                            ),
                        ),
                          const Card(elevation: 3,shadowColor: Colors.grey,
                            child: Text(''),
                          ),
                          const Card(elevation: 3,shadowColor: Colors.grey,
                            child: Text(''),
                          ),
                          const Card(elevation: 3,shadowColor: Colors.grey,
                            child: Text(''),
                          ),
                    ],
              ),

          )


        );
  } 
}
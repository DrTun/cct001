import 'package:flutter/material.dart';
import '/src/geolocation/locationnotifier.dart';
import 'package:provider/provider.dart';
import '../geolocation/mapview.dart';
import 'cards/blankcard.dart';
import 'cards/mapcard.dart';
class MainCards extends StatefulWidget {
  const MainCards({super.key});
  @override
  MainCardsState createState() => MainCardsState();
}
class MainCardsState extends State<MainCards> {
  @override
  void initState() {
    super.initState();
    
    setState(() { 
    });
  }
  @override
  Widget build(BuildContext context) { 



    return Consumer<LocationNotifier>(
      builder: (context, provider , child) {




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
                        child:mapcard(provider.tripdata)),        

                        GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, MapView.routeName);
                        },
                        child: blankcard(""))
                        ,

                        GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, MapView.routeName);
                        },
                        child: blankcard(""))
                        ,
                    ],
              ),

          )
        );




      });




  } 
}


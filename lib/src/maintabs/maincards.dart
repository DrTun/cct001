import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../geolocation/geodata.dart';
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
        if (GeoData.currentTrip.started) {
          GeoData.startTimer(provider);
        }  
        return   Scaffold(
          body: 
          Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
          child:  
            StaggeredGrid.count(
              crossAxisCount: 8,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
                    children:  [ 
                        StaggeredGridTile.count(
                        crossAxisCellCount: 8,  
                        mainAxisCellCount: 4,   
                        child: 
                        GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, MapView.routeName);
                        },
                        child:mapcard( fsize: 42)),        
                        ),
                       StaggeredGridTile.count(
                        crossAxisCellCount: 4,mainAxisCellCount:2,
                        child: GestureDetector(
                        onTap: () {},
                        child: blankcard("1"))
                       ),
                       StaggeredGridTile.count(
                        crossAxisCellCount: 4,mainAxisCellCount: 2,
                        child: GestureDetector(
                        onTap: () {
                          //Navigator.pushNamed(context, MapViewGoogle.routeName);
                        },
                        child: blankcard("2"))
                       ),

                       StaggeredGridTile.count( crossAxisCellCount: 4, mainAxisCellCount: 4,
                        child: GestureDetector(onTap: () {}, child: blankcard("3"))
                       ),  

                       StaggeredGridTile.count( crossAxisCellCount: 4, mainAxisCellCount: 2,
                        child:  GestureDetector( onTap: () {  },  child: blankcard("4"))
                       ),  
                       StaggeredGridTile.count( crossAxisCellCount: 4, mainAxisCellCount: 2,
                        child:  GestureDetector( onTap: () {  },  child: blankcard("5"))
                       ),  

                    ],
              ),
          )
        )
        );
      });
  } 
}


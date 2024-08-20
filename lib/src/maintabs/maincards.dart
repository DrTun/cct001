import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../geolocation/geodata.dart';
import '../helpers/helpers.dart';
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
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
          child:  
            StaggeredGrid.count(
              crossAxisCount: 8,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
                    children:  [ 
                        StaggeredGridTile.count(
                        crossAxisCellCount: 4,  
                        mainAxisCellCount: 3,   
                        child: 
                        GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, MapView.routeName);
                        },
                        child:mapcard(provider.tripdata)),        
                        ),
                       StaggeredGridTile.count(
                        crossAxisCellCount: 4,
                        mainAxisCellCount:2,
                        child: 
                        GestureDetector(
                        onTap: () {
                          MyHelpers.getBool(context, "Are you sure to clear trips?").then ((value) => {
                            if (value!=null && value ) GeoData.resetData()
                          });
                        },
                        child: blankcard("Clear Trip Data"))
                       ),

                       StaggeredGridTile.count(
                        crossAxisCellCount: 4,
                        mainAxisCellCount: 2,
                        child: 
                        GestureDetector(
                        onTap: () {
                        },
                        child: blankcard("1"))
                       ),

                       StaggeredGridTile.count(
                        crossAxisCellCount: 4,
                        mainAxisCellCount: 4,
                        child: 
                        GestureDetector(
                        onTap: () {
                        },
                        child: blankcard("2"))
                       ),  

                       StaggeredGridTile.count(
                        crossAxisCellCount: 4,
                        mainAxisCellCount: 3,
                        child: 
                        GestureDetector(
                        onTap: () {
                        },
                        child: blankcard("3"))
                       ),  
                    ],
              ),
          )
        )
        );
      });
  } 
}


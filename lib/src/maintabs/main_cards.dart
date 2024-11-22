import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../geolocation/geo_data.dart';
import '../geolocation/location_notifier.dart';
import 'package:provider/provider.dart';
import '../geolocation/map_view.dart';
import '../helpers/helpers.dart';
import '../xpass/service/xpass_admin_status_service.dart';
import '../xpass/view/view_xpass.dart';
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

    setState(() {});
  }

  Future<bool> _checkUserStatus() async {
    bool response = await XpassAdminStatusService.checkUserStatus();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Consumer<LocationNotifier>(builder: (context, provider, child) {
      if (GeoData.currentTrip.started) {
        GeoData.startTimer(provider);
      }
      return Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: StaggeredGrid.count(
                  crossAxisCount: 8,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 8,
                      mainAxisCellCount: 4,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, MapView.routeName);
                          },
                          child: mapcard(context, fsize: size * 0.1)),
                    ),
                    //  StaggeredGridTile.count(
                    //   crossAxisCellCount: 4,mainAxisCellCount:2,
                    //   child: GestureDetector(
                    //   onTap: () {},
                    //   child: blankcard("1"))
                    //  ),
                    //  StaggeredGridTile.count(
                    //   crossAxisCellCount: 4,mainAxisCellCount: 2,
                    //   child: GestureDetector(
                    //   onTap: () {
                    //   },
                    //   child: blankcard("2"))
                    //  ),
                    //  StaggeredGridTile.count( crossAxisCellCount: 4, mainAxisCellCount: 4,
                    //   child: GestureDetector(onTap: () {}, child: blankcard("3"))
                    //  ),

                    //  StaggeredGridTile.count( crossAxisCellCount: 4, mainAxisCellCount: 2,
                    //   child:  GestureDetector( onTap: () {  },  child: blankcard("4"))
                    //  ),
                    //  StaggeredGridTile.count( crossAxisCellCount: 4, mainAxisCellCount: 2,
                    //   child:  GestureDetector( onTap: () {Navigator.pushNamed(context, ViewSSForm01.routeName);},  child: blankcard("Social Form"))
                    //  ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 4,
                      mainAxisCellCount: 2,
                      child: GestureDetector(
                        onTap: () async {
                          if (await _checkUserStatus()) {
                            Navigator.pushNamed(context, ViewXpass.routeName);
                          } else {
                            MyHelpers.msg(
                                message: 'Unauthorized Access',
                                backgroundColor: Colors.redAccent);
                          }
                        },
                        child: blankcard("Xpass"),
                      ),
                    ),
                  ],
                ),
              )));
    });
  }
}

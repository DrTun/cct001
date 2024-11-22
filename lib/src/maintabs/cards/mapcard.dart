import 'package:flutter/material.dart';
import '../../geolocation/geo_data.dart';
import '../../modules/flaxi/helpers/extras_helper.dart';
import '../../modules/flaxi/helpers/group_service.dart';
import '../../modules/flaxi/helpers/rate_change_helpers.dart';
import '../../modules/flaxi/helpers/wallet_helper.dart';
import '../../modules/flaxi/views/extra_list_view.dart';
import '../../modules/flaxi/views/rate_scheme_view.dart';
import '../../widgets/digital_row.dart';
import '../../widgets/switch_on_trip.dart';
import '/src/helpers/helpers.dart';

Widget mapcard(
  BuildContext context, {
  bool? transparent,
  Color? fcolor,
  double? fsize,
  int? width,
}) {
  transparent ??= false;
  fcolor ??= Colors.green;
  fsize ??= 30;
  final GeoData geoData;
  final ExtrasData extrasData;
  if (GeoData.currentTrip.started) {
    geoData = GeoData.currentTrip;
  } else {
    geoData = GeoData.previousTrip;
  }
  extrasData = ExtrasData.curExtrasData;
  String speed = geoData.currentSpeed >= 1
      ? "${geoData.currentSpeed.toStringAsFixed(0)} km/h"
      : "";
  return Card(
      elevation: 3,
      shadowColor: Colors.grey,
      color: transparent ? Colors.black.withOpacity(0.4) : Colors.black,
      child: Stack(children: [
        Visibility(
          visible: GroupService.gpType != 0,
          child: Positioned(
              top: 0,
              left: 10,
              child: Row(
                children: [
                 const Icon(Icons.wallet, color: Colors.white,),
                  Padding(padding:const EdgeInsets.only(left: 5,bottom: 5),
                    child: Text(WalletData.curWalletData.currentBalance,style: const TextStyle(color: Colors.white,fontSize: 17,fontWeight: FontWeight.bold,),))
                ],
              )
             
              ),
        ),
        const Positioned(
            top: 0,
            right: 0,
            child: SwitchonTrip(
              label: "",
            )),
        Positioned(
            bottom: 0,
            right: 0,
            child: geoData.points.length % 2 ==
                    0 // showing on and off (even and odd)
                ? IconButton(
                    icon: Icon(
                      Icons.add_location_alt_outlined,
                      color: GeoData.isTransmitting
                          ? Colors.lightBlueAccent
                          : Colors.grey[400],
                    ),
                    onPressed: () async {},
                  )
                : IconButton(
                    icon: Icon(
                      Icons.add_location_alt,
                      color: GeoData.isTransmitting
                          ? Colors.lightBlueAccent
                          : Colors.grey[400],
                    ),
                    onPressed: () async {},
                  )),
        // Positioned(
        //     top: 0,
        //     left: 0,
        //     child: IconButton(
        //       icon: const Icon(
        //         Icons.chat_outlined,
        //         color: Colors.white,
        //       ),
        //       onPressed: () async {},
        //     )),
        
        Positioned(
            bottom: 0,
            left: 0,
            child: IconButton(
              icon: const Icon(
                Icons.car_rental,
                color: Colors.white,
              ),
              onPressed: () {
                // showDialog(
                //   context: context, builder: (BuildContext context) {
                //     return  const CustomPopup(message: "Title of the Pop-up");
                //   },
                // );
                GeoData.currentTrip.started
                    ? Navigator.pushNamed(context, ExtraListView.routeName)
                    : Navigator.pushNamed(context, RateSchemeView.routeName);
              },
            )),
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              //Image.asset('assets/images/map.png', width: 45,height: 45,),
              const SizedBox(height: 13),
              digitalRow(MyHelpers.formatDouble(geoData.distance), speed, " km",
                  fcolor: fcolor, fsize: fsize),
              digitalRow(
                  MyHelpers.formatTime(GeoData.tripDuration()), "", " h:m",
                  fcolor: fcolor, fsize: fsize),
              RateChangeHelper.ratePerKm != 0
                  ? digitalRow(MyHelpers.formatInt(geoData.distanceAmount), "",
                      " ${RateChangeHelper.groupCurrency}",
                      fcolor: fcolor, fsize: fsize)
                  : const SizedBox(),
              const SizedBox(
                height: 5,
              ),
              RateChangeHelper.ratePerKm != 0
                  ? digitalRow(MyHelpers.formatInt(extrasData.extraTotal + GeoData.waitingCharge),
                      "Extras", " ${RateChangeHelper.groupCurrency}",
                      fcolor: fcolor, fsize: fsize)
                  : const SizedBox(),
              //geoData.currentSpeed>=1? Text('${geoData.currentSpeed.toStringAsFixed(0)} km/h',textAlign: TextAlign.left,  style:  const TextStyle(color: Colors.white)) : const SizedBox(),
            ],
          ),
        ),
      ]));
}

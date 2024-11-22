import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../geolocation/geo_data.dart';
import '../geolocation/location_notifier.dart';
import '../helpers/helpers.dart';
import '../root_page.dart';
import '../shared/app_config.dart';

class UserInputFromTo extends StatefulWidget {
  static const routename = '/userInputFromTo';
  const UserInputFromTo({super.key});

  @override
  State<UserInputFromTo> createState() => _UserInputFromToState();
}

class _UserInputFromToState extends State<UserInputFromTo> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  bool isFrom = true;
  bool forfrom = false;
  String? token;
  var uuid = const Uuid();
  Timer? _debounce;
  String currentLocation = "Current location";
  

  @override
  void initState() {
    fromController.text = currentLocation;
    super.initState();
    fromController.addListener(() { onModify(fromController.text, true);});
    toController.addListener(() { onModify(toController.text, false); });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }
  
    void onModify(text, value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (text.isEmpty)  { setState(() {GeoData.fromtotrip.listforplaces = []; });}
      if (token == null) { setState(() { token = uuid.v4();}); }
      makeSuggestion(text, value);
    });
  }

  Future<void> makeSuggestion(String userinput, bool value) async {
    String googleplaceApiKey = AppConfig.shared.googleApiKey;
    String googleplaceUrl = AppConfig.shared.googlePlaceUrl;
    String request = '$googleplaceUrl?input=$userinput&key=$googleplaceApiKey'
        '&types=establishment'
        '&language=en'
        '&components=country:MM'
        '&radius=500'
        '&sessiontoken=$token';
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {  
      GeoData.fromtotrip.listforplaces = jsonDecode(response.body)['predictions'];
      if(mounted){
        setState(() {       
        isFrom = value;
      }); 
      }
    } else {
      
      throw Exception('Failed to fetch suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(elevation: 3,shadowColor: Colors.grey,
              child: SizedBox(
                height: height * 0.17,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox( height:15, child: Image.asset('assets/images/geo/dotblue.png',scale: .3,)),
                          CircleAvatar(backgroundColor: Colors.grey[500],radius: 2,),
                          CircleAvatar(backgroundColor: Colors.grey[500],radius: 2,),
                          CircleAvatar(backgroundColor: Colors.grey[500],radius: 2,),
                          const Text('To',style: TextStyle(fontSize: 18),),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                                height: 40,
                                width: width * 0.7,
                                child: TextFormField(  
                                  onTap: () {
                                    setState(() {
                                      forfrom = false;
                                    }); fromController.text='';},                                                                    
                                  onTapOutside: (event) {if(fromController.text.isEmpty|| forfrom==false){fromController.text = currentLocation;}  FocusScope.of(context).unfocus();},
                                  controller: fromController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                    focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                    disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                  ),
                                ),
                              ),
                          SizedBox(
                                height:40,
                                width: width*0.7,
                                child: TextFormField(
                                  onTap: () { if(fromController.text.isEmpty || forfrom==false) {                                  
                                    fromController.text = currentLocation;} },
                                  onTapOutside: (event) =>FocusScope.of(context).unfocus(),
                                  controller: toController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                    focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                    disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                    hintText: 'Enter location',
                                  ),
                                ),
                              ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: GeoData.fromtotrip.listforplaces.length,
                itemBuilder: (context, index) {
                  dynamic description = GeoData.fromtotrip.listforplaces[index] ;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async { 
                      setState(() {
                        forfrom =!forfrom;
                      });
                      await onPlaceSelected(description['description']);},
                    child: Card(
                      elevation: 3,shadowColor: Colors.grey,
                      child: SizedBox(
                        height: 45,
                        child: Row(
                          children: [
                            const SizedBox(width: 10,),
                            const Center(child: Icon(Icons.add_location_alt_outlined)),
                            const SizedBox(width: 10,),
                            Expanded(child: Text.rich(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                                TextSpan(
                                  text:'${description['structured_formatting']['main_text']}\n',
                                    style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
                                    children: [
                                      TextSpan(
                                          text: description['structured_formatting']['secondary_text'],
                                          style: const TextStyle(fontSize: 12,fontWeight: FontWeight.normal)),
                                    ]),
                              ),
                            ),
                            const SizedBox(width: 10,)
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void>  drawfromto() async {
    LocationNotifier provider = Provider.of<LocationNotifier>(context, listen: false);
    gmap.LatLng first =  await currentOrChoose(fromController.text);
    gmap.LatLng last  =  await getCoordinates(toController.text);
    PolylineResult result = await GeoData.fromtotrip.polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: AppConfig.shared.googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(first.latitude,first.longitude),
        destination:  PointLatLng(last.latitude,last.longitude),
        mode: TravelMode.driving,
        wayPoints: [],
      ),
    );

      if (result.points.isNotEmpty) {
      await GeoData().addPoint(result,provider);
      GeoData.fromto=true;
      MyStore.prefs.setBool("fromto", true);
      setState(() {
      Navigator.pushReplacementNamed(context, RootPage.routeName);
      //Navigator.pop(context);
      });
      fromController.clear();
      toController.clear();
    }

  }

  Future<gmap.LatLng>currentOrChoose(String text) async{
    if(fromController.text.isEmpty || fromController.text==currentLocation ) {
      gmap.LatLng from = gmap.LatLng(GeoData.currentLat, GeoData.currentLng);
      return from;
    }
    else {
      gmap.LatLng from = await getCoordinates(fromController.text);
      return from;
    }
  }

  Future<gmap.LatLng> getCoordinates(String address) async {
    List<Location> locations = await locationFromAddress(address);
    var places = gmap.LatLng(locations.first.latitude, locations.first.longitude);
       return  places;  
  }

  Future<void> onPlaceSelected(String description ) async {
    List<Location> locations = await locationFromAddress(description);
    debugPrint('$locations');
    setState(() {
      token = uuid.v4();
      GeoData.fromtotrip.listforplaces = [];
      isFrom
          ? fromController.text = description
          : toController.text = description;
    });
    if(toController.text == description)
      { drawfromto();}
  }
}

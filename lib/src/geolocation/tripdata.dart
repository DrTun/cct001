import 'package:latlong2/latlong.dart';

class TripData {
  // Properties
  String tripId="";
  String source="";
  String destination="";

  double distance=0;
  double currentSpeed=0;
  int duration=0;
  double distanceAmount=0;

  DateTime startTime=DateTime.now();
  bool started=false;
  DateTime endTime=DateTime.now();
  bool ended=false;
  
  List<LatLng> points=[];  // Previous Trip
  List<DateTime> dtimeList=[];

  List<LatLng> pointsFixed=[];  // Previous Trip
  List<DateTime> dtimeListFixed=[];

  void clear(){
    points.clear();
    dtimeList.clear();
    pointsFixed.clear();
    dtimeListFixed.clear();
  }
}
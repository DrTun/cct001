import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import 'geo_data.dart';
import '../sqflite/trip_model.dart';

Widget mapWidgetGoogle({
  required EdgeInsets padding,
  required TripModel trip,
  required double imageWidth,
  required double imageHeight,
  required bool showMarker,
  required int setMargin,
  required int lineThickness,
}) {


  LatLngBounds bounds = GeoData.getLatLngBounds(trip.route);
  CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 5);
  return SizedBox(
    width: imageWidth,
    height: imageHeight,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
            padding: padding,
            onMapCreated: (GoogleMapController controller) {
             controller.animateCamera(cameraUpdate);
            },
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            scrollGesturesEnabled: false,
            mapToolbarEnabled: false,
            rotateGesturesEnabled: false,
            compassEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(trip.route.last.latitude, trip.route.last.longitude),
              zoom: 16,
            ),
            markers: Set<Marker>.from(addMarkers(trip,showMarker)),
            polylines: Set<Polyline>.from(addPolylines(trip,lineThickness)),
            mapType: MapType.normal,              
          ),
    ),
  );

}

List<Polyline> addPolylines(TripModel trip,int lineThickness) {
    List<Polyline> polylines = [];

    Polyline fixed = Polyline(
      polylineId: const PolylineId('fixed'),
      color: Colors.blue,
      points: GeoData.convertLatLngList(trip.route),
      width: lineThickness,
    );

    polylines.add(fixed);
    return polylines;
  }

  List<Marker> addMarkers(TripModel trip,bool show) {
    List<Marker> markers = [];
    if (show) {
      BitmapDescriptor icOrange =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      BitmapDescriptor icBlue =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);    
      Marker start = Marker(
        markerId: const MarkerId('Start'),
        icon: icBlue,
        position: LatLng(trip.route.first.latitude,
            trip.route.first.longitude),
        infoWindow: const InfoWindow(title: 'Start', snippet: 'ongoing trip'),
      );
      markers.add(start);
      Marker end = Marker(
        markerId: const MarkerId('End'),
        icon: icOrange,
        position: LatLng(trip.route.last.latitude,
            trip.route.last.longitude),
        infoWindow: const InfoWindow(title: 'end', snippet: 'ongoing trip'),
      );
      markers.add(end);
    }
    return markers;
  }


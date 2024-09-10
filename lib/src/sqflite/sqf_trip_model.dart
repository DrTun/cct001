import 'dart:convert';

import 'package:latlong2/latlong.dart';

class TripModel {
  String tripId;
  String startTime;
  String endTime;
  List<LatLng> route;
  List<LatLng> originalRoute;
  List<String> dateTimeList;
  List<String> originalDateTimeList;
  String tripStatus;
  String tripDuration;
  String distance;
  String orgDistance;
  String startLocName;
  String endLocName;
  String totalAmount;
  String rate;
  String initial;
  String createdDate;

  TripModel({
    required this.tripId,
    required this.startTime,
    required this.endTime,
    required this.route,
    required this.originalRoute,
    required this.dateTimeList,
    required this.originalDateTimeList,
    required this.tripStatus,
    required this.tripDuration,
    required this.distance,
    required this.orgDistance,
    required this.startLocName,
    required this.endLocName,
    required this.totalAmount,
    required this.rate,
    required this.initial,
    required this.createdDate,
  });

  // Helper method to parse LatLng from JSON
  static List<LatLng> parseLatLngList(String jsonString) {
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => LatLng(item['lat'], item['lng'])).toList();
  }

  // JSON deserialization
  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
        tripId: json['trip_id'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        route: json['route'] != null
            ? TripModel.parseLatLngList(json['route'])
            : [],
        originalRoute: json['original_route'] != null
            ? TripModel.parseLatLngList(json['org'])
            : [],
        dateTimeList: List<String>.from(json['date_time_list'] ?? []),
        originalDateTimeList: List<String>.from(json['org_date_time_list']),
        tripStatus: json['trip_status'],
        tripDuration: json['trip_duration'],
        distance: json['distance'],
        orgDistance: json['org_distance'],
        startLocName: json['start_loc_name'],
        endLocName: json['end_loc_name'],
        totalAmount: json['total_amount'],
        rate: json['rate'],
        initial: json['initial'],
        createdDate: json['created_date'],
      );

  static String latLngListToJson(List<LatLng> latLngList) {
    List<Map<String, dynamic>> jsonList = latLngList
        .map((latLng) => {'lat': latLng.latitude, 'lng': latLng.longitude})
        .toList();
    return jsonEncode(jsonList);
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
        "trip_id": tripId,
        "start_time": startTime,
        "end_time": endTime,
        "route": latLngListToJson(route),
        "original_route": latLngListToJson(originalRoute),
        "date_time_list": jsonEncode(dateTimeList) ,
        "org_date_time_list": jsonEncode(originalDateTimeList),
        "trip_status": tripStatus,
        "trip_duration": tripDuration,
        "distance": distance,
        "org_distance": orgDistance,
        "start_loc_name": startLocName,
        "end_loc_name": endLocName,
        "total_amount": totalAmount,
        "rate":rate,
        "initial":initial,
        "created_date": createdDate,
      };

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      tripId: map['trip_id'] ?? "",
      startTime: map['start_time'],
      endTime: map['end_time'],
      route: map['route'] != null ? TripModel.parseLatLngList(map['route']) : [],
      originalRoute: map['original_route'] != null
          ? TripModel.parseLatLngList(map['original_route'])
          : [],
      dateTimeList: List<String>.from(jsonDecode(map['date_time_list'] ?? '[]')),
      originalDateTimeList:
          List<String>.from(jsonDecode(map['org_date_time_list'] ?? '[]')),
      tripStatus: map['trip_status'],
      tripDuration: map['trip_duration'],
      distance: map['distance'],
      orgDistance: map['org_distance'],
      startLocName: map['start_loc_name'],
      endLocName: map['end_loc_name'],
      totalAmount: map['total_amount'],
      rate: map['rate'],
      initial: map['initial'],
      createdDate: map['created_date'],
    );
  }
}

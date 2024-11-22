import 'dart:convert';

import 'package:latlong2/latlong.dart';

class TripModel {
  String userID;
  String tripID;
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
  String distanceAmount;
  String extrasTotalAmount;
  String totalAmount;
  String rate;
  String initial;
  String createdDate;
  String cloudStatus;
  String domainID;
  String groupID;
  String currency;
  String walletInitial;
  String walletAmount;
  String walletTotal;

  TripModel({
    required this.userID,
    required this.tripID,
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
    required this.distanceAmount,
    required this.extrasTotalAmount,
    required this.totalAmount,
    required this.rate,
    required this.initial,
    required this.createdDate,
    required this.cloudStatus,
    required this.domainID,
    required this.groupID,
    required this.currency,
    required this.walletAmount,
    required this.walletInitial,
    required this.walletTotal,
  });

  // Helper method to parse LatLng from JSON
  static List<LatLng> parseLatLngList(String jsonString) {
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => LatLng(item['lat'], item['lng'])).toList();
  }

  // JSON deserialization
  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
        userID: json['user_id'],
        tripID: json['trip_id'],
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
        distanceAmount: json['distance_amount'],
        extrasTotalAmount: json['extras_total'],
        totalAmount: json['total_amount'],
        rate: json['rate'],
        initial: json['initial'],
        createdDate: json['created_date'],
        cloudStatus: json['cloud_status'],
        domainID: json['domain_id'],
        groupID: json['group_id'],
        currency:json['currency'],
        walletAmount:json['wallet_amount'],
        walletInitial:json['wallet_initial'],
        walletTotal:json['wallet_total'],
      );

  static String latLngListToJson(List<LatLng> latLngList) {
    List<Map<String, dynamic>> jsonList = latLngList
        .map((latLng) => {'lat': latLng.latitude, 'lng': latLng.longitude})
        .toList();
    return jsonEncode(jsonList);
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
        "user_id": userID,
        "trip_id": tripID,
        "start_time": startTime,
        "end_time": endTime,
        "route": latLngListToJson(route),
        "original_route": latLngListToJson(originalRoute),
        "date_time_list": jsonEncode(dateTimeList),
        "org_date_time_list": jsonEncode(originalDateTimeList),
        "trip_status": tripStatus,
        "trip_duration": tripDuration,
        "distance": distance,
        "org_distance": orgDistance,
        "start_loc_name": startLocName,
        "end_loc_name": endLocName,
        'distance_amount': distanceAmount,
        'extras_total': extrasTotalAmount,
        "total_amount": totalAmount,
        "rate": rate,
        "initial": initial,
        "created_date": createdDate,
        'cloud_status': cloudStatus,
        'domain_id': domainID,
        'group_id':groupID,
        'currency':currency,
        'wallet_amount':walletAmount,
        'wallet_initial':walletInitial,
        'wallet_total':walletTotal,
      };

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      userID: map['user_id'] ?? "",
      tripID: map['trip_id'] ?? "",
      startTime: map['start_time'],
      endTime: map['end_time'],
      route:
          map['route'] != null ? TripModel.parseLatLngList(map['route']) : [],
      originalRoute: map['original_route'] != null
          ? TripModel.parseLatLngList(map['original_route'])
          : [],
      dateTimeList:
          List<String>.from(jsonDecode(map['date_time_list'] ?? '[]')),
      originalDateTimeList:
          List<String>.from(jsonDecode(map['org_date_time_list'] ?? '[]')),
      tripStatus: map['trip_status'],
      tripDuration: map['trip_duration'],
      distance: map['distance'],
      orgDistance: map['org_distance'],
      startLocName: map['start_loc_name'],
      endLocName: map['end_loc_name'],
      distanceAmount: map['distance_amount'],
      extrasTotalAmount: map['extras_total'],
      totalAmount: map['total_amount'],
      rate: map['rate'],
      initial: map['initial'],
      createdDate: map['created_date'],
      cloudStatus: map['cloud_status'],
      domainID: map['domain_id'],
      groupID: map['group_id'],
      currency: map['currency'],
      walletAmount: map['wallet_amount'],
      walletInitial: map['wallet_initial'],
      walletTotal: map['wallet_total'],
    );
    
  }

}

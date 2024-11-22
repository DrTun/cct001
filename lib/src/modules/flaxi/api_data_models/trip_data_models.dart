import 'package:latlong2/latlong.dart';
import 'rateby_groups_models.dart';

class TripDataModel {
  final String sysKey;
  final String tripID;
  final String userID;
  final String appID;
  final String uuID;
  final String domainID;
  final String vehicleID;
  final String fromDateTime;
  final String toDateTime;
  final List<LatLng> route;
  final String type;
  final int status;
  final String refNo;
  final List<String> timeData;
  // final String currency;
  TripDetailData tripDetailData;


  TripDataModel({
    required this.sysKey,
    required this.tripID,
    required this.userID,
    required this.appID,
    required this.uuID,
    required this.domainID,
    required this.vehicleID,
    required this.fromDateTime,
    required this.toDateTime,
    required this.route,
    required this.type,
    required this.status,
    required this.refNo,
    required this.timeData,
    // required this.currency,
    required this.tripDetailData,
  });

  static List<Map<String, dynamic>> latLngListFromJson(
      List<LatLng> latLngList) {
    List<Map<String, dynamic>> jsonList = latLngList.map((latLng) {
      return {
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
      };
    }).toList();
    return jsonList;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['syskey'] = sysKey;
    data['tripid'] = tripID;
    data['userid'] = userID;
    data['appid'] = appID;
    data['uuid'] = uuID;
    data['domainid'] = domainID;
    data['vehicleid'] = vehicleID;
    data['f_datetime'] = fromDateTime;
    data['t_datetime'] = toDateTime;
    data['route'] = latLngListFromJson(route);
    data['type'] = type;
    data['status'] = status;
    data['refno'] = refNo;
    data['timedata'] = timeData;
    // data['currency']=currency;
    data['data'] = tripDetailData.toJson();
    return data;
  }
}



class TripDetailData{
  final double initial;
  final double rate;    
  final double distance;
  final String driverid;
  final int waitingtime;
  final double waitingcharge;
  final String symbol;
  final int total;
  final String subtotal;
  final String duration;
  final String startname;
  final String endname;
  final String domainid;
  final String vehicleno;
  final String vehicle;
  final List<Extra> extras;
  final WalletBalance walletBalance;


  TripDetailData({  
    required this.initial,
    required this.rate,    
    required this.distance,
    required this.driverid,
    required this.waitingtime,
    required this.waitingcharge,
    required this.symbol,
    required this.total,
    required this.subtotal,
    required this.duration,
    required this.startname,
    required this.endname,
    required this.domainid,
    required this.vehicleno,
    required this.vehicle,
    required this.extras,
    required this.walletBalance,
  });                 

  factory TripDetailData.fromJson(Map<String, dynamic> json) {  
    return TripDetailData(
      initial: json['initial'],         
      rate: json['rate'],
      distance: json['distance'],
      driverid: json['driverid'],
      waitingtime: json['waitingtime'],
      waitingcharge: json['waitingcharge'],
      symbol: json['symbol'],
      total: json['total'],
      subtotal: json['subtotal'],
      duration: json['duration'],
      startname: json['startname'],
      endname: json['endname'],
      domainid: json['domainid'],
      vehicleno: json['vehicleno'],
      vehicle: json['vehicle'],
      extras: List<Extra>.from(json['extras'].map((x) => Extra.fromJson(x))),
      walletBalance: WalletBalance.fromJson(json['balance']),
    );
  } 

  Map<String, dynamic> toJson() {        
    final Map<String, dynamic> data = <String, dynamic>{};
    data['initial'] = initial;    
    data['rate'] = rate;    
    data['distance'] = distance;
    data['driverid'] = driverid;
    data['waitingtime'] = waitingtime;
    data['waitingcharge'] = waitingcharge;
    data['symbol'] = symbol;
    data['total'] = total;
    data['subtotal'] = subtotal;
    data['duration'] = duration;
    data['startname'] = startname;
    data['endname'] = endname;
    data['domainid'] = domainid;
    data['vehicleno'] = vehicleno;
    data['vehicle'] = vehicle;
    data['extras'] = extras.isNotEmpty? extras.map((v) => v.toJson()).toList():[];
    data['balance'] = walletBalance.toJson();
    return data;
}
}

class WalletBalance {

   final int initial;
   final int amount;
   final int total;

  WalletBalance({ 
    required this.initial,  
    required this.amount,
    required this.total,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {  
    return WalletBalance(
      initial: json['initial'],
      amount: json['amount'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {        
    final Map<String, dynamic> data = <String, dynamic>{};
    data['initial'] = initial;    
    data['amount'] = amount;    
    data['total'] = total;
    return data;
}

}
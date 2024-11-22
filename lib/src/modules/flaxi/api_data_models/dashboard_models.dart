class DashboardReqModel{
  final String driverid;
  final String startdate;
  final String enddate;
  final String domain;
  final String type;

  DashboardReqModel({
    required this.driverid,
    required this.startdate,
    required this.enddate,
    required this.domain,
    required this.type
  });

  Map<String,dynamic> toJson() {
    final Map<String,dynamic>  data = <String, dynamic>{};
    data["driverid"] = driverid;
    data["startdate"]= startdate;
    data["enddate"]  = enddate;
    data["domain"]   =domain;
    data["type"]     =type;
    return data;
  }
}

class DashboardResponse {
  final int status;
  final String message;
  final List<Data>? driverdata;

  DashboardResponse({
    required this.status,
    required this.message,
    required this.driverdata
  });

  factory DashboardResponse.fromJson(Map<String,dynamic> json) {
    return DashboardResponse(
      status    : json["status"], 
      message   : json["message"], 
      driverdata: json["data"] != null
        ? List<Data>.from(json["data"].map((x) => Data.fromJson(x)))
        : null
    );
  }
}

class Data {
  final String tripCount;
  final String distance;
  final String duration;
  final String totalAmount;
  final String driverCount;

  Data({
    required this.tripCount,
    required this.distance,
    required this.duration,
    required this.totalAmount,
    required this.driverCount
  });

  factory Data.fromJson(Map<String , dynamic> json) {
    return Data(
      tripCount  : json["trip_count"]??'0', 
      distance   : json["distancebykm"]??'0', 
      duration   : json["duration"] ?? '0',
      totalAmount: json["total_amount"]?? '0', 
      driverCount: json["driver_count"]?? '0');
  }
}

class DriverDashBoardDetailsReq{
  final String driverid;
  final String startdate;
  final String enddate;
  final String domain;

  DriverDashBoardDetailsReq({
    required this.driverid,
    required this.startdate,
    required this.enddate,
    required this.domain
  });

  Map<String , dynamic> toJson(){
    final Map<String ,dynamic> data = <String , dynamic> {};
    data["driverid"]  = driverid;
    data["startdate"] = startdate;
    data["enddate"]   = enddate;
    data["domain"]    = domain;
    return data;
  }
}

class DriverDashBoardDetailsResponse{
  final int status;
  final String message;
  final List<Detailsdata>? data;

  DriverDashBoardDetailsResponse({
    required this.status,
    required this.message,
    required this.data
  });

  factory DriverDashBoardDetailsResponse.fromJson(Map<String , dynamic> json) {
    return DriverDashBoardDetailsResponse(
      status: json["status"], 
      message: json["message"], 
      data: json["data"]!=null
      ? List<Detailsdata>.from(json["data"].map((x) => Detailsdata.fromJson(x)))
      : null
    );
  }
}

class Detailsdata{
  final String name;
  final String vehicleno;
  final String taxigroup;
  final String tripCount;
  final String distance;
  final String duration;

  Detailsdata({
    required this.name,
    required this.vehicleno,
    required this.taxigroup,
    required this.tripCount,
    required this.distance,
    required this.duration
  });

  factory Detailsdata.fromJson(Map<String , dynamic> json) {
    return Detailsdata(
      name     : json["name"], 
      vehicleno: json["vehicleno"], 
      taxigroup: json["taxigroup"], 
      tripCount: json["trip_count"], 
      distance : json["distancebykm"], 
      duration : json["duration"]
    );
  }
} 
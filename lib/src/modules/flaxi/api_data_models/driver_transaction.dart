class DriverTransactionReq {
  String driverId;
  String startDate;
  String endDate;
  String domain;

  DriverTransactionReq({
    required this.driverId,
    required this.startDate,
    required this.endDate,
    required this.domain
  });

  Map<String,dynamic> toJson() {
    final Map<String,dynamic> data = <String,dynamic> {};
    data["driverid"] = driverId;
    data["startdate"] = startDate;
    data["enddate"]   = endDate;
    data["domain"]    = domain;

    return data;
  }
}

class DriverTransactionResponse{
  int status;
  String message;
  int totalCount;
  List<TransactionData>? dataList;

  DriverTransactionResponse({
    required this.status,
    required this.message,
    required this.totalCount,
    required this.dataList
  });

  factory DriverTransactionResponse.fromJson(Map<String,dynamic> json) {
    return DriverTransactionResponse(
      status: json["status"], 
      message: json["message"], 
      totalCount: json["total_count"], 
      dataList: json["data_list"] != null
        ? List<TransactionData>.from(json["data_list"].map((x) => TransactionData.fromJson(x)))
        : null
    );
  }
}

class TransactionData{
  String startName;
  String endName;
  String tripId;
  String distance;
  String duration;
  String total;
  String reduceAmount;
  String fDatetime;
  String symbol;

  TransactionData({
    required this.startName,
    required this.endName,
    required this.tripId,
    required this.distance,
    required this.duration,
    required this.total,
    required this.reduceAmount,
    required this.fDatetime,
    required this.symbol,
  });

  factory TransactionData.fromJson(Map<String , dynamic> json) {
    return TransactionData(
      startName   : json["startname"], 
      endName     : json["endname"], 
      tripId      : json["tripid"], 
      distance    : json["distance"], 
      duration    : json["duration"], 
      total       : json["total"], 
      reduceAmount: json["reduce_amount"], 
      fDatetime   : json["f_datetime"],
      symbol      : json['symbol']);
      
  }
}

 
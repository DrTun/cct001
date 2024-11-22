class SocketDataModel {
  String action;
  SocketDataBody body;

  SocketDataModel({required this.action, required this.body});

  // From JSON (deserialization)
  factory SocketDataModel.fromJson(Map<String, dynamic> json) {
    return SocketDataModel(
      action: json['action'],
      body: SocketDataBody.fromJson(json['body']),
    );
  }

  // To JSON (serialization)
  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'body': body.toJson(),
    };
  }
}

class SocketDataBody {
  String syskey;
  String tripid;
  String userid;
  String appid;
  String domainid;
  String vehicleid;
  String datetime;
  double latitude;
  double longitude;
  String type;
  int status;
  String uuid;

  SocketDataBody({
    required this.syskey,
    required this.tripid,
    required this.userid,
    required this.appid,
    required this.domainid,
    required this.vehicleid,
    required this.datetime,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.status,
    required this.uuid,
  });

  // From JSON (deserialization)
  factory SocketDataBody.fromJson(Map<String, dynamic> json) {
    return SocketDataBody(
      syskey: json['syskey'],
      tripid: json['tripid'],
      userid: json['userid'],
      appid: json['appid'],
      domainid: json['domainid'],
      vehicleid: json['vehicleid'],
      datetime: json['datetime'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      type: json['type'],
      status: json['status'],
      uuid: json['uuid'],
    );
  }

  // To JSON (serialization)
  Map<String, dynamic> toJson() {
    return {
      'syskey': syskey,
      'tripid': tripid,
      'userid': userid,
      'appid': appid,
      'domainid': domainid,
      'vehicleid': vehicleid,
      'datetime': datetime,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'status': status,
      'uuid': uuid,
    };
  }
}

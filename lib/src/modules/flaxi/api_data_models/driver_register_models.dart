class DriverRegister {
  String syskey;
  String name;
  String email;
  String mobile;
  String vehicleno;
  String vehicle;
  String fbtoken;

  DriverRegister(
      {required this.syskey,
      required this.name,
      required this.email,
      required this.mobile,
      required this.vehicleno,
      required this.vehicle,
      required this.fbtoken});

      factory DriverRegister.fromJson(Map<String, dynamic> json) {
    return DriverRegister(
        syskey: json['syskey'] ?? '',
        name: json['name'] ?? '',
        vehicleno: json['vehicleno'] ?? '',
        vehicle: json['vehicle'] ?? '', email:json['email'], mobile:json['mobile'], fbtoken:json['fbtoken']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["syskey"] = syskey;
    data["name"] = name;
    data["email"] = email;
    data["mobile"] = mobile;
    data["vehicleno"] = vehicleno;
    data["vehicle"] = vehicle;
    data["fbtoken"] = fbtoken;

    return data;
  }
}

class DriverProfile {
  String syskey;
  String name;
  String vehicleno;
  String vehicle;

  DriverProfile({
    required this.syskey,
    required this.name,
    required this.vehicleno,
    required this.vehicle,
  });
  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
        syskey: json['syskey'] ?? '',
        name: json['name'] ?? '',
        vehicleno: json['vehicleno'] ?? '',
        vehicle: json['vehicle'] ?? '');
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["syskey"] = syskey;
    data["name"] = name;
    data["vehicleno"] = vehicleno;
    data["vehicle"] = vehicle;
    return data;
  }
}

class DriverRegisterResponse {
  int status;
  String message;
  DriverData dataD;

  DriverRegisterResponse(
      {required this.status, required this.message, required this.dataD});

  factory DriverRegisterResponse.fromJson(Map<String, dynamic> json) {
    return DriverRegisterResponse(
        status: json["status"],
        message: json["message"],
        dataD: DriverData.fromJson(json["data"]));
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["status"] = status;
    data["message"] = message;
    data["data"] = dataD.toJson();
    return data;
  }
}
class DriverInfoResponse {
  final int status;
  final String message;
  final DriverInfo data;

  DriverInfoResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DriverInfoResponse.fromJson(Map<String, dynamic> json) {
    return DriverInfoResponse(
      status: json['status'],
      message: json['message'],
      data: DriverInfo.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class DriverInfo {
  final String name;
  final String email;
  final String mobile;
  final String vehicleno;
  final String vehicle;
  final String? deviceid;

  DriverInfo({
    required this.name,
    required this.email,
    required this.mobile,
    required this.vehicleno,
    required this.vehicle,
    this.deviceid,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      vehicleno: json['vehicleno'],
      vehicle: json['vehicle'],
      deviceid: json['deviceid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'vehicleno': vehicleno,
      'vehicle': vehicle,
      'deviceid': deviceid,
    };
  }
}

class DriverData {
  String syskey;
  String name;
  String email;
  String mobile;
  String vehicleno;
  String vehicle;
  List<GroupData> groups;

  DriverData(
      {required this.syskey,
      required this.name,
      required this.email,
      required this.mobile,
      required this.vehicleno,
      required this.vehicle,
      required this.groups});

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
        syskey: json["syskey"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        vehicleno: json["vehicleno"],
        vehicle: json["vehicle"],
        groups: List<GroupData>.from(
            json["groups"].map((gdata) => GroupData.fromJson(gdata))));
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["syskey"] = syskey;
    data["name"] = name;
    data["email"] = email;
    data["mobile"] = mobile;
    data["vehicleno"] = vehicleno;
    data["vehicle"] = vehicle;
    data["groups"] = groups.map((v) => v.toJson()).toList();
    return data;
  }
}

class GroupData {
  String syskey;
  String id;
  String name;
  int isadmin;

  GroupData(
      {required this.syskey,
      required this.id,
      required this.name,
      required this.isadmin});

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
        syskey: json["syskey"],
        id: json["id"],
        name: json["name"],
        isadmin: json["isadmin"]);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["syskey"] = syskey;
    data["id"] = id;
    data["name"] = name;
    data["isadmin"] = isadmin;
    return data;
  }
}

class VersionUpdateReq{
  String versionNo;
  int  platform;

  VersionUpdateReq({
    required this.versionNo,
    required this.platform
  });

  Map< String,dynamic> toJson(){
    final Map< String,dynamic> data = <String,dynamic> {};
    data['version_no'] = versionNo;
    data['platform']   = platform;
    return data;
  }
} 

class VersionUpdateResponse{
  int status;
  String message;
  int type;
  String newVersion;

  VersionUpdateResponse ({
    required this.status,
    required this.message,
    required this.type,
    required this.newVersion
  });

  factory VersionUpdateResponse.fromJson(Map< String,dynamic> json) {
    return VersionUpdateResponse(
      status: json['status'], 
      message: json['message'], 
      type: json['type'], 
      newVersion : json['version']??'' );
  }
}
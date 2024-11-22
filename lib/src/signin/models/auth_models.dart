class SignUpRequest {
    String userId;
    String sToken;
    String password;   
    String userName;
    String appId;
    String uuId;
    String dateTime;
    int reqType;

    SignUpRequest({
      required this.userId,
      required this.sToken,
      required this.password,
      required this.userName,
      required this.appId,
      required this.uuId,
      required this.dateTime,
      required this.reqType
    });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["user_id"]   = userId;
    data["s_token"]   = sToken;
    data["password"]  = password;
    data["user_name"] = userName;
    data["app_id"]    = appId;
    data["uuid"]      = uuId;
    data["date_time"] = dateTime;
    data["req_type"]  = reqType ;
    return data;
  }
  
}

class SignInRequest{
    String userId;
    String password;
    String sToken;
    String appId;
    String uuId;
    String dateTime;
    int reqType;

    SignInRequest({
      required this.userId,
      required this.password,
      required this.sToken,
      required this.appId,
      required this.uuId,
      required this.dateTime,
      required this.reqType
    });

     Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["user_id"]   = userId;
    data["password"]  = password;
    data["s_token"]   = sToken;
    data["app_id"]    = appId;
    data["uuid"]      = uuId;
    data["date_time"] = dateTime;
    data["req_type"]  = reqType ;
    return data;
  }

}

class ResetPasswordReq{
  String userId;
  String sToken;
  String appId;
  String uuId;
  String dateTime;
  int reqType;

  ResetPasswordReq({
    required this.userId,
    required this.sToken,
    required this.appId,
    required this.uuId,
    required this.dateTime,
    required this.reqType,
  });

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = <String,dynamic> {};

    data["user_id"]   = userId;
    data["s_token"]   = sToken;
    data["app_id"]    = appId;
    data["uuid"]      = uuId;
    data["date_time"] = dateTime;
    data["req_type"]  = reqType ;
    return data;
  }
}
class OtpSignInReq{
    String userId;
    String sToken;
    String appId;
    String uuId;
    String dateTime;
    int reqType;

    OtpSignInReq({
      required this.userId,
      required this.sToken,
      required this.appId,
      required this.uuId,
      required this.dateTime,
      required this.reqType
    });

    Map<String,dynamic> toJson() {
      final Map<String,dynamic> data = <String,dynamic> {};
      data["user_id"]   = userId;
      data["s_token"]   = sToken;
      data["app_id"]    = appId;
      data["uuid"]      = uuId;
      data["date_time"] = dateTime;
      data["req_type"]  = reqType ;
      return data;
    }
}

class OtpVerifyReq{
  String userId;
  String otp;
  String session;
  String appId;

  OtpVerifyReq({
    required this.userId,
    required this.otp,
    required this.session,
    required this.appId
  });

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = <String,dynamic> {};
    data["user_id"] = userId; 
    data["otp"]  = otp;
    data["session"] =session; 
    data["app_id"] = appId;
    return data;
  }
}

class UserNameReq{
  String userId;
  String userName;

  UserNameReq({
    required this.userId,
    required this.userName
  });

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = <String,dynamic> {};
    data["user_id"]   = userId;
    data["user_name"] = userName;
    return data;
  }
}

class OtpResponse{
  String userId;
  String session;
  int userStatus;

  OtpResponse({
    required this.userId,
    required this.session,
    required this.userStatus
  });
}

class RenewTokenReq{
  String userId;
  String accessToken;
  String refreshToken;

  RenewTokenReq({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = <String,dynamic> { };
    data["user_id"] = userId;
    data["access_token"] = accessToken;
    data["refresh_token"] = refreshToken;
    return data;
  }
}

//  -------------------------------------   Global Data (Property of Nirvasoft.com)
import 'app_config.dart';
 

import '../helpers/helpers.dart';


class GlobalAccess {
  static String _mode="";
  static String _userid="";
  static String _username="";
  static String _accesstoken="";
  static String _refreshtoken=""; 
  static String _driverid="";
  static String? _idtoken;


  static String get mode => _mode;
  static String get userID => _userid;
  static String get userName => _username;
  static String get accessToken => _accesstoken;
  static String get refreshToken => _refreshtoken; 
  static String get driverID => _driverid;
  static String? get idToken => _idtoken;


  static reset() {
    _mode="";
    _userid="";
    _username="";
    _accesstoken="";
    _refreshtoken="";
    _driverid = "";
    _idtoken = null; 
  }   

    static updateUnameToken(String username,) {
    _username=username; 
  }

    static updateAccessToken(String accesstoken) {
      _accesstoken = accesstoken;
    }

  static updateUToken(String userid, String username, String accesstoken, String refreshtoken,{String? idtoken}) {
    _mode="User";
    _userid=userid;
    _username=username; 
    _accesstoken=accesstoken;
    _refreshtoken=refreshtoken;
    _idtoken = idtoken;
  }
  static updateGToken(String guesttoken) {
    _mode="Guest"; 
    _accesstoken=guesttoken; 
  }
  static updateDriverID(String driverid) {
    _driverid = driverid;
  }
  static readSecToken() async {
   MySecure store = MySecure();
   String userid,username,accesstoken,refreshtoken,driverid;
   String? idtoken;
    userid = await store.readSecureData("userid");
    if (AppConfig.shared.log>=3) logger.i('From Secure Data Read: $userid');
    if (userid.isNotEmpty && !userid.startsWith("No data")) {   
      username = await store.readSecureData("username");
      accesstoken = await store.readSecureData("accesstoken");
      refreshtoken = await store.readSecureData("refreshtoken");
      idtoken = await store.readSecureData("idtoken");  
      driverid = await store.readSecureData("driverid");
      updateUToken(userid, username, accesstoken, refreshtoken, idtoken: idtoken);
      updateDriverID(driverid);
    } 
  }
  static updateSecToken() async {
    MySecure store = MySecure();
    store.writeSecureData("userid", _userid);
    store.writeSecureData("username", _username);
    store.writeSecureData("accesstoken", _accesstoken);
    store.writeSecureData("refreshtoken", _refreshtoken);
    store.writeSecureData("driverid", _driverid);
    if (_idtoken != null) {
      store.writeSecureData("idtoken", _idtoken!);
    }
  }
  static resetSecToken() async {
    MySecure store = MySecure();
    store.deleteSecureData("userid");
    store.deleteSecureData("username");
    store.deleteSecureData("accesstoken");
    store.deleteSecureData("refreshtoken");
    store.deleteSecureData("idtoken");
    store.deleteSecureData("driverid");
  }
}
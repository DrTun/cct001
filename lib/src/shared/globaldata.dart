//  -------------------------------------   Global Data (Property of Nirvasoft.com)
import 'appconfig.dart';
 

import '../helpers/helpers.dart';


class GlobalAccess {
  static String _mode="";
  static String _userid="";
  static String _username="";
  static String _accesstoken="";
  static String _refreshtoken=""; 

  static String get mode => _mode;
  static String get userID => _userid;
  static String get userName => _username;
  static String get accessToken => _accesstoken;
  static String get refreshToken => _refreshtoken; 

  static reset() {
    _mode="";
    _userid="";
    _username="";
    _accesstoken="";
    _refreshtoken=""; 
  }   

  static updateUToken(String userid, String username, String accesstoken, String refreshtoken) {
    _mode="User";
    _userid=userid;
    _username=username; 
    _accesstoken=accesstoken;
    _refreshtoken=refreshtoken; 
  }
  static updateGToken(String guesttoken) {
    _mode="Guest"; 
    _accesstoken=guesttoken; 
  }
  static readSecToken() async {
   SecureStorage store = SecureStorage();
   String userid,username,accesstoken,refreshtoken;
    userid = await store.readSecureData("userid");
    if (AppConfig.shared.log>=3) logger.i('From Secure Data Read: $userid');
    if (userid.isNotEmpty && !userid.startsWith("No data")) {   
      username = await store.readSecureData("username");
      accesstoken = await store.readSecureData("accesstoken");
      refreshtoken = await store.readSecureData("refreshtoken");  
      updateUToken(userid, username, accesstoken, refreshtoken);
    } 
  }
  static updateSecToken() async {
    SecureStorage store = SecureStorage();
    store.writeSecureData("userid", _userid);
    store.writeSecureData("username", _username);
    store.writeSecureData("accesstoken", _accesstoken);
    store.writeSecureData("refreshtoken", _refreshtoken);
  }
  static resetSecToken() async {
    SecureStorage store = SecureStorage();
    store.deleteSecureData("userid");
    store.deleteSecureData("username");
    store.deleteSecureData("accesstoken");
    store.deleteSecureData("refreshtoken");
  }
}
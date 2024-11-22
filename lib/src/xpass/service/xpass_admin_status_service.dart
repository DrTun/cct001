import '../api/xpass_api_data.dart';

class XpassAdminStatusService {
  static Future<bool> checkUserStatus() async {
    Map<String, dynamic> response = await XpassApiData().getXpassUserStatus();
    if (response['data'] != null) {
      return response['data'];
    } else {
      return false;
    }
  }
}

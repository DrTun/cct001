import '../api/xpass_api_data.dart';
import '../models/xpass_register_models.dart';

class XpassRegisterService {
  static Future<List<RegisterItem>> fetchRegisters(int page, int size) async {
    Map<String, dynamic> apiRegisterResponse =
        await XpassApiData().getXpassRegister(page, size);
    if (apiRegisterResponse['status'] == 200 ||
        apiRegisterResponse['status'] == 201) {
      return (apiRegisterResponse['data']['content'] as List)
          .map((item) => RegisterItem.fromJson(item))
          .toList();
    } else {
      throw Exception('Connectivity [50x]');
    }
  }

  static Future<Map<String, dynamic>> updateRegister(
      RegisterItem updatedRegisterItem) async {
    Map<String, dynamic> apiUpdateRegisterResponse =
        await XpassApiData().putXpassRegister(updatedRegisterItem);
    if (apiUpdateRegisterResponse['status'] == 200 ||
        apiUpdateRegisterResponse['status'] == 201) {
      return {'status': 200};
    } else {
      throw Exception('Connectivity [50x]');
    }
  }

  static Future<Map<String, dynamic>> createRegister(
      RegisterItem createRegister) async {
    Map<String, dynamic> apiRegisterResponse =
        await XpassApiData().postXpassRegister(createRegister);
    if (apiRegisterResponse['status'] == 200 ||
        apiRegisterResponse['status'] == 201) {
      return {'status': 200};
    } else {
      throw Exception('Connectivity [50x]');
    }
  }
}

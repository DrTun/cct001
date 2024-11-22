import '../api/xpass_api_data.dart';
import '../models/xpass_logs_models.dart';

class XpassLogsService {
  static Future<List<LogsItem>> fetchLogs(int page, int size) async {
    Map<String, dynamic> apiLogsResponse =
        await XpassApiData().getXpassLogs(page, size);
    if (apiLogsResponse['status'] == 200) {
      return (apiLogsResponse['data']['content'] as List)
          .map((item) => LogsItem.fromJson(item))
          .toList();
    } else {
      throw Exception('Connectivity [50x]');
    }
  }
}

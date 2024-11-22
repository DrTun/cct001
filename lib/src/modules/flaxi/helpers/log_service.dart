import 'dart:io'; 
import 'package:path_provider/path_provider.dart'; 
import 'dart:convert'; 

import '../../../helpers/helpers.dart';
import 'log_model.dart'; 



class LogService {
  static String logFileName = 'error_logs.json';

  static Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$logFileName';
  }

  static Future<void> writeLog(LogModel log) async {
    try {
      final path = await _getFilePath(); 
      final file = File(path); 
      final logJson = jsonEncode(log.toJson()); 

      await file.writeAsString("$logJson\n", mode: FileMode.append);
    } catch (e) {
      logger.e("Error writing log to file: $e");
    }
  }

  static Future<List<LogModel>> readLogs() async {
    try {
      final path = await _getFilePath(); 
      final file = File(path);
      bool fileExists = await file.exists(); 

      if (fileExists) {
        final content = await file.readAsString();
        final List<String> logEntries = content.split("\n").where((entry) => entry.isNotEmpty).toList();
        
        List<LogModel> logs = logEntries.map((entry) {
          return LogModel.fromJson(jsonDecode(entry));
        }).toList();

        return logs;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }


}


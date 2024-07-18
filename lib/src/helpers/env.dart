import '../globaldata.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
//  -------------------------------------    Environment (Property of Nirvasoft.com)
final logger = Logger();
class EnvService {
  static Future<int> loadEnv() async {
    try {
      await dotenv.load(fileName: 'config/.env');
      if (GlobalData.log>=3) logger.i('Environment Init successful.');
      return 200;
    } catch (error) {
      if (GlobalData.log>=1) logger.e('Environment Init Error: $error'); 
      return 400;
    }
  }
  static String getEnvVariable(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }
}
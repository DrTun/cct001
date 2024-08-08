import '../shared/appconfig.dart';
 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
//  -------------------------------------    Environment (Property of Nirvasoft.com)
final logger = Logger();
class EnvService {
  static Future<int> loadEnv({String? ext}) async {
    String f= 'config/.env.$ext';
    try {
      await dotenv.load(fileName: f);
      if (AppConfig.shared.log>=3) logger.i('Environment Init successful.');
      return 200;
    } catch (error) {
      if (AppConfig.shared.log>=1) logger.e('Environment Init Error ($f): $error'); 
      return 400;
    }
  }
  static String getEnvVariable(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }
}

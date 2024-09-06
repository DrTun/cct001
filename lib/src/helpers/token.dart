import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '/src/helpers/helpers.dart';
import '/src/shared/appconfig.dart';
import 'package:uuid/uuid.dart';

class Token {
  Future<String> createSToken(DateTime time,String reqType) async {
    String uuid = await getDeviceUUID();
    String appId = AppConfig.shared.appID;
    String idtime = time.toIso8601String();
    String keyType = AppConfig.shared.secretKey;

    String sTokenSignUp = uuid + appId + idtime + reqType + keyType;

    final sToken = utf8.encode(sTokenSignUp);

    String sTokenHash = sha512.convert(sToken).toString();

    logger.i(sTokenHash);

    return sTokenHash;
  }

  Future<String> getDeviceUUID() async {
    final deviceInfo = DeviceInfoPlugin();
    const uuid = Uuid();
    late String uniqueId;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        uniqueId = androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        uniqueId = iosInfo.identifierForVendor??"";
      }
    } catch (e) {
      uniqueId = uuid.v4();
    }

    return uniqueId.toString();
  }
}
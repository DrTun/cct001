import '../../shared/app_config.dart';

enum LogsStatus { Pending, Open, Close, Auto, Error }

class LogsItem {
  String xpassBaseURL = AppConfig.shared.xpassBaseURL;

  final String id;
  final String license;
  final DateTime createdDate;
  final LogsStatus logStatus;
  final String detectPhotoUrl;
  final String licensePhotoUrl;

  LogsItem({
    required this.id,
    required this.license,
    required this.createdDate,
    required this.logStatus,
    required this.detectPhotoUrl,
    required this.licensePhotoUrl,
  });

  static LogsStatus _parseLogStatus(String status) {
    switch (status) {
      case 'pending':
        return LogsStatus.Pending;
      case 'open':
        return LogsStatus.Open;
      case 'close':
        return LogsStatus.Close;
      case 'auto':
        return LogsStatus.Auto;
      default:
        return LogsStatus.Error;
    }
  }

  factory LogsItem.fromJson(Map<String, dynamic> json) {
    return LogsItem(
      id: json['id'] ?? '',
      license: json['license'] ?? '',
      createdDate: DateTime.parse(json['createdDate']),
      logStatus: _parseLogStatus(json['logStatus']),
      detectPhotoUrl: json['detectPhotoUrl'] ?? '',
      licensePhotoUrl: json['licensePhotoUrl'] ?? '',
    );
  }
  String get fullDetectPhotoUrl =>
      '$xpassBaseURL/api/v1/common/photo?photoUrl=$detectPhotoUrl';

  String get fullLicensePhotoUrl =>
      '$xpassBaseURL/api/v1/common/photo?photoUrl=$licensePhotoUrl';
}

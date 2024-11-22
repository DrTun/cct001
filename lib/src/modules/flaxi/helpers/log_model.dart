class LogModel {
  String errorMessage;
  String stackTrace;
  String timestamp;

  LogModel({
    required this.errorMessage,
    required this.stackTrace,
    required this.timestamp
  });

  factory LogModel.fromJson(Map<String,dynamic> json) {
    return LogModel(
      errorMessage: json['error_message'], 
      stackTrace  : json['stacktrace'], 
      timestamp   : json['timestamp']);
  }

  Map<String,dynamic> toJson() {
    
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error_message'] = errorMessage;
    data['stacktrace'] = stackTrace;
    data['timestamp']  = timestamp;
    
    return data;
  }
}
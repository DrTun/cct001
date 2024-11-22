import 'dart:async';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../shared/app_config.dart';

void onConnect(StompFrame frame) {
  Timer.periodic(const Duration(seconds: 10), (_) {
    stompClient.send(
      destination: '/app/heartbeat',
      body: "Heartbeat",
    );
  });
}

final StompClient stompClient = StompClient(
  config: StompConfig(
    url: AppConfig.shared.xpassWebSocketURL,
    onConnect: onConnect,
  ),
);

class WebsocketService {
  static void activate() {
    stompClient.activate();
  }
}

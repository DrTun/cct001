import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../geolocation/geo_data.dart';
import '../geolocation/location_notifier.dart';
import '../helpers/helpers.dart';
import '../providers/network_service_provider.dart';
import '../shared/app_config.dart';

class SocketService {
  static SocketService? _instance;
  WebSocketChannel? _channel;
  static final String _url = AppConfig.shared.webSocketUrl;
  final LocationNotifier providerLocation = LocationNotifier();
  final NetworkServiceProvider networkService = NetworkServiceProvider();

  // Private constructor
  SocketService._();

  // Singleton pattern to ensure only one instance
  factory SocketService() {
    _instance ??= SocketService._();
    return _instance!;
  }

  // Connect to the WebSocket server
  Future<void> connect() async {
    if(!networkService.isOnline.value){
      return;
    }
    try {
      _channel ??= WebSocketChannel.connect(Uri.parse(_url));
      await _channel!.ready;
      logger.i("websocket connected");
      GeoData.isTransmitting = true;
      providerLocation.notify();
      listenToMessages();
    } catch (e) {
      GeoData.isTransmitting = false;
      providerLocation.notify();
      logger.e(e.toString());
    }
  }

  // Check if the WebSocket is connected
  bool get isConnected => _channel != null;

  // Send Location Data

  void sendCurrentLocation(String message) {
    if (isConnected) {
      bool isIdle = checkSocketSts();
      if (isIdle) {
        logger.i("Message idle state");
       // MyHelpers.msg(message:"Message idle state" );
        disconnect();
        connect();
        GeoData.socketLastReceivedTime = DateTime.now();
        providerLocation.notify();

        return;
      }
      if (networkService.isOnline.value) {
        try {
          _channel!.sink.add(message);
          logger.i('Message sent: $message');

          if (!GeoData.isTransmitting) {
            GeoData.isTransmitting = true;
            providerLocation.notify();
          }
        } catch (e) {
          handleWebSocketError(e);
        }
      } else {
        handleNoInternetConnection();
      }
    } else {
      handleWebSocketDisconnected();
    }
  }

// Helper methods for better organization and readability
  void handleWebSocketError(dynamic e) {
    logger.e('WebSocket error: ${e.toString()}');
    MyHelpers.msg(
        message: 'WebSocket error: ${e.toString()}',
        backgroundColor: Colors.red);
    GeoData.isTransmitting = false;
    GeoData.socketMesStatus = 0;
    providerLocation.notify();
    disconnect();
  }

  void handleNoInternetConnection() {
    MyHelpers.msg(
        message: 'Please Check Your Internet Connection',
        backgroundColor: Colors.red);
    GeoData.isTransmitting = false;
    GeoData.socketMesStatus = 0;
    providerLocation.notify();
    disconnect();
  }

  void handleWebSocketDisconnected() {
    logger.e('WebSocket is not connected');
    GeoData.isTransmitting = false;
     GeoData.socketMesStatus = 0;
    providerLocation.notify();
    disconnect();
    connect(); // Attempt to reconnect
  }
    // Stream to listen to incoming messages
  Stream get stream => _channel!.stream;


  void listenToMessages() {
    _channel!.stream.listen(
      (message) {
        // Log incoming message
        logger.i('Incoming message: $message');
        var mes = json.decode(message);
        GeoData.socketMesStatus = mes['status'];
        GeoData.lastSentLocationTime = DateTime.now();
        providerLocation.notify();
        if (mes['status'] != 200) {
          handleWebSocketError(message);
          connect();
        }
      },
      onError: (error) {
        logger.e('WebSocket error: $error');
        handleWebSocketError(error);
      },
      onDone: () {
      //  logger.w('WebSocket connection closed.');
      },
    );
  }



  // Close the WebSocket connection
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}

bool checkSocketSts() {
  DateTime dt = DateTime.now();
  int time = dt.difference(GeoData.socketLastReceivedTime).inMinutes;
  bool isIdle = time > 1 ? true : false;
  return isIdle;
}

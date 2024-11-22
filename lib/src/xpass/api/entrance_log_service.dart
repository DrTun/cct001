import 'dart:convert';
import '../models/xpass_commands_dto_models.dart';
import '../models/xpass_commands_models.dart';
import '../utils/websocket.dart';

class PassingRecordService {
  static Future<Map<String, dynamic>> command(CommandDto commandDto) async {
    Commands commandStr = commandDto.command;
    try {
      stompClient.send(
        destination: '/app/command',
        body: jsonEncode(commandDto),
      );
      return {"status": 200, "message": "Command $commandStr success."};
    } catch (e) {
      return {"status": 500, "message": "Command $commandStr failed."};
    }
  }
}

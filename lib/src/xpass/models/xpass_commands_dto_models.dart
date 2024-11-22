import 'xpass_commands_models.dart';

class CommandDto {
  String ipaddress;
  Commands command;
  String? id;

  CommandDto(
      {required this.ipaddress, required this.command, required this.id});
  factory CommandDto.fromJson(Map<String, dynamic> json) {
    return CommandDto(
      ipaddress: json['ipaddress'],
      command: fromJson(json['command']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ipaddress': ipaddress,
      'command': command.name,
      'id': id,
    };
  }
}

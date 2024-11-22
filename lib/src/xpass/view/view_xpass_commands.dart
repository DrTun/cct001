import 'package:flutter/material.dart';
import '../api/entrance_log_service.dart';
import '../models/xpass_commands_dto_models.dart';
import '../models/xpass_commands_models.dart';
import 'view_xpass_logs_list.dart';

class ViewXpassCommands extends StatefulWidget {
  const ViewXpassCommands({super.key});
  static const routeName = '/viewxpasscommands';

  @override
  State<ViewXpassCommands> createState() => _ViewXpassCommandsState();
}

class _ViewXpassCommandsState extends State<ViewXpassCommands> {
  final Color openIconColor = const Color.fromARGB(255, 8, 83, 10);
  final Color lockIconColor = const Color.fromARGB(255, 172, 82, 29);
  final Color unLockIconColor = const Color.fromARGB(255, 93, 96, 229);

  String tempIpAddress = "192.168.204.161";
  Future<void> open() async {
    CommandDto commandDto =
        CommandDto(ipaddress: tempIpAddress, command: Commands.open, id: null);
    await PassingRecordService.command(commandDto);
    goToList();
  }

  Future<void> close() async {
    CommandDto commandDto =
        CommandDto(ipaddress: tempIpAddress, command: Commands.close, id: null);
    await PassingRecordService.command(commandDto);
    goToList();
  }

  Future<void> lock() async {
    CommandDto commandDto =
        CommandDto(ipaddress: tempIpAddress, command: Commands.lock, id: null);
    await PassingRecordService.command(commandDto);
    goToList();
  }

  Future<void> unlock() async {
    CommandDto commandDto = CommandDto(
        ipaddress: tempIpAddress, command: Commands.unlock, id: null);
    await PassingRecordService.command(commandDto);
    goToList();
  }

  Future<void> goToList() async {
    Navigator.pushNamed(
      context,
      ViewXpassLogsList.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton.icon(
                  onPressed: open,
                  icon: const Icon(Icons.keyboard_option_key_outlined),
                  label: const Text('Open'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: openIconColor,
                    side: BorderSide(color: openIconColor, width: 1),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: lock,
                  icon: const Icon(Icons.lock),
                  label: const Text('Lock'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: lockIconColor,
                    side: BorderSide(color: lockIconColor, width: 1),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: unlock,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Unlock'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: unLockIconColor,
                    side: BorderSide(color: unLockIconColor, width: 1),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

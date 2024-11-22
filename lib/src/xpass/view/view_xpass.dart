import 'package:flutter/material.dart';
import 'view_xpass_commands.dart';
import 'view_xpass_logs_list.dart';
import 'view_xpass_register_list.dart';

class ViewXpass extends StatefulWidget {
  static const routeName = '/viewxpasss';
  const ViewXpass({super.key});

  @override
  State<ViewXpass> createState() => _ViewXpassState();
}

class _ViewXpassState extends State<ViewXpass> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _screens = [
    const ViewXpassLogsList(),
    const ViewXpassRegisterList(),
    const ViewXpassCommands(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Xpass'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Xpass',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Logs'),
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.app_registration),
                title: const Text('Register'),
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_command_key),
                title: const Text('Commands'),
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: _screens[_selectedIndex]);
  }
}

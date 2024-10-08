import 'package:flutter/material.dart';
import '/src/geolocation/geodata.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});
  static const routeName = '/settings';
  final SettingsController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Glue the SettingsController to the theme selection DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        


        child: Column (children: [
        
        DropdownButton<ThemeMode>(
          // Read the selected themeMode from the controller
          value: controller.themeMode,
          // Call the updateThemeMode method any time the user selects a theme.
          onChanged: controller.updateThemeMode,
          items: const [
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Text('System Theme'),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text('Light Theme'),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Text('Dark Theme'),
            )
          ],
        ),
        const SizedBox(height: 20),
        
        DropdownButton<int>(
          // Read the selected themeMode from the controller
          value: GeoData.defaultMap,
          // Call the updateThemeMode method any time the user selects a theme.
          items: const [
            DropdownMenuItem(
              value: 0,
              child: Text('Open Street Map'),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text('Google Map'),
            ),
          ], onChanged: (Object? value) { GeoData.defaultMap = value as int; },
        ),




        
      ],)

      ),
    );
  }
}

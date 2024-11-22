// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/helpers.dart';
import '../providers/localization.dart';
import '../geolocation/geo_data.dart';

import '../providers/mynotifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'language_select.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
  });
  static const routeName = '/settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  // bool showDropdown = false;
  String selectedLanguage = 'en';
  SharedPreferences? _prefs;

  Future<void> _loadSelectedLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = _prefs!.getString('lang') ?? 'en';
    });
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'my':
        return 'Myanmar';
      case 'th':
        return 'Thai';
      case 'zh':
        return 'Chinese';
      default:
        return 'English';
    }
  }

  void _updateLanguage(BuildContext context, String languageCode) async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = languageCode;
    });

    if (languageCode == 'en') {
      Provider.of<LocaleProvider>(context, listen: false)
          .setLocale(const Locale('en'));
    } else if (languageCode == 'my') {
      Provider.of<LocaleProvider>(context, listen: false)
          .setLocale(const Locale('my'));
    } else if (languageCode == 'th') {
      Provider.of<LocaleProvider>(context, listen: false)
          .setLocale(const Locale('th'));
    } else if (languageCode == 'zh') {
      Provider.of<LocaleProvider>(context, listen: false)
          .setLocale(const Locale('zh'));
    }

    _prefs!.setString('lang', languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final MyNotifier provider = Provider.of<MyNotifier>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context);

    void showMapDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Map Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Option 1: Open Street Map
                RadioListTile<int>(
                  title: const Text('Open Street Map'),
                  value: 1,
                  groupValue: GeoData.mapType,
                  onChanged: (int? value) {
                    GeoData.mapType = value!;
                    MyStore.storeMapType();
                    provider.notify(); // Notify listeners
                    Navigator.of(context).pop(); // Close the dialog
                    MyHelpers.msg(
                      message: "Map type set to Open Street Map",
                    );
                  },
                ),
                // Option 2: Google Map
                RadioListTile<int>(
                  title: const Text('Google Map'),
                  value: 2,
                  groupValue: GeoData.mapType,
                  onChanged: (int? value) {
                    GeoData.mapType = value!;
                    MyStore.storeMapType();
                    provider.notify(); // Notify listeners
                    Navigator.of(context).pop(); // Close the dialog
                    MyHelpers.msg(
                      message: "Map type set to Google Map",
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setting),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Replaced ListView with Column for single item
            Column(
              children: [
                ListTile(
                  title: const Text('Map'),
                  leading: const Icon(Icons.map_outlined),
                  onTap: showMapDialog, // Trigger map dialog on tap
                ),
              ],
            ),
            const SizedBox(height: 20),
            // DropdownButton for language selection
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle:
                  Text(_getLanguageName(localeProvider.locale.toString())),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageSelectionScreen(
                      selectedLocale: localeProvider.locale.toString(),
                      onLanguageSelected: (String languageCode) {
                        _updateLanguage(context, languageCode);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

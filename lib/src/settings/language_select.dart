import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String selectedLocale;
  final ValueChanged<String> onLanguageSelected;

  const LanguageSelectionScreen({
    super.key,
    required this.selectedLocale,
    required this.onLanguageSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLocale;

  @override
  void initState() {
    super.initState();
    // Initialize with the selected locale passed from the previous screen
    _selectedLocale = widget.selectedLocale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: Column(
        children: [
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: _selectedLocale,
            onChanged: (String? value) {
              setState(() {
                _selectedLocale = value!;
              });
              widget.onLanguageSelected(value!);
              Navigator.pop(context); // Return to the previous screen
            },
          ),
          RadioListTile<String>(
            title: const Text('Myanmar'),
            value: 'my',
            groupValue: _selectedLocale,
            onChanged: (String? value) {
              setState(() {
                _selectedLocale = value!;
              });
              widget.onLanguageSelected(_selectedLocale);
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: const Text('Thai'),
            value: 'th',
            groupValue: _selectedLocale,
            onChanged: (String? value) {
              setState(() {
                _selectedLocale = value!;
              });
              widget.onLanguageSelected(value!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: const Text('Chinese'),
            value: 'zh',
            groupValue: _selectedLocale,
            onChanged: (String? value) {
              setState(() {
                _selectedLocale = value!;
              });
              widget.onLanguageSelected(value!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

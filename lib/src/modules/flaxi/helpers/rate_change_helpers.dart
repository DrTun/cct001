import 'package:flutter/material.dart';
import '../../../geolocation/geo_data.dart';
import '../../../geolocation/location_notifier.dart';
import '../rates/rate_schemes.dart';

class RateChangeHelper {
  final RateSchemes rateSchemes = RateSchemes();
  static int initial = 0;
  static int _ratePerKm = 0;

  static int increment = 0;
  static String _groupCurrency='MMK';

  static int get ratePerKm=>_ratePerKm;
  static String get groupCurrency=>_groupCurrency;

  void showRateSelectionDialog(BuildContext context) {
    List<Map<String, dynamic>> schemes = rateSchemes.getRateSchemes();
    Map<String, dynamic> selectedRateSchemes =
        rateSchemes.getSelectedRateScheme() ?? {};
    String? selectedRateSchemeId =
        selectedRateSchemes.isNotEmpty ? selectedRateSchemes['id'] : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Choose Rate Scheme'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: schemes.map((scheme) {
                  return RadioListTile<String>(
                    title: Text(
                        '${scheme['description']} (Initial: ${scheme['initialAmount']} MMK, Rate per km: ${scheme['ratePerKm']} MMK)'),
                    value: scheme['id'] as String,
                    groupValue: selectedRateSchemeId,
                    onChanged: (value) {
                      setState(() {
                        selectedRateSchemeId = value;
                        selectedRateSchemes = scheme;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(
                        context); // Close the dialog without selecting a scheme
                  },
                ),
                TextButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    if (selectedRateSchemeId != null) {
                      // Apply the selected rate scheme
                      _applyRateScheme(selectedRateSchemes);
                      Navigator.pop(context); // Close the dialog after applying
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyRateScheme(Map<String, dynamic> selectedRateScheme) {
    rateSchemes.setSelectedRateScheme(selectedRateScheme);
  }

  static void updateRateData(int initial, int ratePerKm, int increment,String groupCurrency,[LocationNotifier? notifier]) {
    RateChangeHelper.initial = initial;
    RateChangeHelper._ratePerKm = ratePerKm;
    RateChangeHelper.increment = increment;
    RateChangeHelper._groupCurrency=groupCurrency;
    GeoData.updateDistanceAmount(notifier);
  }
}

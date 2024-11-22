

import '../../../helpers/helpers.dart';
import '../helpers/rate_change_helpers.dart';

class RateSchemes {
  // Singleton instance
  static final RateSchemes instance = RateSchemes._privateConstructor();

  // Private constructor
  RateSchemes._privateConstructor();

  // Factory constructor to provide the singleton instance
  factory RateSchemes() {
    return instance;
  }

  // List of rate schemes
  final List<Map<String, dynamic>> _rateSchemes = [
    {
      "id": "Scheme1",
      "description": "Scheme 1",
      "initialAmount": 3000,
      "ratePerKm": 800,
      "increment": 100,
    },
    {
      "id": "Scheme2",
      "description": "Scheme 2",
      "initialAmount": 2500,
      "ratePerKm": 1000,
      "increment": 100,
    },
    {
      "id": "Scheme3",
      "description": "Scheme 3",
      "initialAmount": 3000,
      "ratePerKm": 1200,
      "increment": 100,
    }
  ];

  // Default selected scheme ID
  String _selectedSchemeId = "Scheme1"; // Default scheme

  // Method to get all rate schemes
  List<Map<String, dynamic>> getRateSchemes() {
    return List.unmodifiable(_rateSchemes);
  }

  // Method to get a specific rate scheme by ID
  Map<String, dynamic>? getRateSchemeById(String id) {
    return _rateSchemes.firstWhere((scheme) => scheme['id'] == id,
        orElse: () => {});
  }

  // Method to get the currently selected rate scheme
  Map<String, dynamic>? getSelectedRateScheme() {
    return getRateSchemeById(_selectedSchemeId);
  }

  // Method to update the selected rate scheme
  void setSelectedRateScheme(Map<String, dynamic> selectedRateScheme) {
    if (_rateSchemes
        .any((scheme) => scheme["id"] == selectedRateScheme["id"])) {
      _selectedSchemeId = selectedRateScheme["id"];  
      RateChangeHelper.updateRateData(selectedRateScheme["initialAmount"], selectedRateScheme["ratePerKm"], selectedRateScheme["increment"],selectedRateScheme['groupCurrency']);
      MyStore.saveRateScheme(selectedRateScheme);
    }
  }
}


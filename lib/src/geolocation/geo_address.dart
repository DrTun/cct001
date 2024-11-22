import 'package:geocoding/geocoding.dart';

class GeoAddress {
  Future<String> getPlacemarks(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      String address = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        Placemark placemark = findBestPlacemark(placemarks);
        List<String> addressComponents = [];
        filterPlacemark(placemark.street, addressComponents, placemarks);
        filterPlacemark(placemark.subLocality, addressComponents, placemarks);
        filterPlacemark(placemark.locality, addressComponents, placemarks);    
        filterPlacemark(placemark.administrativeArea, addressComponents, placemarks);   
        String address = addressComponents.join(' ,');
        // Clean up extra spaces and trailing commas
        address = address
            .trim()
            .replaceAll(RegExp(r'\s*,\s*'), ' ,')
            .replaceAll(RegExp(r',+$'), '');
        return address;
      }

      return address;
    } catch (e) {
      return "Unknown Location";
    }
  }

  void filterPlacemark(String? placemark, List<String> addressComponents, List<Placemark> placemarks) {
     if (placemark != null && placemark.isNotEmpty && !addressComponents.contains(placemark) && !RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{3,}$').hasMatch(placemark)) {
        addressComponents.add(placemark);   
    }else {
     String? locality = placemarks.map((p) => p.locality).firstWhere(
            (s) =>
                s != null &&
                s.isNotEmpty &&
                !RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{3,}$').hasMatch(s),
            orElse: () => null, // Return null if no valid street is found
          );
      if (locality != null  && locality.isNotEmpty && !addressComponents.contains(locality)) {
        addressComponents.add(locality);
      }
    }    
  }

  Placemark findBestPlacemark(List<Placemark> placemarks) {
    // Scoring function based on the completeness of placemark attributes
    int scorePlacemark(Placemark placemark) {
      int score = 0;

      // Avoid plus codes
      if (placemark.street != null &&
          !RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{3,}$').hasMatch(placemark.street!)) {
        score += 10; // Higher score for valid street names
      }

      if (placemark.thoroughfare != null &&
          placemark.thoroughfare!.isNotEmpty) {
        score += 8; // Add points for thoroughfare
      }

      if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
        score += 6; // Add points for sublocality
      }

      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        score += 5; // Add points for locality
      }

      if (placemark.subAdministrativeArea != null &&
          placemark.subAdministrativeArea!.isNotEmpty) {
        score += 4; // Add points for sub-administrative area
      }

      if (placemark.administrativeArea != null &&
          placemark.administrativeArea!.isNotEmpty) {
        score += 2; // Add points for administrative area
      }

      if (placemark.country != null && placemark.country!.isNotEmpty) {
        score += 1; // Add minimal points for country, as it’s usually too broad
      }

      return score;
    }

    // Sort the placemarks based on their score
    Placemark bestPlacemark = placemarks.reduce((best, current) {
      return scorePlacemark(current) > scorePlacemark(best) ? current : best;
    });

    return bestPlacemark;
  }
}

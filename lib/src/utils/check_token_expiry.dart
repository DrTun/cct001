import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart'; // You need to add this dependency to pubspec.yaml

String checkTokenExpiry(String token) {
  try {
    // Decode the JWT token to extract its payload
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // Extract the expiration time (exp) from the token
    int expiryTimestamp = decodedToken['exp'];

    // Convert the expiry timestamp to a DateTime
    DateTime expiryDate =
        DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);

    // Format the DateTime to remove milliseconds and display only the date and time
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

    return formattedDate; // Return the formatted date

  } catch (e) {
    return e.toString();
  }
}

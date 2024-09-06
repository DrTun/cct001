class ValidationKeys {
  static const String otp = 'OTP';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String userid = 'Userid';
}

String? validateField(String? value, String validateKey) {
  switch (validateKey) {
    case ValidationKeys.otp:
      if (value!.isEmpty) {
        return 'Invalid OTP';
      }
      break;
    case ValidationKeys.username:
      if (value!.isEmpty) {
        return 'Invalid User Name';
      }
      break;
    case ValidationKeys.password:
      if (value!.isEmpty) {
        return 'Invalid Password';
      } else if (value.length < 8) {
        return 'Enter at least 8 characters';
      }
      break;
    case ValidationKeys.userid:
      if (value!.isEmpty ||
          !value.startsWith(RegExp(r'^[a-zA-Z]')) ||
          value.contains(' ') ||
          !value.endsWith('@gmail.com')) {
        return 'Invalid User ID';
      }
      break;
    default:
      return null;
  }
  return null;
}

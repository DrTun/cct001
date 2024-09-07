class ValidationKeys {
  static const String otp = 'OTP';
  static const String confirm = 'confirm';
  static const String unconfirm = 'unconfirm';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String userid = 'Userid';
}

String? validateField(String? value, String validateKey) {
  final emailRegex = RegExp( r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+', caseSensitive: false, 
 );

  switch (validateKey) {
    case ValidationKeys.otp:
      if (value!.isEmpty) {
        return 'Invalid OTP';
      }
      break;
    case ValidationKeys.confirm:
      if (value!.isEmpty) {
        return 'Invalid Password';
      }
      break;
    case ValidationKeys.unconfirm:
        return 'Invalid Password';  
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
          !emailRegex.hasMatch(value)
          ) {
        return 'Invalid User ID';
      }
      break;
    default:
      return null;
  } 
  return null;
}

class ValidationKeys {
  static const String vehicleNO = 'vehicleNO';
  static const String vehicleName = 'vehicleName';
  static const String useridmobile = 'Useridmobile';
  static const String confirm = 'confirm';
  static const String unconfirm = 'unconfirm';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String userid = 'Userid';
  static const String signinuserid = 'singinUserid';
  static const String signinpw     = 'singinpw';
  static const String signupfirstname = 'signupfirstname';
  static const String signuplastname = 'signuplastname';
}

String? validateField(String? value, String validateKey) {
  final emailRegex = RegExp( r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+', caseSensitive: false,); 
  final RegExp phoneRegExp = RegExp(r'^(?:\+?959|09)\d{7,9}$');
  String? nvalue = value?.trim();

  switch (validateKey) {
    case  ValidationKeys.vehicleNO:
      if(nvalue!.isEmpty) {return 'Empty Vehicle Name';}
      break; 
    case  ValidationKeys.vehicleName:
      if(nvalue!.isEmpty) {return 'Empty Vehicle NO.';}
      break;
    case ValidationKeys.signinuserid:
      if(nvalue!.isEmpty) {return 'Invalid User ID';}
      break;
    case ValidationKeys.signinpw:
      if(value!.isEmpty ) {return 'Invalid Password';}
      break;
    case ValidationKeys.confirm:
      if (value!.isEmpty) { return 'Invalid Password';}
      break;
    case ValidationKeys.unconfirm:
        return 'Invalid Password';
    case ValidationKeys.username:
      if (nvalue!.isEmpty) { return 'Invalid User Name';} 
      break;
    case ValidationKeys.password:
      if (value!.isEmpty) { return 'Invalid Password';} 
      else if (value.length < 8) {  return 'Enter at least 8 characters';} 
      break;
    case ValidationKeys.userid:
    
      if (nvalue!.isEmpty || !nvalue.startsWith(RegExp(r'^[a-zA-Z]')) ||  !emailRegex.hasMatch(nvalue)) {
        return 'Invalid User ID';
      }
      break;
    case ValidationKeys.useridmobile:
      if(nvalue!.isEmpty){
        return 'Invalid User ID';
      } 
      if(nvalue.startsWith(RegExp(r'^[a-zA-Z]'))){
        if(!emailRegex.hasMatch(nvalue)){
          return 'Invalid User ID';
        }
      } else if(!phoneRegExp.hasMatch(nvalue)){
          return 'Invalid User ID';
      }
      break;
    case ValidationKeys.signupfirstname:
      if(value!.isEmpty ) {return 'Please enter your first name.';}
      break;
    case ValidationKeys.signuplastname:
      if(value!.isEmpty ) {return 'Please enter your last name.';}
      break;
    default:
      return null;
  } 
  return null;
}

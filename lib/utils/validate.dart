class Validate {
  // RegEx pattern for validating email addresses.
  static String emailPattern =
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$";
  static RegExp emailRegEx = RegExp(emailPattern);

  // Validates an email address.
  static bool isEmail(String value) {
    if (emailRegEx.hasMatch(value.trim())) {
      return true;
    }

    return false;
  }

  /*
   * Returns an error message if email does not validate.
   */
  static String? validateEmail(String value) {
    String email = value.trim();

    if (email.isEmpty) {
      return 'Email is required.';
    }

    if (!isEmail(email)) {
      return 'Invalid email format.';
    }

    return null;
  }

  /*
   * Returns an error message if password does not validate.
   */
  static String? validateLoginPassword(String value) {
    String password = value.trim();

    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    return null;
  }

  /*
   * Returns an error message if password does not validate.
   */
  static String? validatePassword(String value) {
    String password = value.trim();

    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    if (!password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must have at least 1 special character.';
    }

    if (!password.contains(new RegExp(r'[A-Z]'))) {
      return 'Password must have at least 1 uppercase letter.';
    }

    if (!password.contains(new RegExp(r'[a-z]'))) {
      return 'Password must have at least 1 lowercase letter.';
    }

    if (!password.contains(new RegExp(r'[0-9]'))) {
      return 'Password must have at least 1 digit number.';
    }

    return null;
  }

  /*
   * Returns an error message if required field is empty.
   */
  static String? requiredField(String value, String message) {
    if (value.trim().isEmpty) {
      return message;
    }

    return null;
  }
}

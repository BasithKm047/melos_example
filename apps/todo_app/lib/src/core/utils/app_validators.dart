abstract final class AppValidators {
  static final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
  static final _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  static String? requiredText(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredText(value, field: 'Email');
    if (required != null) {
      return required;
    }
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    final required = requiredText(value, field: 'Phone number');
    if (required != null) {
      return required;
    }
    if (!_phoneRegex.hasMatch(value!.trim())) {
      return 'Use 10-15 digits, optional + prefix';
    }
    return null;
  }

  static String? password(String? value) {
    final required = requiredText(value, field: 'Password');
    if (required != null) {
      return required;
    }
    final text = value!.trim();
    if (text.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(text) || !RegExp(r'[0-9]').hasMatch(text)) {
      return 'Include at least one uppercase letter and one number';
    }
    return null;
  }

  static String? name(String? value) {
    final required = requiredText(value, field: 'Name');
    if (required != null) {
      return required;
    }
    final text = value!.trim();
    if (text.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(text)) {
      return 'Name can include letters, spaces, apostrophe, and hyphen';
    }
    return null;
  }
}

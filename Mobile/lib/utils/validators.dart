class Validators {
  static String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? fullName(String? v) {
    final r = required(v, 'Full name');
    if (r != null) return r;
    return RegExp(r"^\p{L}[\p{L} .'\-]{1,98}$", unicode: true).hasMatch(v!.trim())
        ? null
        : 'Enter a valid full name (letters only)';
  }

  static String? email(String? v) {
    final r = required(v, 'Email address');
    if (r != null) return r;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(v!.trim()) ? null : 'Enter a valid email address';
  }

  static String? phone(String? v) {
    final r = required(v, 'Phone number');
    if (r != null) return r;
    final t = v!.trim();
    final digits = t.replaceAll(RegExp(r'\D'), '');
    final ok = RegExp(r'^\+?[0-9][0-9\s\-]{6,18}$').hasMatch(t) && digits.length >= 7 && digits.length <= 15;
    return ok ? null : 'Enter a valid phone number (7-15 digits)';
  }

  static String? username(String? v) {
    final r = required(v, 'Username');
    if (r != null) return r;
    return RegExp(r'^[A-Za-z0-9_]{4,20}$').hasMatch(v!.trim())
        ? null
        : '4-20 characters: letters, numbers, underscores';
  }

  static String? identifier(String? v) {
    final r = required(v, 'Email or username');
    if (r != null) return r;
    return v!.trim().length < 3 ? 'Enter at least 3 characters' : null;
  }

  static String? loginPassword(String? v) => (v == null || v.isEmpty) ? 'Password is required' : null;

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    if (v.length > 72) return 'Password is too long (72 max)';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Add a lowercase letter';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Add an uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add a number';
    return null;
  }

  static String? confirm(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    return v == original ? null : 'Passwords do not match';
  }

  static String? code(String? v) {
    final r = required(v, 'Reset code');
    if (r != null) return r;
    return v!.trim().length < 6 ? 'Enter the full reset code' : null;
  }
}

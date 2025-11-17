class UsernameValidator {
  // Regex: only letters, numbers, underscores
  static final RegExp _allowedChars = RegExp(r'^[a-zA-Z0-9_]+$');

  // List of reserved/profane words
  static final List<String> _bannedWords = [
    'admin', 'moderator', 'root', 'system', 'null', 'void',
    'fuck', 'shit', 'bitch', 'ass', 'cunt', 'damn', // add more as needed
  ];

  /// Validate username step by step, returning the first error found
  static String? validate(String username) {
    username = username.trim();
    final lower = username.toLowerCase();

    final validators = [
      _checkEmpty,
      _checkLength,
      _checkStartEndLetter,
      _checkAllowedChars,
      _checkBannedWords,
      _checkRepetitivePattern,
      _checkAsciiOnly,
    ];

    for (final validator in validators) {
      final error = validator(username);
      if (error != null) return error;
    }

    return null; // valid
  }

  // --- Individual Checks ---

  static String? _checkEmpty(String username) {
    return username.isEmpty ? "Username cannot be empty" : null;
  }

  static String? _checkLength(String username) {
    if (username.length < 6) return "Username must be at least 6 characters";
    if (username.length > 20) return "Username cannot exceed 20 characters";
    return null;
  }

  static String? _checkStartEndLetter(String username) {
    if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
      return "Username must start with a letter";
    }
    return null;
  }

  static String? _checkAllowedChars(String username) {
    if (!_allowedChars.hasMatch(username)) {
      return "Username can contain only letters, numbers, or underscores";
    }
    if (username.contains('.') || username.contains(' ')) {
      return "Username cannot contain dots or spaces";
    }
    return null;
  }

  static String? _checkBannedWords(String username) {
    for (final word in _bannedWords) {
      if (username.toLowerCase().contains(word.toLowerCase())) {
        return "Username contains forbidden words";
      }
    }
    return null;
  }

  static String? _checkRepetitivePattern(String username) {
    // same char repeated 3+ times consecutively
    if (RegExp(r'(.)\1\1').hasMatch(username)) return "Username cannot contain repetitive characters";

    // repeated sequences like abcabc
    for (int len = 2; len <= username.length ~/ 2; len++) {
      for (int i = 0; i <= username.length - 2 * len; i++) {
        final part1 = username.substring(i, i + len).toLowerCase();
        final part2 = username.substring(i + len, i + 2 * len).toLowerCase();
        if (part1 == part2) return "Username cannot contain repetitive patterns";
      }
    }

    return null;
  }

  static String? _checkAsciiOnly(String username) {
    if (!RegExp(r'^[\x00-\x7F]+$').hasMatch(username)) {
      return "Username cannot contain emojis or non-ASCII characters";
    }
    return null;
  }
}

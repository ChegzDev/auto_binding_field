import 'package:flutter/services.dart';

/// Restricts input to phone-number characters: digits, a single leading `+`,
/// and the separators space, `-`, `.`, `(` and `)`, with at most 15 digits.
/// Formatted numbers such as `+1 (415) 555-2671` can be typed or pasted.
class MobileInputFormatter extends TextInputFormatter {
  static final _allowed = RegExp(r'^\+?[\d\s\-().]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (!_allowed.hasMatch(text)) return oldValue;
    if (text.replaceAll(RegExp(r'\D'), '').length > 15) return oldValue;
    return newValue;
  }
}

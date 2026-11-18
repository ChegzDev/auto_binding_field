/// Regular expressions used by the fields.
class Expression {
  /// A phone number: optional leading `+`, then 7 to 15 digits. Spaces,
  /// dashes, dots and parentheses are allowed between digits
  /// (e.g. `+1 (415) 555-2671`, `+4930123456`, `0612345678`).
  static const String mobile = r'^\+?[\d\s\-().]*$';

  /// A date in `dd-mm-yyyy` format.
  static const String dateDMY = r'^\d{2}-\d{2}-\d{4}$';

  /// An `http` or `https` URL (case-insensitive).
  static const String webUrl =
      r'^(?:[hH][tT][tT][pP][sS]?)://[-a-zA-Z\d.]+(?::\d+)?(?:/[-a-zA-Z\d+&@#/%=~_|!:,.;]*)?(?:\?[-a-zA-Z\d+&@#/%=~_|!:,.;]*)?(?:#[-a-zA-Z\d+&@#/%=~_|!:,.;]*)?$';

  /// An email address with a dotted domain such as `a@my-company.com`.
  static const String email =
      r"^[a-zA-Z\d!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z\d!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z\d](?:[a-zA-Z\d-]{0,61}[a-zA-Z\d])?\.)+[a-zA-Z]{2,}$";
}

/// Whether [value] is a valid email address.
bool isValidEmail(String value) =>
    RegExp(Expression.email).hasMatch(value.trim());

/// Whether [value] is a plausible phone number: an optional leading `+` and
/// 7 to 15 digits (the E.164 maximum), with optional separators.
bool isValidPhone(String value) {
  final v = value.trim();
  if (!RegExp(Expression.mobile).hasMatch(v)) return false;
  if (v.indexOf('+') > 0) return false;
  final digits = v.replaceAll(RegExp(r'\D'), '').length;
  return digits >= 7 && digits <= 15;
}

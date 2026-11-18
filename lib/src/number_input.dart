import 'package:flutter/services.dart';

import '../util/enum.dart';

extension NumberTypeInfo on NumberType {
  /// Whether values of this type may be negative.
  bool get allowsNegative => switch (this) {
        NumberType.onlyPositiveInt || NumberType.onlyPositiveDecimal => false,
        _ => true,
      };

  /// Whether values of this type must be negative.
  bool get onlyNegative => switch (this) {
        NumberType.onlyNegativeInt || NumberType.onlyNegativeDecimal => true,
        _ => false,
      };

  /// Whether values of this type may have decimals.
  bool get allowsDecimal => switch (this) {
        NumberType.decimal ||
        NumberType.onlyPositiveDecimal ||
        NumberType.onlyNegativeDecimal =>
          true,
        _ => false,
      };

  /// A keyboard that offers the characters this type needs.
  TextInputType get keyboardType => TextInputType.numberWithOptions(
        signed: allowsNegative,
        decimal: allowsDecimal,
      );

  /// Matches every valid *partial* input, e.g. `-`, `1.` or an empty string.
  RegExp get partialPattern {
    final sign = onlyNegative ? '-?' : (allowsNegative ? '-?' : '');
    final fraction = allowsDecimal ? r'(\.\d*)?' : '';
    return RegExp('^$sign\\d*$fraction\$');
  }

  /// Parses complete input into an `int` (integer types) or a `double`.
  /// Returns null for empty or incomplete input such as `-` or `.`.
  num? parse(String text) {
    final t = text.trim();
    if (t.isEmpty || t == '-' || t == '.' || t == '-.') return null;
    if (allowsDecimal) {
      final v = double.tryParse(t);
      return v != null && v.isFinite ? v : null;
    }
    return int.tryParse(t) ?? _bigIntToInt(t);
  }

  /// Formats [value] for display. Non-finite values are shown as empty.
  String format(num? value) {
    if (value == null || !value.isFinite) return '';
    if (!allowsDecimal || value is int) {
      if (value is int) return value.toString();
      if (value == value.truncateToDouble() && value.abs() < 9e15) {
        return value.toInt().toString();
      }
    }
    return formatDecimal(value.toDouble());
  }
}

int? _bigIntToInt(String t) {
  final big = BigInt.tryParse(t);
  return big?.isValidInt == true ? big!.toInt() : null;
}

/// Formats a double without exponent notation and without binary rounding
/// noise (e.g. `0.1 + 0.2` is shown as `0.3`).
String formatDecimal(double value) {
  if (value == value.truncateToDouble()) {
    return value.abs() < 9e15
        ? value.toInt().toString()
        : BigInt.from(value).toString();
  }
  final rounded = double.parse(value.toStringAsPrecision(15));
  final s = rounded.toString();
  if (!s.contains('e')) return s;
  // Very small numbers, e.g. 1e-7: write out the digits.
  return rounded.toStringAsFixed(20).replaceFirst(RegExp(r'\.?0+$'), '');
}

/// Accepts an edit only if the whole new text is a valid (partial) number of
/// [type]. Invalid edits are rejected as a whole instead of being truncated.
///
/// A comma typed or pasted as the decimal separator is converted to a dot,
/// grouping separators in pasted text are removed, and for negative-only
/// types a leading `-` is added automatically.
class NumberInputFormatter extends TextInputFormatter {
  NumberInputFormatter(this.type);

  final NumberType type;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    var selection = newValue.selection;

    String replace(String from, String to) {
      // Keep the caret in place when characters are removed or replaced.
      if (from == to) return from;
      final before = selection.isValid
          ? _normalize(
              from.substring(0, selection.extentOffset.clamp(0, from.length)),
            )
          : to;
      selection = TextSelection.collapsed(
        offset: before.length.clamp(0, to.length),
      );
      return to;
    }

    text = replace(text, _normalize(text));
    final pattern = type.partialPattern;
    if (type.onlyNegative && text.isNotEmpty && !text.startsWith('-')) {
      final prefixed = '-$text';
      if (pattern.hasMatch(prefixed)) {
        final offset =
            selection.isValid ? selection.extentOffset + 1 : prefixed.length;
        return TextEditingValue(
          text: prefixed,
          selection: TextSelection.collapsed(
            offset: offset.clamp(0, prefixed.length),
          ),
        );
      }
    }
    if (!pattern.hasMatch(text)) return oldValue;
    return TextEditingValue(text: text, selection: selection);
  }

  String _normalize(String text) {
    var t = text.replaceAll(RegExp(r'[\s  _]'), '');
    if (type.allowsDecimal) {
      final hasDot = t.contains('.');
      final hasComma = t.contains(',');
      if (hasDot && hasComma) {
        // "1,234.5" -> "1234.5", "1.234,5" -> "1234.5"
        t = t.lastIndexOf(',') > t.lastIndexOf('.')
            ? t.replaceAll('.', '').replaceAll(',', '.')
            : t.replaceAll(',', '');
      } else if (hasComma) {
        t = ','.allMatches(t).length == 1
            ? t.replaceAll(',', '.')
            : t.replaceAll(',', '');
      }
    } else {
      t = t.replaceAll(',', '');
    }
    return t;
  }
}

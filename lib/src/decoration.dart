import 'package:material_ui/material_ui.dart';

/// Returns [d] without its label, for fields that show the label outside.
///
/// Every other property is kept. `InputDecoration.copyWith` cannot remove a
/// label, so the decoration is rebuilt field by field.
InputDecoration decorationWithoutLabel(InputDecoration d) {
  return InputDecoration(
    icon: d.icon,
    iconColor: d.iconColor,
    floatingLabelStyle: d.floatingLabelStyle,
    helperText: d.helperText,
    helperStyle: d.helperStyle,
    helperMaxLines: d.helperMaxLines,
    hintText: d.hintText,
    hintStyle: d.hintStyle,
    hintTextDirection: d.hintTextDirection,
    hintMaxLines: d.hintMaxLines,
    hintFadeDuration: d.hintFadeDuration,
    error: d.error,
    errorText: d.errorText,
    errorStyle: d.errorStyle,
    errorMaxLines: d.errorMaxLines,
    floatingLabelBehavior: d.floatingLabelBehavior,
    floatingLabelAlignment: d.floatingLabelAlignment,
    isCollapsed: d.isCollapsed,
    isDense: d.isDense,
    contentPadding: d.contentPadding,
    prefixIcon: d.prefixIcon,
    prefixIconConstraints: d.prefixIconConstraints,
    prefix: d.prefix,
    prefixText: d.prefixText,
    prefixStyle: d.prefixStyle,
    prefixIconColor: d.prefixIconColor,
    suffixIcon: d.suffixIcon,
    suffix: d.suffix,
    suffixText: d.suffixText,
    suffixStyle: d.suffixStyle,
    suffixIconColor: d.suffixIconColor,
    suffixIconConstraints: d.suffixIconConstraints,
    counter: d.counter,
    counterText: d.counterText,
    counterStyle: d.counterStyle,
    filled: d.filled,
    fillColor: d.fillColor,
    focusColor: d.focusColor,
    hoverColor: d.hoverColor,
    errorBorder: d.errorBorder,
    focusedBorder: d.focusedBorder,
    focusedErrorBorder: d.focusedErrorBorder,
    disabledBorder: d.disabledBorder,
    enabledBorder: d.enabledBorder,
    border: d.border,
    enabled: d.enabled,
    semanticCounterText: d.semanticCounterText,
    alignLabelWithHint: d.alignLabelWithHint,
    constraints: d.constraints,
    // material_ui-only:begin (not available in older Flutter versions)
    labelTextDirection: d.labelTextDirection,
    helper: d.helper,
    hint: d.hint,
    maintainHintSize: d.maintainHintSize,
    maintainLabelSize: d.maintainLabelSize,
    visualDensity: d.visualDensity,
    supportingTextPadding: d.supportingTextPadding,
    // material_ui-only:end
  );
}

/// The label of [d] as a widget to show above the field, styled with the
/// theme's and the decoration's `labelStyle`. Returns null without a label.
Widget? outsideLabel(BuildContext context, InputDecoration? d) {
  if (d == null) return null;
  final Widget? label =
      d.label ?? (d.labelText == null ? null : Text(d.labelText!));
  if (label == null) return null;
  final themeStyle = Theme.of(context).inputDecorationTheme.labelStyle;
  final style = themeStyle?.merge(d.labelStyle) ?? d.labelStyle;
  return style == null
      ? label
      : DefaultTextStyle.merge(style: style, child: label);
}

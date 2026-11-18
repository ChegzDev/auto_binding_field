import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../util/enum.dart';
import '../util/input_format.dart';
import '../util/reg_exp.dart';
import 'binding.dart';
import 'decoration.dart';
import 'number_input.dart';

export '../util/enum.dart';

const double _ourSideLabelGap = 8;
const String _defaultMandatoryErrorText = 'This field is required';

/// A text field bound to a `String?` variable.
///
/// Pass your variable as [value] and update it in [onChanged]. When the
/// variable changes elsewhere (for example a "clear" button), the field
/// shows the new value. While the user is typing, changes that only echo
/// earlier input are ignored so no keystrokes are lost, and an active IME
/// composition is never interrupted.
class AutoBindingTextField extends StatefulWidget {
  /// The bound value. Use your variable here.
  final String? value;

  /// Called with the new text on every edit. Update your variable here.
  final void Function(String value)? onChanged;

  /// Same as [TextFormField.onSaved].
  final void Function(String? value)? onSaved;

  /// Same as [TextFormField.onEditingComplete].
  final void Function()? onEditingComplete;

  /// Same as [TextFormField.onFieldSubmitted].
  final void Function(String value)? onFieldSubmitted;

  /// Same as [TextFormField.focusNode]. When null, the field creates and
  /// disposes its own node.
  final FocusNode? focusNode;

  /// Same as [TextFormField.inputFormatters].
  final List<TextInputFormatter>? inputFormatters;

  /// Same as [TextFormField.textInputAction].
  final TextInputAction? textInputAction;

  /// Selects the whole text when the field gains focus, so typing replaces
  /// the current value.
  final bool isPrimarySelect;

  /// Same as [TextFormField.validator]. Runs after the [mandatory] check.
  final String? Function(String? value)? validator;

  /// Same as [TextFormField.maxLines].
  final int maxLines;

  /// Same as [TextFormField.keyboardType].
  final TextInputType? keyboardType;

  /// Same as [TextFormField.autovalidateMode].
  final AutovalidateMode? autoValidateMode;

  /// Hides the text, for passwords.
  final bool isPassword;

  /// Same as [TextFormField.enabled].
  final bool enabled;

  /// Same as [TextFormField.decoration].
  final InputDecoration? decoration;

  /// Shows the decoration's label above the field instead of inside it.
  final bool outSideLabel;

  /// Space between the outside label and the field.
  final double ourSideLabelGap;

  /// When true, an empty value fails validation with [mandatoryErrorText].
  final bool mandatory;

  /// Error shown when a [mandatory] field is empty.
  final String mandatoryErrorText;

  /// Same as [TextFormField.readOnly].
  final bool readOnly;

  /// Same as [TextFormField.autofocus].
  final bool autoFocus;

  /// Creates a text field bound to [value].
  const AutoBindingTextField({
    super.key,
    required this.value,
    this.onChanged,
    this.readOnly = false,
    this.autoFocus = false,
    this.decoration,
    this.isPassword = false,
    this.enabled = true,
    this.mandatory = false,
    this.mandatoryErrorText = _defaultMandatoryErrorText,
    this.outSideLabel = false,
    this.ourSideLabelGap = _ourSideLabelGap,
    this.focusNode,
    this.onEditingComplete,
    this.inputFormatters,
    this.textInputAction,
    this.maxLines = 1,
    this.keyboardType,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.onSaved,
    this.isPrimarySelect = true,
    this.onFieldSubmitted,
    this.validator,
  });

  /// A phone number field: phone keyboard, [MobileInputFormatter] and a
  /// validator that accepts 7 to 15 digits with an optional leading `+`.
  /// An empty value is valid unless [mandatory] is true.
  factory AutoBindingTextField.mobile({
    Key? key,
    String? value,
    void Function(String value)? onChanged,
    bool readOnly = false,
    bool autoFocus = false,
    InputDecoration? decoration,
    bool isPassword = false,
    bool enabled = true,
    bool mandatory = false,
    String mandatoryErrorText = _defaultMandatoryErrorText,
    String invalidErrorText = 'Invalid Mobile Number',
    bool outSideLabel = false,
    double ourSideLabelGap = _ourSideLabelGap,
    FocusNode? focusNode,
    void Function()? onEditingComplete,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    int maxLines = 1,
    TextInputType? keyboardType,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    void Function(String? value)? onSaved,
    bool isPrimarySelect = true,
    void Function(String value)? onFieldSubmitted,
    String? Function(String? value)? validator,
  }) {
    return AutoBindingTextField(
      key: key,
      value: value,
      keyboardType: keyboardType ?? TextInputType.phone,
      inputFormatters: inputFormatters ?? [MobileInputFormatter()],
      decoration: decoration,
      outSideLabel: outSideLabel,
      maxLines: maxLines,
      onSaved: onSaved,
      autoValidateMode: autoValidateMode,
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) return null;
            return isValidPhone(value) ? null : invalidErrorText;
          },
      readOnly: readOnly,
      focusNode: focusNode,
      onChanged: onChanged,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
      autoFocus: autoFocus,
      isPassword: isPassword,
      isPrimarySelect: isPrimarySelect,
      mandatory: mandatory,
      mandatoryErrorText: mandatoryErrorText,
      onEditingComplete: onEditingComplete,
      ourSideLabelGap: ourSideLabelGap,
      textInputAction: textInputAction,
    );
  }

  /// An email field: email keyboard and an email validator. An empty value
  /// is valid unless [mandatory] is true.
  factory AutoBindingTextField.email({
    Key? key,
    String? value,
    void Function(String value)? onChanged,
    bool readOnly = false,
    bool autoFocus = false,
    InputDecoration? decoration,
    bool isPassword = false,
    bool enabled = true,
    bool mandatory = false,
    String mandatoryErrorText = _defaultMandatoryErrorText,
    String invalidErrorText = 'Invalid email id',
    bool outSideLabel = false,
    double ourSideLabelGap = _ourSideLabelGap,
    FocusNode? focusNode,
    void Function()? onEditingComplete,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    int maxLines = 1,
    TextInputType? keyboardType,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    void Function(String? value)? onSaved,
    bool isPrimarySelect = true,
    void Function(String value)? onFieldSubmitted,
    String? Function(String? value)? validator,
  }) {
    return AutoBindingTextField(
      key: key,
      value: value,
      keyboardType: keyboardType ?? TextInputType.emailAddress,
      inputFormatters: inputFormatters,
      decoration: decoration,
      outSideLabel: outSideLabel,
      maxLines: maxLines,
      onSaved: onSaved,
      autoValidateMode: autoValidateMode,
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) return null;
            return isValidEmail(value) ? null : invalidErrorText;
          },
      readOnly: readOnly,
      focusNode: focusNode,
      onChanged: onChanged,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
      autoFocus: autoFocus,
      isPassword: isPassword,
      isPrimarySelect: isPrimarySelect,
      mandatory: mandatory,
      mandatoryErrorText: mandatoryErrorText,
      onEditingComplete: onEditingComplete,
      ourSideLabelGap: ourSideLabelGap,
      textInputAction: textInputAction,
    );
  }

  @override
  State<AutoBindingTextField> createState() => _AutoBindingTextFieldState();
}

class _AutoBindingTextFieldState extends State<AutoBindingTextField>
    with BindingFieldMixin<AutoBindingTextField> {
  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  bool get isPrimarySelect => widget.isPrimarySelect;

  @override
  String textForValue() => widget.value ?? '';

  @override
  bool textMatchesValue(String text) => text == (widget.value ?? '');

  @override
  void initState() {
    super.initState();
    initBinding();
  }

  @override
  void didUpdateWidget(AutoBindingTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateFocusNode(oldWidget.focusNode);
    if (oldWidget.value != widget.value) scheduleSync();
  }

  @override
  void dispose() {
    disposeBinding();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      autofocus: widget.autoFocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      controller: controller,
      focusNode: focusNode,
      validator: (text) {
        if (widget.mandatory && (text == null || text.trim().isEmpty)) {
          return widget.mandatoryErrorText;
        }
        return widget.validator?.call(text);
      },
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      onChanged: (text) {
        recordEmitted(text);
        widget.onChanged?.call(text);
      },
      onSaved: widget.onSaved,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      autovalidateMode: widget.autoValidateMode,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.isPassword,
      decoration: _decoration(widget.decoration, widget.outSideLabel),
    );
    return _withOutsideLabel(
      context,
      field,
      widget.decoration,
      widget.outSideLabel,
      widget.ourSideLabelGap,
    );
  }
}

/// A number field bound to a `num?` variable.
///
/// Only input valid for [type] is accepted, a comma is accepted as decimal
/// separator, and the keyboard matches [type]. [onChanged], [onSaved],
/// [onFieldSubmitted] and [validator] receive an `int` for integer types and
/// a `double` for decimal types (or null when the field is empty).
class AutoBindingNumField extends StatefulWidget {
  /// The bound value. Use your number variable here.
  final num? value;

  /// Called with the parsed number on every edit (null when empty or
  /// incomplete, e.g. just `-`). Update your variable here.
  final void Function(num? value)? onChanged;

  /// Same as [TextFormField.onSaved], with the parsed number.
  final void Function(num? value)? onSaved;

  /// Same as [TextFormField.onEditingComplete].
  final void Function()? onEditingComplete;

  /// Same as [TextFormField.onFieldSubmitted], with the parsed number.
  final void Function(num? value)? onFieldSubmitted;

  /// Same as [TextFormField.focusNode]. When null, the field creates and
  /// disposes its own node.
  final FocusNode? focusNode;

  /// Replaces the default number filter for [type].
  final List<TextInputFormatter>? inputFormatters;

  /// Same as [TextFormField.textInputAction].
  final TextInputAction? textInputAction;

  /// Selects the whole text when the field gains focus, so typing replaces
  /// the current value.
  final bool isPrimarySelect;

  /// Validates the parsed number. Runs after the [mandatory] check.
  final String? Function(num? value)? validator;

  /// Same as [TextFormField.maxLines].
  final int maxLines;

  /// Overrides the keyboard. Defaults to a number keyboard that offers a
  /// minus sign and decimal point when [type] needs them.
  final TextInputType? keyboardType;

  /// Same as [TextFormField.autovalidateMode].
  final AutovalidateMode? autoValidateMode;

  /// Same as [TextFormField.enabled].
  final bool enabled;

  /// Same as [TextFormField.decoration].
  final InputDecoration? decoration;

  /// Shows the decoration's label above the field instead of inside it.
  final bool outSideLabel;

  /// Space between the outside label and the field.
  final double ourSideLabelGap;

  /// When true, an empty value fails validation with [mandatoryErrorText].
  final bool mandatory;

  /// Error shown when a [mandatory] field is empty.
  final String mandatoryErrorText;

  /// Same as [TextFormField.readOnly].
  final bool readOnly;

  /// Same as [TextFormField.autofocus].
  final bool autoFocus;

  /// Hides the input (e.g. for a PIN).
  final bool isPassword;

  /// The kind of number accepted. Defaults to [NumberType.decimal].
  final NumberType type;

  /// Creates a number field bound to [value].
  const AutoBindingNumField({
    super.key,
    required this.value,
    this.onChanged,
    this.readOnly = false,
    this.type = NumberType.decimal,
    this.autoFocus = false,
    this.decoration,
    this.enabled = true,
    this.mandatory = false,
    this.mandatoryErrorText = _defaultMandatoryErrorText,
    this.outSideLabel = false,
    this.focusNode,
    this.onEditingComplete,
    this.inputFormatters,
    this.textInputAction,
    this.maxLines = 1,
    this.keyboardType,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.onSaved,
    this.isPrimarySelect = true,
    this.onFieldSubmitted,
    this.validator,
    this.ourSideLabelGap = _ourSideLabelGap,
    this.isPassword = false,
  });

  /// A decimal number field ([NumberType.decimal] unless [type] is given).
  factory AutoBindingNumField.decimal({
    Key? key,
    num? value,
    void Function(num? value)? onChanged,
    NumberType type = NumberType.decimal,
    bool readOnly = false,
    bool autoFocus = false,
    InputDecoration? decoration,
    bool isPassword = false,
    bool enabled = true,
    bool mandatory = false,
    String mandatoryErrorText = _defaultMandatoryErrorText,
    bool outSideLabel = false,
    double ourSideLabelGap = _ourSideLabelGap,
    FocusNode? focusNode,
    void Function()? onEditingComplete,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    int maxLines = 1,
    TextInputType? keyboardType,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    void Function(num? value)? onSaved,
    bool isPrimarySelect = true,
    void Function(num? value)? onFieldSubmitted,
    String? Function(num? value)? validator,
  }) {
    return AutoBindingNumField(
      key: key,
      type: type,
      value: value,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: decoration,
      outSideLabel: outSideLabel,
      maxLines: maxLines,
      onSaved: onSaved,
      autoValidateMode: autoValidateMode,
      validator: validator,
      readOnly: readOnly,
      focusNode: focusNode,
      onChanged: onChanged,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
      autoFocus: autoFocus,
      isPassword: isPassword,
      isPrimarySelect: isPrimarySelect,
      mandatory: mandatory,
      mandatoryErrorText: mandatoryErrorText,
      onEditingComplete: onEditingComplete,
      ourSideLabelGap: ourSideLabelGap,
      textInputAction: textInputAction,
    );
  }

  /// An integer field ([NumberType.integer] unless [type] is given).
  factory AutoBindingNumField.integer({
    Key? key,
    num? value,
    void Function(num? value)? onChanged,
    bool readOnly = false,
    NumberType type = NumberType.integer,
    bool autoFocus = false,
    InputDecoration? decoration,
    bool isPassword = false,
    bool enabled = true,
    bool mandatory = false,
    String mandatoryErrorText = _defaultMandatoryErrorText,
    bool outSideLabel = false,
    double ourSideLabelGap = _ourSideLabelGap,
    FocusNode? focusNode,
    void Function()? onEditingComplete,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    int maxLines = 1,
    TextInputType? keyboardType,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    void Function(num? value)? onSaved,
    bool isPrimarySelect = true,
    void Function(num? value)? onFieldSubmitted,
    String? Function(num? value)? validator,
  }) {
    return AutoBindingNumField(
      key: key,
      type: type,
      value: value,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: decoration,
      outSideLabel: outSideLabel,
      maxLines: maxLines,
      onSaved: onSaved,
      autoValidateMode: autoValidateMode,
      validator: validator,
      readOnly: readOnly,
      focusNode: focusNode,
      onChanged: onChanged,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
      autoFocus: autoFocus,
      isPassword: isPassword,
      isPrimarySelect: isPrimarySelect,
      mandatory: mandatory,
      mandatoryErrorText: mandatoryErrorText,
      onEditingComplete: onEditingComplete,
      ourSideLabelGap: ourSideLabelGap,
      textInputAction: textInputAction,
    );
  }

  @override
  State<AutoBindingNumField> createState() => _AutoBindingNumFieldState();
}

class _AutoBindingNumFieldState extends State<AutoBindingNumField>
    with BindingFieldMixin<AutoBindingNumField> {
  late NumberInputFormatter _formatter = NumberInputFormatter(widget.type);

  @override
  FocusNode? get widgetFocusNode => widget.focusNode;

  @override
  bool get isPrimarySelect => widget.isPrimarySelect;

  @override
  String textForValue() => widget.type.format(widget.value);

  @override
  bool textMatchesValue(String text) {
    final parsed = widget.type.parse(text);
    final value = widget.value;
    if (value == null || !value.isFinite) return parsed == null;
    return parsed != null && parsed == value;
  }

  @override
  void initState() {
    super.initState();
    initBinding();
  }

  @override
  void didUpdateWidget(AutoBindingNumField oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateFocusNode(oldWidget.focusNode);
    if (oldWidget.type != widget.type) {
      _formatter = NumberInputFormatter(widget.type);
    }
    if (oldWidget.value != widget.value || oldWidget.type != widget.type) {
      scheduleSync();
    }
  }

  @override
  void dispose() {
    disposeBinding();
    super.dispose();
  }

  num? _parse(String? text) => widget.type.parse(text ?? '');

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      autofocus: widget.autoFocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      controller: controller,
      focusNode: focusNode,
      validator: (text) {
        if (widget.mandatory && _parse(text) == null) {
          return widget.mandatoryErrorText;
        }
        return widget.validator?.call(_parse(text));
      },
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted == null
          ? null
          : (text) => widget.onFieldSubmitted!(_parse(text)),
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType ?? widget.type.keyboardType,
      onChanged: (text) {
        recordEmitted(text);
        widget.onChanged?.call(_parse(text));
      },
      onSaved: widget.onSaved == null
          ? null
          : (text) => widget.onSaved!(_parse(text)),
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      autovalidateMode: widget.autoValidateMode,
      inputFormatters: widget.inputFormatters ?? [_formatter],
      obscureText: widget.isPassword,
      decoration: _decoration(widget.decoration, widget.outSideLabel),
    );
    return _withOutsideLabel(
      context,
      field,
      widget.decoration,
      widget.outSideLabel,
      widget.ourSideLabelGap,
    );
  }
}

InputDecoration _decoration(InputDecoration? d, bool outSideLabel) {
  if (d == null) return const InputDecoration();
  return outSideLabel ? decorationWithoutLabel(d) : d;
}

Widget _withOutsideLabel(
  BuildContext context,
  Widget field,
  InputDecoration? decoration,
  bool outSideLabel,
  double gap,
) {
  if (!outSideLabel) return field;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      outsideLabel(context, decoration) ?? const SizedBox(),
      SizedBox(height: gap),
      field,
    ],
  );
}

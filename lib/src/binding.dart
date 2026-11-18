import 'package:flutter/widgets.dart';

/// Shared two-way binding logic for the auto binding fields.
///
/// * The text is updated from the bound value when the value changes
///   (`didUpdateWidget`) and when the field loses focus — never from `build`.
/// * While the field has focus, an update that only repeats text the user
///   typed earlier (a late echo from async state) is ignored so keystrokes
///   are not lost, and updates wait until an IME composition is finished.
/// * Focus listeners are removed on dispose, and only a focus node created
///   by the field itself is disposed.
mixin BindingFieldMixin<W extends StatefulWidget> on State<W> {
  /// The controller of the inner text field.
  final TextEditingController controller = TextEditingController();

  FocusNode? _ownedFocusNode;
  FocusNode? _listenedNode;
  bool _pendingSync = false;
  final List<String> _emittedTexts = [];

  /// The focus node passed to the widget, if any.
  FocusNode? get widgetFocusNode;

  /// Whether to select all text when the field gains focus.
  bool get isPrimarySelect;

  /// The text that represents the current bound value.
  String textForValue();

  /// Whether [text] already represents the current bound value.
  bool textMatchesValue(String text);

  /// The focus node in use.
  FocusNode get focusNode =>
      widgetFocusNode ?? (_ownedFocusNode ??= FocusNode());

  void initBinding() {
    final text = textForValue();
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    controller.addListener(_onControllerChanged);
    _listen(focusNode);
  }

  void updateFocusNode(FocusNode? oldWidgetNode) {
    if (identical(oldWidgetNode, widgetFocusNode)) return;
    _listenedNode?.removeListener(_onFocusChanged);
    _listenedNode = null;
    if (widgetFocusNode != null && _ownedFocusNode != null) {
      _ownedFocusNode!.dispose();
      _ownedFocusNode = null;
    }
    _listen(focusNode);
  }

  void disposeBinding() {
    _listenedNode?.removeListener(_onFocusChanged);
    _listenedNode = null;
    _ownedFocusNode?.dispose();
    controller.removeListener(_onControllerChanged);
    controller.dispose();
  }

  /// Records text the user produced, to recognise late echoes of it.
  void recordEmitted(String text) {
    if (!focusNode.hasFocus) return;
    _emittedTexts.add(text);
    if (_emittedTexts.length > 50) _emittedTexts.removeAt(0);
  }

  /// Schedules [syncFromValue] after the current frame. Use this from
  /// `didUpdateWidget`, where changing the controller would notify listeners
  /// during build.
  void scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) syncFromValue();
    });
  }

  /// Shows the bound value in the field unless it is already shown.
  void syncFromValue() {
    if (textMatchesValue(controller.text)) {
      _pendingSync = false;
      return;
    }
    if (focusNode.hasFocus) {
      if (controller.value.composing.isValid) {
        _pendingSync = true;
        return;
      }
      final newText = textForValue();
      if (_emittedTexts.contains(newText) && newText != controller.text) {
        // A stale echo of earlier input; re-checked when focus is lost.
        _pendingSync = true;
        return;
      }
    }
    _apply(textForValue());
  }

  void _apply(String text) {
    _pendingSync = false;
    final old = controller.value;
    var offset = text.length;
    if (focusNode.hasFocus && old.selection.isValid) {
      offset = (old.selection.extentOffset + text.length - old.text.length)
          .clamp(0, text.length);
    }
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  void _listen(FocusNode node) {
    node.addListener(_onFocusChanged);
    _listenedNode = node;
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (focusNode.hasFocus) {
      if (isPrimarySelect) {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      }
    } else {
      _emittedTexts.clear();
      syncFromValue();
    }
  }

  void _onControllerChanged() {
    if (_pendingSync &&
        !controller.value.composing.isValid &&
        !_emittedTexts.contains(textForValue())) {
      // Defer: modifying the controller inside its own listener is unsafe.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pendingSync) syncFromValue();
      });
    }
  }
}

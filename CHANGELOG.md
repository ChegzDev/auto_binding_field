## 0.2.0

For apps on `material_ui` (Flutter 3.47+). Apps on `package:flutter/material.dart` should use 0.0.8, which has the same fixes.

* Fixed a crash ("TextEditingController was used after being disposed") when a `focusNode` passed to the field is reused after the field is removed. Focus listeners are now removed, and a focus node created by the field is disposed.
* Values changed while the field has focus are no longer lost: the field syncs when the value changes and when it loses focus, instead of on every build.
* `AutoBindingTextField` no longer overwrites the text with late echoes of earlier input, keeps the cursor position, and doesn't interrupt IME composition.
* Number input: invalid edits are rejected as a whole instead of truncating the text; a comma decimal separator and pasted grouped numbers (`1,234.5`) are accepted; negative-only types add `-` automatically.
* **Integer types now report `int`** (previously always `double`), exactly for large values. Decimal types report `double`.
* The number keyboard offers a minus sign for signed types (negative numbers could not be typed on iOS), and the `keyboardType` parameter is honoured.
* `autoFocus` and `isPassword` now work on `AutoBindingNumField`.
* **The number field no longer forces focus to the next field** on "done"; Flutter's default behaviour for `textInputAction` applies.
* Numbers are displayed consistently (`5` instead of `5.0`, `0.3` instead of `0.30000000000000004`, no exponent notation); `Infinity`/`NaN` show as empty.
* `mandatory` works on every field and constructor; `.email`/`.mobile` accept an empty optional value. New `mandatoryErrorText` and `invalidErrorText` parameters.
* Email validation accepts hyphenated domains and rejects malformed addresses; mobile validation accepts international numbers (7–15 digits) and formatted input such as `+1 (415) 555-2671`, which `MobileInputFormatter` now allows too.
* `Expression.webUrl` and `Expression.dateDMY` are anchored and fixed.
* `outSideLabel`: rich-text labels no longer crash; all decoration properties (hint, helper and error widgets, visual density, ...) are kept; `labelStyle` applies to label widgets.
* README: corrected badges and the compatibility guidance (`MaterialUiCompatibilityBridge` does not make this package work in `flutter/material` apps).
* Added package tests and a corrected example (bound price/tax fields, working "Clear form").

## 0.1.0

* **Breaking:** Migrated from the deprecated `package:flutter/material.dart` to [`material_ui`](https://pub.dev/packages/material_ui). Requires Flutter 3.47.0 / Dart 3.13.0.
* Replaced the deprecated `textScaleFactor` with `textScaler` for outside labels.
* Fixed static analysis issues (super parameters, library name).
* README: fixed the `AutoBindingNumField` example. `onChanged` reports a `num`, so use `value?.toInt()` instead of `value as int?`.
* Example app migrated to `material_ui`, with widget tests added.

## 0.0.7

* AutoBindingNumField bug fixed, when value is infinity 

## 0.0.0

* Initial Release

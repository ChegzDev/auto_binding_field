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

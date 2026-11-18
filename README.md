# AutoBindingField

[![pub package](https://img.shields.io/pub/v/auto_binding_field.svg)](https://pub.dev/packages/auto_binding_field) [![GitHub license](https://img.shields.io/github/license/ChegzDev/auto_binding_field)](https://github.com/ChegzDev/auto_binding_field/blob/master/LICENSE)

Flutter text and number fields that are bound to a variable: the field shows your variable, and your variable is updated as the user types. No `TextEditingController` to manage.

- `AutoBindingTextField` for strings, with `.email` and `.mobile` variants.
- `AutoBindingNumField` for numbers, with `.integer` and `.decimal` variants and a `NumberType` (`integer`, `decimal`, `onlyPositiveInt`, `onlyNegativeInt`, `onlyPositiveDecimal`, `onlyNegativeDecimal`).
- Works inside a `Form` (`validator`, `onSaved`, `mandatory`), and can show the label above the field (`outSideLabel: true`).

## Which version to use

| Your app imports | Use | Requires |
|---|---|---|
| `package:material_ui/material_ui.dart` | `auto_binding_field: ^0.2.0` | Flutter 3.47+ |
| `package:flutter/material.dart` | `auto_binding_field: ^0.0.8` | Flutter 3.16+ |

Both versions have the same features and fixes. Since Flutter 3.47, `package:flutter/material.dart` is deprecated in favour of the separate [`material_ui`](https://pub.dev/packages/material_ui) package, and the two libraries use different `InputDecoration`, `Theme` and `Material` types. A widget built on one can't be used in an app built on the other (you get a compile error or "No Material widget found"), and `MaterialUiCompatibilityBridge` does not help in that direction. To move to 0.2.0, migrate your whole app to `material_ui` first:

```sh
dart fix --apply --code=migrate_design_widgets
```

## Usage

```dart
String name = '';
int? age;

AutoBindingTextField(
  value: name,
  mandatory: true,
  onChanged: (value) => setState(() => name = value),
  decoration: const InputDecoration(labelText: 'Name'),
),

AutoBindingNumField(
  value: age,
  type: NumberType.onlyPositiveInt,
  onChanged: (value) => setState(() => age = value as int?),
  decoration: const InputDecoration(labelText: 'Age'),
),
```

### How binding works

- When your variable changes (for example a "Clear" button sets it to `null`), the field shows the new value.
- While the user is typing, a late update that only repeats something they typed earlier (common with debounced or async state) is ignored, so keystrokes are not lost. Other changes, such as upper-casing the text in `onChanged`, are applied and the cursor stays in place.
- Updates wait until an active IME composition (e.g. Chinese, Japanese or Korean input) is finished.
- When the field loses focus, it always shows the current value of your variable.

### Numbers

- `onChanged`, `onSaved`, `onFieldSubmitted` and `validator` receive an `int` for integer types and a `double` for decimal types, or `null` when the field is empty or incomplete (e.g. just `-`).
- Only input valid for the type is accepted; an invalid edit is rejected as a whole. A comma is accepted as decimal separator, pasted numbers such as `1,234.50` are cleaned up, and negative-only types add the `-` automatically.
- The keyboard offers a minus sign and decimal point only when the type needs them. Pass `keyboardType` to override it.
- `Infinity` and `NaN` are shown as an empty field.

### Validation

- `mandatory: true` fails validation for an empty field with `mandatoryErrorText` (default "This field is required"), then runs your `validator`.
- `.email` and `.mobile` accept an empty value unless `mandatory` is true, and take an `invalidErrorText`. Mobile numbers may have a leading `+`, 7 to 15 digits and separators such as `+1 (415) 555-2671`.

## Example

See the [example app](https://github.com/ChegzDev/auto_binding_field/blob/master/example/lib/main.dart), which includes fields bound to each other (price, tax and price with tax).

## Issues and feedback

Please file issues and feedback on the [GitHub issues page](https://github.com/ChegzDev/auto_binding_field/issues).

If you have any suggestions or feedback, please send an email to __chegz.dev@gmail.com__ and we'll be happy to hear from you!

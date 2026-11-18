
# AutoBindingField

[![pub package](https://img.shields.io/pub/v/like_button.svg)](https://pub.dartlang.org/packages/like_button) [![GitHub license](https://img.shields.io/github/license/fluttercandies/like_button)](https://github.com/fluttercandies/like_button/blob/master/LICENSE)

A AutoBindingField package that automatically updates input field state based on bound variable changes, and vice versa.

[Demo](https://github.com/ChegzDev/auto_binding_field/blob/master/example/lib/main.dart)




## Requirements

Version 0.1.0 and later is built on [`material_ui`](https://pub.dev/packages/material_ui), the standalone Material library that replaces `package:flutter/material.dart`, and requires **Flutter 3.47+** / **Dart 3.13+**. On older Flutter versions, use `auto_binding_field: ^0.0.7`.

If your app still imports `package:flutter/material.dart`, migrate it with `dart fix --apply --code=migrate_design_widgets`, or wrap your app with `MaterialUiCompatibilityBridge` (see the [material_ui README](https://pub.dev/packages/material_ui)).

## Usage

Simply import the package and use the `AutoBindingField` widget in your Flutter app. Here is an example:

```dart    
    int? age;
    AutoBindingNumField(
       value: age,
       type: NumberType.onlyPositiveInt,
       onChanged: (value) {
          setState(() {
            age = value?.toInt(); // onChanged always reports a num (double)
          });
       },
       decoration: const InputDecoration(labelText: 'Age'),
    ),
```  

## Example

[click here](https://github.com/ChegzDev/auto_binding_field/blob/master/example/lib/main.dart) for example


## Issues and feedback

Please file issues and feedback using the Github issues page for this repository.

If you have any suggestions or feedback, please send an email to __chegz.dev@gmail.com__ and we'll be happy to hear from you!

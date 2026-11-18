import 'package:auto_binding_field/auto_binding_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('Example app renders binding fields', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    expect(find.byType(AutoBindingTextField), findsWidgets);
    expect(find.byType(AutoBindingNumField), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AutoBindingNumField reports typed value and follows binding', (
    tester,
  ) async {
    int? age;
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return AutoBindingNumField(
                value: age,
                type: NumberType.onlyPositiveInt,
                onChanged: (value) => setState(() => age = value?.toInt()),
                decoration: const InputDecoration(labelText: 'Age'),
              );
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '42');
    await tester.pump();
    expect(age, 42);

    // External changes are applied only while the field is not focused.
    FocusManager.instance.primaryFocus?.unfocus();
    rebuild(() => age = 7);
    await tester.pump();
    await tester.pump();
    expect(find.text('7'), findsOneWidget);
  });
}

import 'package:auto_binding_field/auto_binding_field.dart';
import 'package:auto_binding_field/util/input_format.dart';
import 'package:auto_binding_field/util/reg_exp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Form(child: Column(children: [child])),
  ),
);

TextField innerField(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first);

String fieldText(WidgetTester tester) => innerField(tester).controller!.text;

void main() {
  group('lifecycle', () {
    testWidgets('a reused external FocusNode does not touch a disposed field', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      var show = true;
      late StateSetter setState;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              setState = s;
              return show
                  ? AutoBindingNumField(value: 1, focusNode: node)
                  : TextField(focusNode: node);
            },
          ),
        ),
      );
      setState(() => show = false);
      await tester.pump();
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('swapping the focusNode uses the new node', (tester) async {
      final a = FocusNode(), b = FocusNode();
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      await tester.pumpWidget(
        host(AutoBindingTextField(value: 'x', focusNode: a)),
      );
      await tester.pumpWidget(
        host(AutoBindingTextField(value: 'x', focusNode: b)),
      );
      expect(innerField(tester).focusNode, same(b));
    });
  });

  group('AutoBindingNumField binding', () {
    testWidgets('value changed while focused is shown after blur', (
      tester,
    ) async {
      num? age = 42;
      late StateSetter setState;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              setState = s;
              return AutoBindingNumField(
                value: age,
                onChanged: (v) => s(() => age = v),
              );
            },
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '43');
      setState(() => age = null); // "clear form" while focused
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(fieldText(tester), '');
    });

    testWidgets('value changed while unfocused is shown immediately', (
      tester,
    ) async {
      num? v = 1;
      late StateSetter setState;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              setState = s;
              return AutoBindingNumField(value: v);
            },
          ),
        ),
      );
      setState(() => v = 7);
      await tester.pump();
      expect(fieldText(tester), '7');
    });

    testWidgets('integer types report ints, exactly', (tester) async {
      final values = <num?>[];
      await tester.pumpWidget(
        host(
          AutoBindingNumField(
            value: null,
            type: NumberType.integer,
            onChanged: values.add,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '12345678901234567');
      expect(values.last, 12345678901234567);
      expect(values.last, isA<int>());
    });

    testWidgets('decimal types report doubles; partial input reports null', (
      tester,
    ) async {
      final values = <num?>[];
      await tester.pumpWidget(
        host(AutoBindingNumField(value: null, onChanged: values.add)),
      );
      await tester.enterText(find.byType(TextField), '-');
      expect(values.last, isNull);
      await tester.enterText(find.byType(TextField), '2.5');
      expect(values.last, 2.5);
      expect(values.last, isA<double>());
    });

    testWidgets('typing "1." is not overwritten by the bound value', (
      tester,
    ) async {
      num? v;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) =>
                AutoBindingNumField(value: v, onChanged: (x) => s(() => v = x)),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '1.');
      await tester.pump();
      expect(fieldText(tester), '1.');
      expect(v, 1.0);
    });

    testWidgets('display formatting is consistent and finite', (tester) async {
      Future<String> show(
        num? value, [
        NumberType t = NumberType.decimal,
      ]) async {
        await tester.pumpWidget(
          host(AutoBindingNumField(key: UniqueKey(), value: value, type: t)),
        );
        return fieldText(tester);
      }

      expect(await show(5.0, NumberType.integer), '5');
      expect(await show(5.0), '5');
      expect(await show(0.1 + 0.2), '0.3');
      expect(await show(1e21), '1000000000000000000000');
      expect(await show(double.infinity), '');
      expect(await show(double.nan), '');
      expect(await show(-2.75), '-2.75');
    });
  });

  group('number input', () {
    Future<String> type(
      WidgetTester tester,
      NumberType t,
      String start,
      TextEditingValue edit,
    ) async {
      await tester.pumpWidget(
        host(
          AutoBindingNumField(
            key: UniqueKey(),
            value: t.allowsDecimalForTest
                ? double.tryParse(start)
                : int.tryParse(start),
            type: t,
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      tester.testTextInput.updateEditingValue(edit);
      await tester.pump();
      return fieldText(tester);
    }

    TextEditingValue v(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    testWidgets('an invalid edit is rejected without truncating', (
      tester,
    ) async {
      expect(
        await type(tester, NumberType.integer, '1234', v('12-34')),
        '1234',
      );
    });

    testWidgets('comma decimals and pasted grouping are accepted', (
      tester,
    ) async {
      expect(await type(tester, NumberType.decimal, '', v('3,5')), '3.5');
      expect(
        await type(tester, NumberType.decimal, '', v('1,234.5')),
        '1234.5',
      );
      expect(
        await type(tester, NumberType.decimal, '', v('1.234,5')),
        '1234.5',
      );
      expect(await type(tester, NumberType.integer, '', v('1,234')), '1234');
    });

    testWidgets('negative-only types add the minus sign', (tester) async {
      expect(await type(tester, NumberType.onlyNegativeInt, '', v('5')), '-5');
      expect(
        await type(tester, NumberType.onlyNegativeDecimal, '', v('-1.5')),
        '-1.5',
      );
    });

    testWidgets('positive-only types reject a minus sign', (tester) async {
      expect(await type(tester, NumberType.onlyPositiveInt, '', v('-5')), '');
    });

    testWidgets('keyboard matches the type and keyboardType is honoured', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AutoBindingNumField(
            value: null,
            type: NumberType.onlyNegativeInt,
          ),
        ),
      );
      expect(
        innerField(tester).keyboardType,
        const TextInputType.numberWithOptions(signed: true, decimal: false),
      );
      await tester.pumpWidget(
        host(
          const AutoBindingNumField(
            value: null,
            keyboardType: TextInputType.phone,
          ),
        ),
      );
      expect(innerField(tester).keyboardType, TextInputType.phone);
    });

    testWidgets('autoFocus and isPassword are applied', (tester) async {
      await tester.pumpWidget(
        host(
          AutoBindingNumField.integer(
            value: 1234,
            autoFocus: true,
            isPassword: true,
          ),
        ),
      );
      expect(innerField(tester).autofocus, isTrue);
      expect(innerField(tester).obscureText, isTrue);
    });

    testWidgets('"done" does not jump to the next field', (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: const [
              AutoBindingNumField(
                value: 1,
                textInputAction: TextInputAction.done,
              ),
              TextField(),
            ],
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField).first);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      final second = tester.widget<TextField>(find.byType(TextField).last);
      expect(second.focusNode?.hasFocus ?? false, isFalse);
    });
  });

  group('AutoBindingTextField binding', () {
    testWidgets('a late echo of earlier input does not revert typing', (
      tester,
    ) async {
      String? v = '';
      late StateSetter setState;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              setState = s;
              return AutoBindingTextField(value: v); // parent updates late
            },
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'a');
      await tester.enterText(find.byType(TextField), 'ab');
      setState(() => v = 'a'); // stale async update arrives
      await tester.pump();
      expect(fieldText(tester), 'ab');
      setState(() => v = 'ab');
      await tester.pump();
      expect(fieldText(tester), 'ab');
    });

    testWidgets('a transformed value is applied and keeps the caret', (
      tester,
    ) async {
      String? v = '';
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) => AutoBindingTextField(
              value: v,
              onChanged: (t) => s(() => v = t.toUpperCase()),
            ),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'abc',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pump();
      final value = innerField(tester).controller!.value;
      expect(value.text, 'ABC');
      expect(value.selection.extentOffset, 1);
    });

    testWidgets('updates wait for an IME composition to finish', (
      tester,
    ) async {
      String? v = '';
      late StateSetter setState;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              setState = s;
              return AutoBindingTextField(value: v);
            },
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'ni',
          selection: TextSelection.collapsed(offset: 2),
          composing: TextRange(start: 0, end: 2),
        ),
      );
      await tester.pump();
      setState(() => v = 'external');
      await tester.pump();
      expect(fieldText(tester), 'ni'); // composition untouched
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '你',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(fieldText(tester), 'external');
    });

    testWidgets('a null value does not rewrite the controller on rebuild', (
      tester,
    ) async {
      late StateSetter setState;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              setState = s;
              return const AutoBindingTextField(value: null);
            },
          ),
        ),
      );
      var notifications = 0;
      innerField(tester).controller!.addListener(() => notifications++);
      for (var i = 0; i < 5; i++) {
        setState(() {});
        await tester.pump();
      }
      expect(notifications, 0);
    });
  });

  group('validation', () {
    Future<bool> validate(WidgetTester tester, Widget field) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: key,
              child: Column(children: [field]),
            ),
          ),
        ),
      );
      final ok = key.currentState!.validate();
      await tester.pump();
      return ok;
    }

    testWidgets('optional empty email and mobile fields are valid', (
      tester,
    ) async {
      expect(
        await validate(tester, AutoBindingTextField.email(value: '')),
        isTrue,
      );
      expect(
        await validate(tester, AutoBindingTextField.mobile(value: null)),
        isTrue,
      );
    });

    testWidgets('mandatory works on every field type', (tester) async {
      expect(
        await validate(
          tester,
          const AutoBindingTextField(value: '', mandatory: true),
        ),
        isFalse,
      );
      expect(find.text('This field is required'), findsOneWidget);
      expect(
        await validate(
          tester,
          const AutoBindingNumField(value: null, mandatory: true),
        ),
        isFalse,
      );
      expect(
        await validate(
          tester,
          AutoBindingTextField.email(
            value: '',
            mandatory: true,
            mandatoryErrorText: 'Required',
          ),
        ),
        isFalse,
      );
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('invalid values fail with the custom message', (tester) async {
      expect(
        await validate(
          tester,
          AutoBindingTextField.email(
            value: 'nope',
            invalidErrorText: 'Bad email',
          ),
        ),
        isFalse,
      );
      expect(find.text('Bad email'), findsOneWidget);
    });

    test('email check', () {
      for (final ok in [
        'a@my-company.com',
        'john@sub.example.co.uk',
        'first.last+tag@x.io',
      ]) {
        expect(isValidEmail(ok), isTrue, reason: ok);
      }
      for (final bad in [
        'a,b@x.com',
        'a@b.co!!garbage',
        'a@b.c',
        '.a@x.io',
        'a..b@x.io',
        'a@x.c0m',
        'a@-x.com',
      ]) {
        expect(isValidEmail(bad), isFalse, reason: bad);
      }
    });

    test('phone check', () {
      for (final ok in [
        '+4930123456',
        '1234567',
        '+1 (415) 555-2671',
        '+8801712345678',
        '0612345678',
      ]) {
        expect(isValidPhone(ok), isTrue, reason: ok);
      }
      for (final bad in [
        '123',
        '12+345678',
        '+1234567890123456',
        'abc1234567',
      ]) {
        expect(isValidPhone(bad), isFalse, reason: bad);
      }
    });

    test('MobileInputFormatter accepts formatted numbers', () {
      final f = MobileInputFormatter();
      TextEditingValue fmt(String s) =>
          f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: s));
      expect(fmt('+1 (415) 555-2671').text, '+1 (415) 555-2671');
      expect(fmt('+8801712345678').text, '+8801712345678');
      expect(fmt('12a').text, '');
      expect(fmt('1234567890123456').text, '');
    });

    test('other expressions are anchored', () {
      expect(RegExp(Expression.dateDMY).hasMatch('01-02-2024'), isTrue);
      expect(RegExp(Expression.dateDMY).hasMatch('x01-02-2024y'), isFalse);
      expect(
        RegExp(Expression.webUrl).hasMatch('https://example.com/a?b=c'),
        isTrue,
      );
      expect(RegExp(Expression.webUrl).hasMatch('ftp://example.com'), isFalse);
    });
  });

  group('outside label', () {
    testWidgets('Text.rich labels work and are shown above the field', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AutoBindingTextField(
            value: '',
            outSideLabel: true,
            decoration: InputDecoration(
              label: Text.rich(
                TextSpan(
                  text: 'Name',
                  children: [TextSpan(text: ' *')],
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Name *', findRichText: true), findsOneWidget);
      expect(innerField(tester).decoration!.label, isNull);
    });

    testWidgets('hint, helper and error widgets are kept', (tester) async {
      await tester.pumpWidget(
        host(
          const AutoBindingNumField(
            value: null,
            outSideLabel: true,
            decoration: InputDecoration(
              labelText: 'Price',
              hint: Text('hint-w'),
              helper: Text('helper-w'),
              error: Text('error-w'),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      );
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('helper-w'), findsNothing); // replaced by error
      expect(find.text('error-w'), findsOneWidget);
      final d = innerField(tester).decoration!;
      expect(d.hint, isNotNull);
      expect(d.helper, isNotNull);
      expect(d.visualDensity, VisualDensity.compact);
      expect(d.labelText, isNull);
    });

    testWidgets('labelStyle applies to a Text label', (tester) async {
      await tester.pumpWidget(
        host(
          const AutoBindingTextField(
            value: '',
            outSideLabel: true,
            decoration: InputDecoration(
              label: Text('Styled'),
              labelStyle: TextStyle(color: Color(0xFFFF0000)),
            ),
          ),
        ),
      );
      final style = DefaultTextStyle.of(tester.element(find.text('Styled')))
          .style;
      expect(style.color, const Color(0xFFFF0000));
    });
  });
}

extension on NumberType {
  bool get allowsDecimalForTest => name.toLowerCase().contains('decimal');
}

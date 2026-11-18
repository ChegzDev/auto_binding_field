import 'package:auto_binding_field/auto_binding_field.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoBindingField',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'AutoBindingField'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = '';
  String mobile = '';
  String email = '';
  int? age = 18;
  double? salary;
  double tax = 12;
  double? price;

  /// A derived value: editing it updates [price].
  double? get priceWithTax => price == null ? null : price! * (100 + tax) / 100;
  set priceWithTax(double? value) =>
      price = value == null ? null : value * 100 / (100 + tax);

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              'Personal Info',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AutoBindingTextField(
              value: name,
              mandatory: true,
              onChanged: (value) => setState(() => name = value),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            AutoBindingTextField.mobile(
              value: mobile,
              onChanged: (value) => setState(() => mobile = value),
              decoration: const InputDecoration(labelText: 'Mobile (optional)'),
            ),
            AutoBindingTextField.email(
              value: email,
              onChanged: (value) => setState(() => email = value),
              decoration: const InputDecoration(labelText: 'Email (optional)'),
            ),
            AutoBindingNumField(
              value: age,
              type: NumberType.onlyPositiveInt,
              // Integer types report an int.
              onChanged: (value) => setState(() => age = value as int?),
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            AutoBindingNumField(
              value: salary,
              type: NumberType.onlyPositiveDecimal,
              // Decimal types report a double.
              onChanged: (value) => setState(() => salary = value as double?),
              decoration: const InputDecoration(labelText: 'Salary'),
            ),
            const SizedBox(height: 24),
            Text(
              'Price (fields bound to each other)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AutoBindingNumField(
              value: price,
              type: NumberType.onlyPositiveDecimal,
              outSideLabel: true,
              onChanged: (value) => setState(() => price = value as double?),
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            AutoBindingNumField(
              value: tax,
              type: NumberType.onlyPositiveDecimal,
              outSideLabel: true,
              onChanged: (value) =>
                  setState(() => tax = (value as double?) ?? 0),
              decoration: const InputDecoration(
                labelText: 'Tax',
                suffixText: '%',
              ),
            ),
            AutoBindingNumField(
              value: priceWithTax,
              type: NumberType.onlyPositiveDecimal,
              outSideLabel: true,
              onChanged: (value) =>
                  setState(() => priceWithTax = value as double?),
              decoration: const InputDecoration(labelText: 'Price with tax'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Name: $name, Mobile: $mobile, Email: $email\n'
              'Age: $age, Salary: $salary, Price: $price, Tax: $tax%',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() {
                    name = '';
                    mobile = '';
                    email = '';
                    age = null;
                    salary = null;
                    price = null;
                  }),
                  child: const Text('Clear form'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => formKey.currentState!.validate(),
                  child: const Text('Validate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

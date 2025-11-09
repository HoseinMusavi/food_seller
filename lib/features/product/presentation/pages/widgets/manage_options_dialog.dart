// lib/features/product/presentation/widgets/manage_options_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_seller/features/product/domain/entities/option_group_entity.dart';

// نتیجه‌ای که این دیالوگ برمی‌گرداند
class NewOptionResult {
  final String name;
  final double priceDelta;
  NewOptionResult({required this.name, required this.priceDelta});
}

class ManageOptionsDialog extends StatefulWidget {
  final OptionGroupEntity group;

  const ManageOptionsDialog({super.key, required this.group});

  @override
  State<ManageOptionsDialog> createState() => _ManageOptionsDialogState();
}

class _ManageOptionsDialogState extends State<ManageOptionsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController(text: '0');

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final priceDelta = double.tryParse(_priceController.text) ?? 0.0;
      Navigator.of(context).pop(NewOptionResult(name: name, priceDelta: priceDelta));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('مدیریت گزینه‌های "${widget.group.name}"'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('گزینه‌های فعلی:', style: theme.textTheme.titleSmall),
            if (widget.group.options.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('هنوز گزینه‌ای اضافه نشده است.'),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView(
                  shrinkWrap: true,
                  children: widget.group.options.map((opt) {
                    return ListTile(
                      title: Text(opt.name),
                      trailing: Text('+${opt.priceDelta.toStringAsFixed(0)} ت'),
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
            
            const Divider(height: 24),
            
            Text('افزودن گزینه جدید:', style: theme.textTheme.titleSmall),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'نام گزینه',
                      hintText: 'مثال: متوسط، سس اضافه، پپسی',
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'نام الزامی است' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'افزایش قیمت (تومان)',
                      hintText: 'مثال: 0 یا 5000',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => (v == null || v.isEmpty) ? 'قیمت الزامی است' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('بستن'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('افزودن'),
        ),
      ],
    );
  }
}
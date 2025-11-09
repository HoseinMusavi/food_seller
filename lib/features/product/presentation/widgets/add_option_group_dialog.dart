// lib/features/product/presentation/widgets/add_option_group_dialog.dart
import 'package:flutter/material.dart';

class AddOptionGroupDialog extends StatefulWidget {
  const AddOptionGroupDialog({super.key});

  @override
  State<AddOptionGroupDialog> createState() => _AddOptionGroupDialogState();
}

class _AddOptionGroupDialogState extends State<AddOptionGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ایجاد گروه آپشن جدید'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'نام گروه',
            hintText: 'مثال: سایز، افزودنی، نوشیدنی',
          ),
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'نام الزامی است' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('لغو'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('ایجاد'),
        ),
      ],
    );
  }
}
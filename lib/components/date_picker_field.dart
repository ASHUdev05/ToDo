import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(BuildContext) onTap;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        hintText: 'Enter Completion Date',
        labelText: 'Date Completed',
        constraints: BoxConstraints(
          maxWidth: 200,
        ),
      ),
      controller: controller,
      readOnly: true,
      onTap: () => onTap(context),
    );
  }
}
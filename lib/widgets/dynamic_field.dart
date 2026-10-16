import 'package:flutter/material.dart';

import '../config/field_config.dart';
import '../utils/date_utils.dart';

/// Renders one search field based only on its [FieldConfig].
/// It knows about field types, never about specific fields.
class DynamicField extends StatelessWidget {
  final FieldConfig config;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final VoidCallback onSubmitted;

  const DynamicField({
    super.key,
    required this.config,
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    switch (config.type) {
      case FieldType.text:
        return TextFormField(
          key: ValueKey('field_${config.key}'),
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          textInputAction: textInputAction,
          autocorrect: false,
          onFieldSubmitted: (_) => onSubmitted(),
          decoration: InputDecoration(
            labelText: config.label,
            hintText: config.placeholder,
            border: const OutlineInputBorder(),
          ),
        );
      case FieldType.date:
        return TextFormField(
          key: ValueKey('field_${config.key}'),
          controller: controller,
          focusNode: focusNode,
          readOnly: true,
          showCursor: false,
          onTap: () => _pickDate(context),
          decoration: InputDecoration(
            labelText: config.label,
            hintText: config.placeholder,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    var initialDate = DateTime.tryParse(controller.text) ?? DateTime(1990);
    if (initialDate.isAfter(now)) initialDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: config.label,
    );

    if (picked != null) {
      controller.text = toApiDate(picked);
    }
  }
}

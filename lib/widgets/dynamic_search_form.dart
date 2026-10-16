import 'package:flutter/material.dart';

import '../config/field_config.dart';
import 'dynamic_field.dart';

/// Builds the whole search form from a list of [FieldConfig].
///
/// Adding a new entry to the config list is enough to show a new field here,
/// this widget does not need to change.
class DynamicSearchForm extends StatefulWidget {
  final List<FieldConfig> fields;
  final ValueChanged<Map<String, String>> onSearch;
  final VoidCallback onClear;
  final bool isLoading;

  const DynamicSearchForm({
    super.key,
    required this.fields,
    required this.onSearch,
    required this.onClear,
    this.isLoading = false,
  });

  @override
  State<DynamicSearchForm> createState() => _DynamicSearchFormState();
}

class _DynamicSearchFormState extends State<DynamicSearchForm> {
  List<FieldConfig> _sortedFields = [];
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _createFieldResources();
  }

  @override
  void didUpdateWidget(covariant DynamicSearchForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fields != widget.fields) {
      _disposeFieldResources();
      _createFieldResources();
    }
  }

  @override
  void dispose() {
    _disposeFieldResources();
    super.dispose();
  }

  void _createFieldResources() {
    _sortedFields = sortByRenderOrder(widget.fields);
    for (final field in _sortedFields) {
      _controllers[field.key] = TextEditingController();
      _focusNodes[field.key] = FocusNode();
    }
  }

  void _disposeFieldResources() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();
  }

  Map<String, String> _collectValues() {
    final values = <String, String>{};
    _controllers.forEach((key, controller) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        values[key] = text;
      }
    });
    return values;
  }

  void _submit() {
    if (widget.isLoading) return;
    FocusScope.of(context).unfocus();
    widget.onSearch(_collectValues());
  }

  void _clear() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
    FocusScope.of(context).unfocus();
    widget.onClear();
  }

  void _moveToNextField(int index) {
    final nextIndex = index + 1;
    if (nextIndex < _sortedFields.length) {
      _focusNodes[_sortedFields[nextIndex].key]!.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _sortedFields.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DynamicField(
              config: _sortedFields[i],
              controller: _controllers[_sortedFields[i].key]!,
              focusNode: _focusNodes[_sortedFields[i].key]!,
              textInputAction: i == _sortedFields.length - 1
                  ? TextInputAction.search
                  : TextInputAction.next,
              onSubmitted: i == _sortedFields.length - 1
                  ? _submit
                  : () => _moveToNextField(i),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.isLoading ? null : _clear,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: widget.isLoading ? null : _submit,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum FieldType { text, date }

class FieldConfig {
  final String key;
  final FieldType type;
  final String label;
  final String? placeholder;
  final int renderOrder;

  const FieldConfig({
    required this.key,
    required this.type,
    required this.label,
    this.placeholder,
    required this.renderOrder,
  });
}

/// Returns a new list sorted by [FieldConfig.renderOrder].
/// The original list is not changed.
List<FieldConfig> sortByRenderOrder(List<FieldConfig> fields) {
  final sorted = List<FieldConfig>.of(fields);
  sorted.sort((a, b) => a.renderOrder.compareTo(b.renderOrder));
  return sorted;
}

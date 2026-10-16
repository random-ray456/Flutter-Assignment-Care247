// Small helpers so a missing or wrong-typed value never crashes parsing.

String readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is num || value is bool) return value.toString();
  return '';
}

bool readBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

/// Parses a list of objects and skips every item that is not a JSON object.
List<T> readList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic> item) fromJson,
) {
  final value = json[key];
  if (value is! List) return [];

  final result = <T>[];
  for (final item in value) {
    if (item is Map<String, dynamic>) {
      result.add(fromJson(item));
    }
  }
  return result;
}

import '../models/customer.dart';
import 'customer_api.dart';

class CustomerRepository {
  final CustomerApi _api;

  List<Customer>? _cachedCustomers;
  Future<List<Customer>>? _pendingRequest;

  CustomerRepository(this._api);

  /// Returns customers that match every non-empty value in [criteria].
  ///
  /// Customers are fetched once and kept in memory. Pass [forceRefresh] to
  /// load them again from the API (used by pull-to-refresh and retry).
  Future<List<Customer>> searchCustomers(
    Map<String, String> criteria, {
    bool forceRefresh = false,
  }) async {
    final customers = await _getCustomers(forceRefresh: forceRefresh);
    return filterCustomers(customers, criteria);
  }

  Future<List<Customer>> _getCustomers({required bool forceRefresh}) async {
    if (!forceRefresh && _cachedCustomers != null) {
      return _cachedCustomers!;
    }

    // If a request is already running, reuse it instead of sending another.
    final pending = _pendingRequest ?? _api.fetchCustomers();
    _pendingRequest = pending;
    try {
      final customers = await pending;
      _cachedCustomers = customers;
      return customers;
    } finally {
      _pendingRequest = null;
    }
  }
}

/// Generic filter: the criteria key is the customer JSON property name.
///
/// Text matching is case-insensitive and partial ("jo" matches "John").
/// Dates are stored as yyyy-MM-dd so a full date only matches the same day.
List<Customer> filterCustomers(
  List<Customer> customers,
  Map<String, String> criteria,
) {
  final activeCriteria = <String, String>{};
  criteria.forEach((key, value) {
    final cleanValue = value.trim().toLowerCase();
    if (cleanValue.isNotEmpty) {
      activeCriteria[key] = cleanValue;
    }
  });

  if (activeCriteria.isEmpty) {
    return List.of(customers);
  }

  return customers.where((customer) {
    final json = customer.toJson();
    for (final entry in activeCriteria.entries) {
      final fieldValue = json[entry.key];
      if (fieldValue is! String) return false;
      if (!fieldValue.toLowerCase().contains(entry.value)) return false;
    }
    return true;
  }).toList();
}

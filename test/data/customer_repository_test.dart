import 'package:customer_search/data/customer_repository.dart';
import 'package:customer_search/models/customer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_data.dart';

void main() {
  final customers = sampleCustomersJson.map(Customer.fromJson).toList();

  List<String> namesFor(Map<String, String> criteria) {
    return filterCustomers(customers, criteria).map((c) => c.fullName).toList();
  }

  group('filterCustomers', () {
    test('text match is partial and case-insensitive', () {
      expect(namesFor({'firstName': 'jo'}), ['John Smith']);
      expect(namesFor({'lastName': 'SON'}), ['Sarah Johnson']);
    });

    test('all criteria must match', () {
      expect(namesFor({'firstName': 'john', 'lastName': 'smith'}), [
        'John Smith',
      ]);
      expect(namesFor({'firstName': 'john', 'lastName': 'johnson'}), isEmpty);
    });
  });
}

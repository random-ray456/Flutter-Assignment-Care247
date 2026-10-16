import 'package:customer_search/models/customer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_data.dart';

void main() {
  group('Customer.fromJson', () {
    test('parses a full customer with nested lists', () {
      final customer = Customer.fromJson(sampleCustomersJson.first);

      expect(customer.id, 'cust-001');
      expect(customer.fullName, 'John Smith');
      expect(customer.dateOfBirth, '1985-03-15');
      expect(customer.addresses.single.city, 'San Francisco');
      expect(customer.phones.length, 2);
      expect(customer.primaryPhone?.number, '+1-415-555-0123');
      expect(customer.primaryEmail?.address, 'john.smith@email.com');
    });

    test('handles missing and wrong-typed fields without throwing', () {
      final customer = Customer.fromJson({
        'id': 42,
        'firstName': null,
        'lastName': 'Doe',
        'addresses': 'not a list',
      });

      expect(customer.id, '42');
      expect(customer.fullName, 'Doe');
      expect(customer.addresses, isEmpty);
      expect(customer.phones, isEmpty);
    });
  });
}

import 'dart:convert';

import 'package:customer_search/data/customer_api.dart';
import 'package:customer_search/data/customer_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Two records copied from the supplied db.json, used only by tests.
const List<Map<String, dynamic>> sampleCustomersJson = [
  {
    'id': 'cust-001',
    'firstName': 'John',
    'lastName': 'Smith',
    'dateOfBirth': '1985-03-15',
    'maritalStatus': 'Married',
    'secureId': '123-45-6789',
    'addresses': [
      {
        'id': 'addr-001',
        'type': 'Home',
        'street': '123 Oak Street',
        'city': 'San Francisco',
        'state': 'CA',
        'zipCode': '94102',
      },
    ],
    'phones': [
      {
        'id': 'phone-001',
        'type': 'Mobile',
        'number': '+1-415-555-0123',
        'isPrimary': true,
      },
      {
        'id': 'phone-002',
        'type': 'Work',
        'number': '+1-415-555-0199',
        'isPrimary': false,
      },
    ],
    'emails': [
      {
        'id': 'email-001',
        'type': 'Personal',
        'address': 'john.smith@email.com',
        'isPrimary': true,
      },
    ],
  },
  {
    'id': 'cust-002',
    'firstName': 'Sarah',
    'lastName': 'Johnson',
    'dateOfBirth': '1990-07-22',
    'maritalStatus': 'Single',
    'secureId': '987-65-4321',
    'addresses': [],
    'phones': [
      {
        'id': 'phone-003',
        'type': 'Mobile',
        'number': '+1-310-555-0456',
        'isPrimary': true,
      },
    ],
    'emails': [
      {
        'id': 'email-003',
        'type': 'Personal',
        'address': 'sarah.j@email.com',
        'isPrimary': true,
      },
    ],
  },
];

/// Fake HTTP client that returns [sampleCustomersJson], or a network error.
class FakeServer {
  bool throwNetworkError;

  FakeServer({this.throwNetworkError = false});

  http.Client get client => MockClient((request) async {
    if (throwNetworkError) {
      throw http.ClientException('Connection refused', request.url);
    }
    return http.Response(jsonEncode(sampleCustomersJson), 200);
  });

  CustomerApi get api =>
      CustomerApi(client: client, baseUrl: 'http://test.local');

  CustomerRepository get repository => CustomerRepository(api);
}

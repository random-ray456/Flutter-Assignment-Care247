import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/customer.dart';
import 'api_exception.dart';

/// Only responsible for the HTTP call and turning the response into models.
class CustomerApi {
  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;

  CustomerApi({
    required http.Client client,
    String? baseUrl,
    Duration timeout = ApiConfig.requestTimeout,
  }) : _client = client,
       _baseUrl = baseUrl ?? ApiConfig.baseUrl,
       _timeout = timeout;

  Future<List<Customer>> fetchCustomers() async {
    final uri = Uri.parse('$_baseUrl${ApiConfig.customersPath}');

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw const ApiException(
        'Unable to reach the server. Check your connection and that the API is running.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Unable to reach the server. Check your connection and that the API is running.',
      );
    }

    if (response.statusCode != 200) {
      throw ApiException(
        'Something went wrong on the server (error ${response.statusCode}).',
      );
    }

    return _parseCustomers(response.body);
  }

  List<Customer> _parseCustomers(String body) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const ApiException('The server sent data we could not read.');
    }

    if (decoded is! List) {
      throw const ApiException('The server sent data in an unexpected format.');
    }

    final customers = <Customer>[];
    for (final item in decoded) {
      // Skip broken records instead of failing the whole list.
      if (item is Map<String, dynamic>) {
        customers.add(Customer.fromJson(item));
      }
    }
    return customers;
  }
}

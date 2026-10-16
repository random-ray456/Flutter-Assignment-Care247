import 'package:customer_search/config/field_config.dart';
import 'package:customer_search/config/search_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('searchConfig', () {
    test('contains first name, last name and date of birth in order', () {
      final keys = sortByRenderOrder(searchConfig).map((f) => f.key).toList();

      expect(keys, ['firstName', 'lastName', 'dateOfBirth']);
    });

    test('date of birth uses the date field type', () {
      final dob = searchConfig.firstWhere((f) => f.key == 'dateOfBirth');

      expect(dob.type, FieldType.date);
    });
  });
}

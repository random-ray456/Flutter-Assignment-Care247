import 'package:customer_search/config/field_config.dart';
import 'package:customer_search/config/search_config.dart';
import 'package:customer_search/widgets/dynamic_search_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, String>? submittedValues;

  Future<void> pumpForm(WidgetTester tester, List<FieldConfig> fields) async {
    submittedValues = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DynamicSearchForm(
              fields: fields,
              onSearch: (values) => submittedValues = values,
              onClear: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('search sends only the filled in values', (tester) async {
    await pumpForm(tester, searchConfig);

    await tester.enterText(
      find.byKey(const ValueKey('field_firstName')),
      ' John ',
    );
    await tester.tap(find.text('Search'));

    expect(submittedValues, {'firstName': 'John'});
  });

  testWidgets('a new configured field is rendered without code changes', (
    tester,
  ) async {
    const fields = [
      ...searchConfig,
      FieldConfig(
        key: 'maritalStatus',
        type: FieldType.text,
        label: 'Marital Status',
        placeholder: 'Enter marital status',
        renderOrder: 4,
      ),
    ];

    await pumpForm(tester, fields);
    expect(find.text('Marital Status'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('field_maritalStatus')),
      'Single',
    );
    await tester.tap(find.text('Search'));

    expect(submittedValues, {'maritalStatus': 'Single'});
  });
}

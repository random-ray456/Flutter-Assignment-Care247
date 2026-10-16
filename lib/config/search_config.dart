import 'field_config.dart';

/// Fields shown on the search screen.
///
/// The key must match the customer JSON property it searches on
/// (for example 'firstName'). To add a new search field just add a new
/// FieldConfig here, e.g.
///
/// FieldConfig(
///   key: 'maritalStatus',
///   type: FieldType.text,
///   label: 'Marital Status',
///   placeholder: 'Enter marital status',
///   renderOrder: 4,
/// ),
const List<FieldConfig> searchConfig = [
  FieldConfig(
    key: 'firstName',
    type: FieldType.text,
    label: 'First Name',
    placeholder: 'Enter first name',
    renderOrder: 1,
  ),
  FieldConfig(
    key: 'lastName',
    type: FieldType.text,
    label: 'Last Name',
    placeholder: 'Enter last name',
    renderOrder: 2,
  ),
  FieldConfig(
    key: 'dateOfBirth',
    type: FieldType.date,
    label: 'Date of Birth',
    placeholder: 'Select date of birth',
    renderOrder: 3,
  ),
];

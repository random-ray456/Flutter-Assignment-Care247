import 'address.dart';
import 'email.dart';
import 'json_helpers.dart';
import 'phone.dart';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String maritalStatus;
  final String secureId;
  final List<Address> addresses;
  final List<Phone> phones;
  final List<Email> emails;

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.secureId,
    required this.addresses,
    required this.phones,
    required this.emails,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: readString(json, 'id'),
      firstName: readString(json, 'firstName'),
      lastName: readString(json, 'lastName'),
      dateOfBirth: readString(json, 'dateOfBirth'),
      maritalStatus: readString(json, 'maritalStatus'),
      secureId: readString(json, 'secureId'),
      addresses: readList(json, 'addresses', Address.fromJson),
      phones: readList(json, 'phones', Phone.fromJson),
      emails: readList(json, 'emails', Email.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'maritalStatus': maritalStatus,
      'secureId': secureId,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'phones': phones.map((p) => p.toJson()).toList(),
      'emails': emails.map((e) => e.toJson()).toList(),
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  /// The phone marked as primary, or the first phone if none is marked.
  Phone? get primaryPhone {
    if (phones.isEmpty) return null;
    for (final phone in phones) {
      if (phone.isPrimary) return phone;
    }
    return phones.first;
  }

  /// The email marked as primary, or the first email if none is marked.
  Email? get primaryEmail {
    if (emails.isEmpty) return null;
    for (final email in emails) {
      if (email.isPrimary) return email;
    }
    return emails.first;
  }
}

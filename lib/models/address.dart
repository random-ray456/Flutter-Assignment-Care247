import 'json_helpers.dart';

class Address {
  final String id;
  final String type;
  final String street;
  final String city;
  final String state;
  final String zipCode;

  const Address({
    required this.id,
    required this.type,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: readString(json, 'id'),
      type: readString(json, 'type'),
      street: readString(json, 'street'),
      city: readString(json, 'city'),
      state: readString(json, 'state'),
      zipCode: readString(json, 'zipCode'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }
}

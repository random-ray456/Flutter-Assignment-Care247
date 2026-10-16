import 'json_helpers.dart';

class Email {
  final String id;
  final String type;
  final String address;
  final bool isPrimary;

  const Email({
    required this.id,
    required this.type,
    required this.address,
    required this.isPrimary,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: readString(json, 'id'),
      type: readString(json, 'type'),
      address: readString(json, 'address'),
      isPrimary: readBool(json, 'isPrimary'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'address': address, 'isPrimary': isPrimary};
  }
}

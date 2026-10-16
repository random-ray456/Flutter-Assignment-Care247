import 'json_helpers.dart';

class Phone {
  final String id;
  final String type;
  final String number;
  final bool isPrimary;

  const Phone({
    required this.id,
    required this.type,
    required this.number,
    required this.isPrimary,
  });

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      id: readString(json, 'id'),
      type: readString(json, 'type'),
      number: readString(json, 'number'),
      isPrimary: readBool(json, 'isPrimary'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'number': number, 'isPrimary': isPrimary};
  }
}

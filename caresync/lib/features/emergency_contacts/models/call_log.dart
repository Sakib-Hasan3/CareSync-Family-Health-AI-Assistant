import 'package:hive/hive.dart';

part 'call_log.g.dart';

@HiveType(typeId: 7)
class CallLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String contactId;

  @HiveField(2)
  final String contactName;

  @HiveField(3)
  final String phoneNumber;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String contactType;

  CallLog({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.phoneNumber,
    required this.timestamp,
    required this.contactType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'contactId': contactId,
        'contactName': contactName,
        'phoneNumber': phoneNumber,
        'timestamp': timestamp.toIso8601String(),
        'contactType': contactType,
      };

  factory CallLog.fromJson(Map<String, dynamic> json) => CallLog(
        id: json['id'] as String,
        contactId: json['contactId'] as String,
        contactName: json['contactName'] as String,
        phoneNumber: json['phoneNumber'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        contactType: json['contactType'] as String,
      );
}

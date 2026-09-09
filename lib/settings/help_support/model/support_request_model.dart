import 'package:cloud_firestore/cloud_firestore.dart';

class SupportRequestModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String issueType;
  final String message;
  final String status;
  final DateTime? createdAt;

  const SupportRequestModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.issueType,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory SupportRequestModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return SupportRequestModel(
      id: documentId.trim(),
      userId: map['userId']?.toString().trim() ?? '',
      name: map['name']?.toString().trim() ?? '',
      email: map['email']?.toString().trim() ?? '',
      issueType: map['issueType']?.toString().trim() ?? '',
      message: map['message']?.toString().trim() ?? '',
      status: map['status']?.toString().trim() ?? 'open',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId.trim(),
      'name': name.trim(),
      'email': email.trim(),
      'issueType': issueType.trim(),
      'message': message.trim(),
      'status': status.trim(),
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }
}

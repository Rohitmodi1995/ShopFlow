import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String loginType;
  final bool isEmailVerified;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.loginType,
    required this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'loginType': loginType,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      loginType: map['loginType'] ?? '',
      isEmailVerified:
          map['isEmailVerified'] ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt:
          (map['updatedAt'] as Timestamp?)?.toDate(),
      lastLoginAt:
          (map['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }
}
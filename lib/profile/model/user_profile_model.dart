class UserProfileModel {
  final String uid;
  final String name;
  final String email;
  final String loginType;
  final bool isEmailVerified;

  const UserProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.loginType,
    required this.isEmailVerified,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      loginType: map['loginType']?.toString() ?? '',
      isEmailVerified: _parseBool(map['isEmailVerified']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'loginType': loginType,
      'isEmailVerified': isEmailVerified,
    };
  }

  UserProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? loginType,
    bool? isEmailVerified,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      loginType: loginType ?? this.loginType,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    if (value is num) {
      return value == 1;
    }

    return false;
  }
}

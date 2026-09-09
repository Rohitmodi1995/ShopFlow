import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/support_request_model.dart';

class SupportRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  SupportRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User get _currentUser {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw StateError('Authenticated user required.');
    }

    return user;
  }

  Future<String> submitSupportRequest({
    required String name,
    required String email,
    required String issueType,
    required String message,
  }) async {
    final user = _currentUser;

    final documentReference = _firestore.collection('support_requests').doc();

    final supportRequest = SupportRequestModel(
      id: documentReference.id,
      userId: user.uid,
      name: name.trim(),
      email: email.trim(),
      issueType: issueType.trim(),
      message: message.trim(),
      status: 'open',
      createdAt: DateTime.now(),
    );

    await documentReference.set(supportRequest.toMap());

    return documentReference.id;
  }
}

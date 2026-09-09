import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  OrderRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _firebaseAuth =
            firebaseAuth ?? FirebaseAuth.instance;

  User get _currentUser {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw StateError(
        'User not logged in.',
      );
    }

    return user;
  }

  Future<String> createOrder(
    OrderModel order,
  ) async {
    try {
      final documentReference =
          _firestore
              .collection('orders')
              .doc();

      final orderData = order.toMap()
        ..['userId'] = _currentUser.uid
        ..['createdAt'] =
            FieldValue.serverTimestamp();

      await documentReference.set(
        orderData,
      );

      return documentReference.id;
    } catch (error) {
      throw StateError(
        'Unable to create order: $error',
      );
    }
  }

  Future<List<OrderModel>>
      getUserOrders() async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where(
                'userId',
                isEqualTo:
                    _currentUser.uid,
              )
              .orderBy(
                'createdAt',
                descending: true,
              )
              .get();

      return snapshot.docs
          .map(
            (document) =>
                OrderModel.fromMap(
              document.id,
              document.data(),
            ),
          )
          .toList();
    } catch (error) {
      throw StateError(
        'Unable to load orders: $error',
      );
    }
  }

  Future<OrderModel?> getOrderById(
    String orderId,
  ) async {
    try {
      final document =
          await _firestore
              .collection('orders')
              .doc(orderId)
              .get();

      final data = document.data();

      if (!document.exists ||
          data == null) {
        return null;
      }

      if (data['userId'] !=
          _currentUser.uid) {
        return null;
      }

      return OrderModel.fromMap(
        document.id,
        data,
      );
    } catch (error) {
      throw StateError(
        'Unable to load order: $error',
      );
    }
  }

  Future<void> updateRazorpayOrderId({
    required String orderId,
    required String razorpayOrderId,
  }) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({
        'razorpayOrderId':
            razorpayOrderId,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw StateError(
        'Unable to update Razorpay order: $error',
      );
    }
  }

  Future<void> updatePaymentSuccess({
    required String orderId,
    required String razorpayPaymentId,
  }) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({
        'paymentStatus': 'paid',
        'orderStatus': 'confirmed',
        'razorpayPaymentId':
            razorpayPaymentId,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw StateError(
        'Unable to update payment status: $error',
      );
    }
  }

  Future<void> updatePaymentFailed({
    required String orderId,
  }) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({
        'paymentStatus': 'failed',
        'orderStatus': 'pending',
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw StateError(
        'Unable to update failed payment: $error',
      );
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({
        'orderStatus': status,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw StateError(
        'Unable to update order status: $error',
      );
    }
  }
}
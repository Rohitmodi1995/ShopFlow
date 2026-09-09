import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/services/notification_service.dart';
import '../model/order_model.dart';
import '../repository/order_repository.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final NotificationService _notificationService;

  OrderViewModel({
    OrderRepository? orderRepository,
    NotificationService? notificationService,
  })  : _orderRepository =
            orderRepository ?? OrderRepository(),
        _notificationService =
            notificationService ?? NotificationService();

  bool _isLoading = false;
  bool _isCreatingOrder = false;
  String? _errorMessage;
  List<OrderModel> _orders = [];
  String? _currentOrderId;

  bool get isLoading => _isLoading;
  bool get isCreatingOrder =>
      _isCreatingOrder;
  String? get errorMessage =>
      _errorMessage;
  List<OrderModel> get orders =>
      List.unmodifiable(_orders);
  String? get currentOrderId =>
      _currentOrderId;
  bool get hasOrders =>
      _orders.isNotEmpty;

  Future<String?> createOrder(
    OrderModel order,
  ) async {
    if (_isCreatingOrder) {
      return null;
    }

    _errorMessage = null;
    _setCreatingOrder(true);

    try {
      final orderId =
          await _orderRepository
              .createOrder(order);

      _currentOrderId = orderId;

      await _showOrderPlacedNotification(
        orderId,
      );

      return orderId;
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToCreateOrder[
              AppConstant.language];

      return null;
    } finally {
      _setCreatingOrder(false);
    }
  }

  Future<void> loadOrders() async {
    _errorMessage = null;
    _setLoading(true);

    try {
      _orders =
          await _orderRepository
              .getUserOrders();
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToLoadOrders[
              AppConstant.language];
    } finally {
      _setLoading(false);
    }
  }

  Future<OrderModel?> getOrderById(
    String orderId,
  ) async {
    _errorMessage = null;

    try {
      return await _orderRepository
          .getOrderById(orderId);
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .unableToLoadOrderDetails[
              AppConstant.language];

      notifyListeners();

      return null;
    }
  }

  Future<bool> saveRazorpayOrderId({
    required String orderId,
    required String razorpayOrderId,
  }) async {
    _errorMessage = null;

    try {
      await _orderRepository
          .updateRazorpayOrderId(
        orderId: orderId,
        razorpayOrderId:
            razorpayOrderId,
      );

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .unableToInitializePayment[
              AppConstant.language];

      notifyListeners();

      return false;
    }
  }

  Future<bool> markPaymentSuccess({
    required String orderId,
    required String razorpayPaymentId,
  }) async {
    _errorMessage = null;

    try {
      await _orderRepository
          .updatePaymentSuccess(
        orderId: orderId,
        razorpayPaymentId:
            razorpayPaymentId,
      );

      await _showPaymentSuccessNotification(
        orderId,
      );

      return true;
    } catch (_) {
      _errorMessage = AppLanguage
              .paymentSuccessfulOrderUpdateFailed[
          AppConstant.language];

      notifyListeners();

      return false;
    }
  }

  Future<bool> markPaymentFailed({
    required String orderId,
  }) async {
    _errorMessage = null;

    try {
      await _orderRepository
          .updatePaymentFailed(
        orderId: orderId,
      );

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .unableToUpdatePaymentStatus[
              AppConstant.language];

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    _errorMessage = null;

    try {
      await _orderRepository
          .updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      final exists = _orders.any(
        (order) =>
            order.id == orderId,
      );

      if (exists) {
        await loadOrders();
      }

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .unableToUpdateOrderStatus[
              AppConstant.language];

      notifyListeners();

      return false;
    }
  }

  Future<void>
      _showOrderPlacedNotification(
    String orderId,
  ) async {
    try {
      await _notificationService
          .showOrderPlacedNotification(
        orderId: orderId,
      );
    } catch (_) {}
  }

  Future<void>
      _showPaymentSuccessNotification(
    String orderId,
  ) async {
    try {
      await _notificationService
          .showPaymentSuccessNotification(
        orderId: orderId,
      );
    } catch (_) {}
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void resetCurrentOrder() {
    _currentOrderId = null;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  void _setCreatingOrder(bool value) {
    if (_isCreatingOrder == value) {
      return;
    }

    _isCreatingOrder = value;
    notifyListeners();
  }
}
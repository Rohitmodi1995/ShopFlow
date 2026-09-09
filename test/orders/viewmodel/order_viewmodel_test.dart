import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopflow/core/constants/app_constants.dart';
import 'package:shopflow/core/constants/app_languages.dart';
import 'package:shopflow/core/services/notification_service.dart';
import 'package:shopflow/orders/model/order_model.dart';
import 'package:shopflow/orders/repository/order_repository.dart';
import 'package:shopflow/orders/viewmodel/order_viewmodel.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class FakeOrderModel extends Fake implements OrderModel {}

void main() {
  late OrderViewModel viewModel;
  late MockOrderRepository mockOrderRepository;
  late MockNotificationService mockNotificationService;

  setUpAll(() {
    registerFallbackValue(FakeOrderModel());
  });

  setUp(() {
    mockOrderRepository = MockOrderRepository();

    mockNotificationService = MockNotificationService();

    viewModel = OrderViewModel(
      orderRepository: mockOrderRepository,
      notificationService: mockNotificationService,
    );
  });

  group('OrderViewModel', () {
    test('initial state should be correct', () {
      expect(viewModel.isLoading, false);

      expect(viewModel.isCreatingOrder, false);

      expect(viewModel.errorMessage, isNull);

      expect(viewModel.orders, isEmpty);

      expect(viewModel.currentOrderId, isNull);

      expect(viewModel.hasOrders, false);
    });

    test('should create order successfully', () async {
      final order = FakeOrderModel();

      when(() => mockOrderRepository.createOrder(any()))
          .thenAnswer((_) async => 'order_1');

      when(
        () => mockNotificationService.showOrderPlacedNotification(
          orderId: any(named: 'orderId'),
        ),
      ).thenAnswer((_) async {});

      final result = await viewModel.createOrder(order);

      expect(result, 'order_1');

      expect(viewModel.currentOrderId, 'order_1');

      expect(viewModel.isCreatingOrder, false);

      expect(viewModel.errorMessage, isNull);

      verify(() => mockOrderRepository.createOrder(order)).called(1);

      verify(
        () => mockNotificationService.showOrderPlacedNotification(
          orderId: 'order_1',
        ),
      ).called(1);
    });

    test('should return null and set error when create order fails', () async {
      final order = FakeOrderModel();

      when(() => mockOrderRepository.createOrder(any()))
          .thenThrow(Exception('Repository error'));

      final result = await viewModel.createOrder(order);

      expect(result, isNull);

      expect(viewModel.currentOrderId, isNull);

      expect(viewModel.isCreatingOrder, false);

      expect(
        viewModel.errorMessage,
        AppLanguage.unableToCreateOrder[AppConstant.language],
      );

      verifyNever(
        () => mockNotificationService.showOrderPlacedNotification(
          orderId: any(named: 'orderId'),
        ),
      );
    });

    test(
      'notification failure should not fail successful order creation',
      () async {
        final order = FakeOrderModel();

        when(() => mockOrderRepository.createOrder(any()))
            .thenAnswer((_) async => 'order_1');

        when(
          () => mockNotificationService.showOrderPlacedNotification(
            orderId: 'order_1',
          ),
        ).thenThrow(Exception('Notification error'));

        final result = await viewModel.createOrder(order);

        expect(result, 'order_1');

        expect(viewModel.currentOrderId, 'order_1');

        expect(viewModel.errorMessage, isNull);
      },
    );

    test('should set error when loading orders fails', () async {
      when(() => mockOrderRepository.getUserOrders())
          .thenThrow(Exception('Repository error'));

      await viewModel.loadOrders();

      expect(viewModel.orders, isEmpty);

      expect(viewModel.isLoading, false);

      expect(
        viewModel.errorMessage,
        AppLanguage.unableToLoadOrders[AppConstant.language],
      );
    });

    test(
      'should return null and set error when loading order details fails',
      () async {
        when(() => mockOrderRepository.getOrderById('order_1'))
            .thenThrow(Exception('Repository error'));

        final result = await viewModel.getOrderById('order_1');

        expect(result, isNull);

        expect(
          viewModel.errorMessage,
          AppLanguage.unableToLoadOrderDetails[AppConstant.language],
        );

        verify(() => mockOrderRepository.getOrderById('order_1')).called(1);
      },
    );

    test('should save Razorpay order id successfully', () async {
      when(
        () => mockOrderRepository.updateRazorpayOrderId(
          orderId: any(named: 'orderId'),
          razorpayOrderId: any(named: 'razorpayOrderId'),
        ),
      ).thenAnswer((_) async {});

      final result = await viewModel.saveRazorpayOrderId(
        orderId: 'order_1',
        razorpayOrderId: 'razorpay_order_1',
      );

      expect(result, true);

      expect(viewModel.errorMessage, isNull);

      verify(
        () => mockOrderRepository.updateRazorpayOrderId(
          orderId: 'order_1',
          razorpayOrderId: 'razorpay_order_1',
        ),
      ).called(1);
    });

    test('should mark payment success and show notification', () async {
      when(
        () => mockOrderRepository.updatePaymentSuccess(
          orderId: any(named: 'orderId'),
          razorpayPaymentId: any(named: 'razorpayPaymentId'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => mockNotificationService.showPaymentSuccessNotification(
          orderId: any(named: 'orderId'),
        ),
      ).thenAnswer((_) async {});

      final result = await viewModel.markPaymentSuccess(
        orderId: 'order_1',
        razorpayPaymentId: 'payment_1',
      );

      expect(result, true);

      expect(viewModel.errorMessage, isNull);

      verify(
        () => mockOrderRepository.updatePaymentSuccess(
          orderId: 'order_1',
          razorpayPaymentId: 'payment_1',
        ),
      ).called(1);

      verify(
        () => mockNotificationService.showPaymentSuccessNotification(
          orderId: 'order_1',
        ),
      ).called(1);
    });

    test('should set error when marking payment failed throws error', () async {
      when(() => mockOrderRepository.updatePaymentFailed(orderId: 'order_1'))
          .thenThrow(Exception('Repository error'));

      final result = await viewModel.markPaymentFailed(orderId: 'order_1');

      expect(result, false);

      expect(
        viewModel.errorMessage,
        AppLanguage.unableToUpdatePaymentStatus[AppConstant.language],
      );
    });

    test('should clear error and reset current order', () async {
      final order = FakeOrderModel();

      when(() => mockOrderRepository.createOrder(any()))
          .thenThrow(Exception('Repository error'));

      await viewModel.createOrder(order);

      expect(viewModel.errorMessage, isNotNull);

      viewModel.clearError();

      expect(viewModel.errorMessage, isNull);

      when(() => mockOrderRepository.createOrder(any()))
          .thenAnswer((_) async => 'order_1');

      when(
        () => mockNotificationService.showOrderPlacedNotification(
          orderId: any(named: 'orderId'),
        ),
      ).thenAnswer((_) async {});

      await viewModel.createOrder(order);

      expect(viewModel.currentOrderId, 'order_1');

      viewModel.resetCurrentOrder();

      expect(viewModel.currentOrderId, isNull);
    });
  });
}

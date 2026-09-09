import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopflow/cart/repository/cart_repository.dart';
import 'package:shopflow/cart/viewmodel/cart_viewmodel.dart';
import 'package:shopflow/core/constants/app_constants.dart';
import 'package:shopflow/core/constants/app_languages.dart';
import 'package:shopflow/home/model/product_model.dart';
import 'package:shopflow/home/repository/home_repository.dart';

class MockCartRepository extends Mock
    implements CartRepository {}

class MockHomeRepository extends Mock
    implements HomeRepository {}

void main() {
  late CartViewModel viewModel;
  late MockCartRepository mockCartRepository;
  late MockHomeRepository mockHomeRepository;

  const product = ProductModel(
    id: 'product_1',
    name: 'Test Product',
    description: 'Test Description',
    price: 1200,
    discountPrice: 1000,
    imageUrl: 'image.jpg',
    images: [],
    categoryId: 'category_1',
    rating: 4.5,
    stock: 5,
    isFeatured: true,
    isActive: true,
  );

  const secondProduct = ProductModel(
    id: 'product_2',
    name: 'Second Product',
    description: 'Second Description',
    price: 800,
    discountPrice: 600,
    imageUrl: 'image2.jpg',
    images: [],
    categoryId: 'category_1',
    rating: 4.0,
    stock: 10,
    isFeatured: false,
    isActive: true,
  );

  setUp(() {
    mockCartRepository = MockCartRepository();
    mockHomeRepository = MockHomeRepository();

    viewModel = CartViewModel(
      cartRepository: mockCartRepository,
      homeRepository: mockHomeRepository,
    );
  });

  group('CartViewModel', () {
    test(
      'initial state should be correct',
      () {
        expect(viewModel.cartItems, isEmpty);
        expect(viewModel.isEmpty, true);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.totalProducts, 0);
        expect(viewModel.totalItems, 0);
        expect(viewModel.subTotal, 0.0);
      },
    );

    test(
      'should add new product to cart successfully',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(
          product,
          quantity: 2,
        );

        expect(viewModel.cartItems.length, 1);
        expect(
          viewModel.cartItems.first.product.id,
          'product_1',
        );
        expect(
          viewModel.cartItems.first.quantity,
          2,
        );
        expect(viewModel.totalProducts, 1);
        expect(viewModel.totalItems, 2);
        expect(viewModel.subTotal, 2000.0);
        expect(viewModel.errorMessage, isNull);

        verify(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 2,
          ),
        ).called(1);
      },
    );

    test(
      'should not add product when stock is zero',
      () async {
        const outOfStockProduct = ProductModel(
          id: 'product_3',
          name: 'Out Of Stock Product',
          description: 'Test Description',
          price: 1000,
          discountPrice: 800,
          imageUrl: 'image.jpg',
          images: [],
          categoryId: 'category_1',
          rating: 4.0,
          stock: 0,
          isFeatured: false,
          isActive: true,
        );

        await viewModel.addToCart(
          outOfStockProduct,
        );

        expect(viewModel.cartItems, isEmpty);
        expect(viewModel.totalItems, 0);

        verifyNever(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        );
      },
    );

    test(
      'should not add product when quantity is zero',
      () async {
        await viewModel.addToCart(
          product,
          quantity: 0,
        );

        expect(viewModel.cartItems, isEmpty);

        verifyNever(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        );
      },
    );

    test(
      'should limit quantity to available stock',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(
          product,
          quantity: 10,
        );

        expect(
          viewModel.getProductQuantity('product_1'),
          5,
        );

        expect(viewModel.totalItems, 5);
        expect(viewModel.subTotal, 5000.0);

        verify(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 5,
          ),
        ).called(1);
      },
    );

    test(
      'should increase quantity for existing product',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(
          product,
          quantity: 1,
        );

        await viewModel.addToCart(
          product,
          quantity: 2,
        );

        expect(viewModel.cartItems.length, 1);

        expect(
          viewModel.getProductQuantity('product_1'),
          3,
        );

        expect(viewModel.totalItems, 3);
        expect(viewModel.subTotal, 3000.0);

        verify(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 1,
          ),
        ).called(1);

        verify(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 3,
          ),
        ).called(1);
      },
    );

    test(
      'should rollback new product when repository update fails',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenThrow(
          Exception('Repository error'),
        );

        await viewModel.addToCart(
          product,
          quantity: 2,
        );

        expect(viewModel.cartItems, isEmpty);
        expect(viewModel.totalItems, 0);

        expect(
          viewModel.errorMessage,
          AppLanguage.unableToUpdateCartError[
              AppConstant.language],
        );

        verify(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 2,
          ),
        ).called(1);
      },
    );

    test(
      'should load valid cart items successfully',
      () async {
        when(
          () => mockCartRepository.getCartItems(),
        ).thenAnswer(
          (_) async => [
            {
              'productId': 'product_1',
              'quantity': 2,
            },
          ],
        );

        when(
          () => mockHomeRepository.getProducts(),
        ).thenAnswer(
          (_) async => [product],
        );

        await viewModel.loadCart();

        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.cartItems.length, 1);

        expect(
          viewModel.getProductQuantity('product_1'),
          2,
        );

        expect(viewModel.totalItems, 2);
        expect(viewModel.subTotal, 2000.0);

        verify(
          () => mockCartRepository.getCartItems(),
        ).called(1);

        verify(
          () => mockHomeRepository.getProducts(),
        ).called(1);
      },
    );

    test(
      'should limit loaded quantity to product stock',
      () async {
        when(
          () => mockCartRepository.getCartItems(),
        ).thenAnswer(
          (_) async => [
            {
              'productId': 'product_1',
              'quantity': 20,
            },
          ],
        );

        when(
          () => mockHomeRepository.getProducts(),
        ).thenAnswer(
          (_) async => [product],
        );

        await viewModel.loadCart();

        expect(
          viewModel.getProductQuantity('product_1'),
          5,
        );

        expect(viewModel.totalItems, 5);
      },
    );

    test(
      'should set error when loading cart fails',
      () async {
        when(
          () => mockCartRepository.getCartItems(),
        ).thenThrow(
          Exception('Repository error'),
        );

        await viewModel.loadCart();

        expect(viewModel.cartItems, isEmpty);
        expect(viewModel.isLoading, false);

        expect(
          viewModel.errorMessage,
          AppLanguage.unableToLoadCartError[
              AppConstant.language],
        );
      },
    );

    test(
      'should increase product quantity successfully',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(product);

        await viewModel.increaseQuantity(
          'product_1',
        );

        expect(
          viewModel.getProductQuantity('product_1'),
          2,
        );

        expect(viewModel.totalItems, 2);
        expect(viewModel.subTotal, 2000.0);

        verify(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 2,
          ),
        ).called(1);
      },
    );

    test(
      'should not increase quantity above available stock',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(
          product,
          quantity: 5,
        );

        clearInteractions(mockCartRepository);

        await viewModel.increaseQuantity(
          'product_1',
        );

        expect(
          viewModel.getProductQuantity('product_1'),
          5,
        );

        verifyNever(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        );
      },
    );

    test(
      'should rollback quantity when increase repository update fails',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(product);

        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 2,
          ),
        ).thenThrow(
          Exception('Repository error'),
        );

        await viewModel.increaseQuantity(
          'product_1',
        );

        expect(
          viewModel.getProductQuantity('product_1'),
          1,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage.unableToUpdateCartError[
              AppConstant.language],
        );
      },
    );

    test(
      'should decrease product quantity successfully',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(
          product,
          quantity: 3,
        );

        await viewModel.decreaseQuantity(
          'product_1',
        );

        expect(
          viewModel.getProductQuantity('product_1'),
          2,
        );

        expect(viewModel.totalItems, 2);
        expect(viewModel.subTotal, 2000.0);

        verify(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 2,
          ),
        ).called(1);
      },
    );

    test(
      'should not decrease quantity below one',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(product);

        clearInteractions(mockCartRepository);

        await viewModel.decreaseQuantity(
          'product_1',
        );

        expect(
          viewModel.getProductQuantity('product_1'),
          1,
        );

        verifyNever(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        );
      },
    );

    test(
      'should rollback quantity when decrease repository update fails',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(
          product,
          quantity: 2,
        );

        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 1,
          ),
        ).thenThrow(
          Exception('Repository error'),
        );

        await viewModel.decreaseQuantity(
          'product_1',
        );

        expect(
          viewModel.getProductQuantity('product_1'),
          2,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage.unableToUpdateCartError[
              AppConstant.language],
        );
      },
    );

    test(
      'should rollback existing product quantity when update fails',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(product);

        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: 'product_1',
            quantity: 3,
          ),
        ).thenThrow(
          Exception('Repository error'),
        );

        await viewModel.addToCart(
          product,
          quantity: 2,
        );

        expect(
          viewModel.getProductQuantity('product_1'),
          1,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage.unableToUpdateCartError[
              AppConstant.language],
        );
      },
    );

    test(
      'should remove product from cart successfully',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockCartRepository.removeFromCart(
            any(),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(
          product,
          quantity: 2,
        );

        await viewModel.removeFromCart(
          'product_1',
        );

        expect(viewModel.cartItems, isEmpty);
        expect(viewModel.isEmpty, true);
        expect(viewModel.totalItems, 0);
        expect(viewModel.subTotal, 0.0);

        verify(
          () => mockCartRepository.removeFromCart(
            'product_1',
          ),
        ).called(1);
      },
    );

    test(
      'should restore product when remove repository call fails',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(
          product,
          quantity: 2,
        );

        when(
          () => mockCartRepository.removeFromCart(
            'product_1',
          ),
        ).thenThrow(
          Exception('Repository error'),
        );

        await viewModel.removeFromCart(
          'product_1',
        );

        expect(viewModel.cartItems.length, 1);

        expect(
          viewModel.getProductQuantity('product_1'),
          2,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage.unableToUpdateCartError[
              AppConstant.language],
        );
      },
    );

    test(
      'should clear cart successfully',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockCartRepository.clearCart(),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(product);

        await viewModel.addToCart(
          secondProduct,
          quantity: 2,
        );

        expect(viewModel.cartItems.length, 2);

        await viewModel.clearCart();

        expect(viewModel.cartItems, isEmpty);
        expect(viewModel.totalProducts, 0);
        expect(viewModel.totalItems, 0);
        expect(viewModel.subTotal, 0.0);

        verify(
          () => mockCartRepository.clearCart(),
        ).called(1);
      },
    );

    test(
      'should restore cart when clear repository call fails',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async {});

        await viewModel.addToCart(product);

        await viewModel.addToCart(
          secondProduct,
          quantity: 2,
        );

        when(
          () => mockCartRepository.clearCart(),
        ).thenThrow(
          Exception('Repository error'),
        );

        await viewModel.clearCart();

        expect(viewModel.cartItems.length, 2);
        expect(viewModel.totalProducts, 2);
        expect(viewModel.totalItems, 3);
        expect(viewModel.subTotal, 2200.0);

        expect(
          viewModel.errorMessage,
          AppLanguage.unableToClearCartError[
              AppConstant.language],
        );
      },
    );

    test(
      'should clear error successfully',
      () async {
        when(
          () => mockCartRepository.addOrUpdateCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenThrow(
          Exception('Repository error'),
        );

        await viewModel.addToCart(product);

        expect(
          viewModel.errorMessage,
          isNotNull,
        );

        viewModel.clearError();

        expect(
          viewModel.errorMessage,
          isNull,
        );
      },
    );
  });
}
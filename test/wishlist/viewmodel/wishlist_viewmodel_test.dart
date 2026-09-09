import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopflow/core/constants/app_constants.dart';
import 'package:shopflow/core/constants/app_languages.dart';
import 'package:shopflow/home/model/product_model.dart';
import 'package:shopflow/home/repository/home_repository.dart';
import 'package:shopflow/wishlist/repository/wishlist_repository.dart';
import 'package:shopflow/wishlist/viewmodel/wishlist_viewmodel.dart';

class MockWishlistRepository extends Mock
    implements WishlistRepository {}

class MockHomeRepository extends Mock
    implements HomeRepository {}

void main() {
  late WishlistViewModel viewModel;
  late MockWishlistRepository mockWishlistRepository;
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
    mockWishlistRepository =
        MockWishlistRepository();

    mockHomeRepository =
        MockHomeRepository();

    viewModel = WishlistViewModel(
      wishlistRepository:
          mockWishlistRepository,
      homeRepository:
          mockHomeRepository,
    );
  });

  group('WishlistViewModel', () {
    test(
      'initial state should be correct',
      () {
        expect(
          viewModel.wishlistProducts,
          isEmpty,
        );

        expect(
          viewModel.isLoading,
          false,
        );

        expect(
          viewModel.errorMessage,
          isNull,
        );

        expect(
          viewModel.isInWishlist(
            'product_1',
          ),
          false,
        );
      },
    );

    test(
      'should load wishlist successfully',
      () async {
        when(
          () => mockWishlistRepository
              .getWishlistProductIds(),
        ).thenAnswer(
          (_) async => [
            'product_1',
          ],
        );

        when(
          () => mockHomeRepository
              .getProducts(),
        ).thenAnswer(
          (_) async => [
            product,
            secondProduct,
          ],
        );

        await viewModel.loadWishlist();

        expect(
          viewModel.isLoading,
          false,
        );

        expect(
          viewModel.errorMessage,
          isNull,
        );

        expect(
          viewModel.wishlistProducts.length,
          1,
        );

        expect(
          viewModel.wishlistProducts
              .first.id,
          'product_1',
        );

        expect(
          viewModel.isInWishlist(
            'product_1',
          ),
          true,
        );

        expect(
          viewModel.isInWishlist(
            'product_2',
          ),
          false,
        );

        verify(
          () => mockWishlistRepository
              .getWishlistProductIds(),
        ).called(1);

        verify(
          () => mockHomeRepository
              .getProducts(),
        ).called(1);
      },
    );

    test(
      'should ignore products not present in product list',
      () async {
        when(
          () => mockWishlistRepository
              .getWishlistProductIds(),
        ).thenAnswer(
          (_) async => [
            'product_99',
          ],
        );

        when(
          () => mockHomeRepository
              .getProducts(),
        ).thenAnswer(
          (_) async => [
            product,
          ],
        );

        await viewModel.loadWishlist();

        expect(
          viewModel.wishlistProducts,
          isEmpty,
        );

        expect(
          viewModel.errorMessage,
          isNull,
        );
      },
    );

    test(
      'should set error when loading wishlist fails',
      () async {
        when(
          () => mockWishlistRepository
              .getWishlistProductIds(),
        ).thenThrow(
          Exception(
            'Repository error',
          ),
        );

        await viewModel.loadWishlist();

        expect(
          viewModel.wishlistProducts,
          isEmpty,
        );

        expect(
          viewModel.isLoading,
          false,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage
                  .unableToLoadWishlistError[
              AppConstant.language],
        );
      },
    );

    test(
      'should add product to wishlist successfully',
      () async {
        when(
          () => mockWishlistRepository
              .addToWishlist(
            any(),
          ),
        ).thenAnswer(
          (_) async {},
        );

        await viewModel.toggleWishlist(
          product,
        );

        expect(
          viewModel.wishlistProducts.length,
          1,
        );

        expect(
          viewModel.isInWishlist(
            'product_1',
          ),
          true,
        );

        expect(
          viewModel.errorMessage,
          isNull,
        );

        verify(
          () => mockWishlistRepository
              .addToWishlist(
            'product_1',
          ),
        ).called(1);

        verifyNever(
          () => mockWishlistRepository
              .removeFromWishlist(
            any(),
          ),
        );
      },
    );

    test(
      'should rollback product when add wishlist fails',
      () async {
        when(
          () => mockWishlistRepository
              .addToWishlist(
            'product_1',
          ),
        ).thenThrow(
          Exception(
            'Repository error',
          ),
        );

        await viewModel.toggleWishlist(
          product,
        );

        expect(
          viewModel.wishlistProducts,
          isEmpty,
        );

        expect(
          viewModel.isInWishlist(
            'product_1',
          ),
          false,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage
                  .unableToUpdateWishlistError[
              AppConstant.language],
        );

        verify(
          () => mockWishlistRepository
              .addToWishlist(
            'product_1',
          ),
        ).called(1);
      },
    );

    test(
      'should remove product from wishlist successfully',
      () async {
        when(
          () => mockWishlistRepository
              .addToWishlist(
            any(),
          ),
        ).thenAnswer(
          (_) async {},
        );

        when(
          () => mockWishlistRepository
              .removeFromWishlist(
            any(),
          ),
        ).thenAnswer(
          (_) async {},
        );

        await viewModel.toggleWishlist(
          product,
        );

        expect(
          viewModel.isInWishlist(
            'product_1',
          ),
          true,
        );

        await viewModel.toggleWishlist(
          product,
        );

        expect(
          viewModel.wishlistProducts,
          isEmpty,
        );

        expect(
          viewModel.isInWishlist(
            'product_1',
          ),
          false,
        );

        verify(
          () => mockWishlistRepository
              .removeFromWishlist(
            'product_1',
          ),
        ).called(1);
      },
    );

    test(
      'should restore product when remove wishlist fails',
      () async {
        when(
          () => mockWishlistRepository
              .addToWishlist(
            any(),
          ),
        ).thenAnswer(
          (_) async {},
        );

        await viewModel.toggleWishlist(
          product,
        );

        when(
          () => mockWishlistRepository
              .removeFromWishlist(
            'product_1',
          ),
        ).thenThrow(
          Exception(
            'Repository error',
          ),
        );

        await viewModel.toggleWishlist(
          product,
        );

        expect(
          viewModel.wishlistProducts.length,
          1,
        );

        expect(
          viewModel.isInWishlist(
            'product_1',
          ),
          true,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage
                  .unableToUpdateWishlistError[
              AppConstant.language],
        );
      },
    );

    test(
      'should preserve product order when remove fails',
      () async {
        when(
          () => mockWishlistRepository
              .getWishlistProductIds(),
        ).thenAnswer(
          (_) async => [
            'product_1',
            'product_2',
          ],
        );

        when(
          () => mockHomeRepository
              .getProducts(),
        ).thenAnswer(
          (_) async => [
            product,
            secondProduct,
          ],
        );

        await viewModel.loadWishlist();

        when(
          () => mockWishlistRepository
              .removeFromWishlist(
            'product_1',
          ),
        ).thenThrow(
          Exception(
            'Repository error',
          ),
        );

        await viewModel.toggleWishlist(
          product,
        );

        expect(
          viewModel.wishlistProducts.length,
          2,
        );

        expect(
          viewModel.wishlistProducts[0].id,
          'product_1',
        );

        expect(
          viewModel.wishlistProducts[1].id,
          'product_2',
        );
      },
    );

    test(
      'should clear error successfully',
      () async {
        when(
          () => mockWishlistRepository
              .addToWishlist(
            'product_1',
          ),
        ).thenThrow(
          Exception(
            'Repository error',
          ),
        );

        await viewModel.toggleWishlist(
          product,
        );

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
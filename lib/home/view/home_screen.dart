import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/viewmodel/cart_viewmodel.dart';
import '../../core/components/home/app_drawer.dart';
import '../../core/components/home/category_item.dart';
import '../../core/components/home/home_banner.dart';
import '../../core/components/home/product_card.dart';
import '../../core/components/home/section_header.dart';
import '../../core/components/shimmer/category_shimmer.dart';
import '../../core/components/shimmer/product_shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/navigation/viewmodel/navigation_viewmodel.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_styles.dart';
import '../../notifications/viewmodel/notification_viewmodel.dart';
import '../../productdetails/view/product_details_screen.dart';
import '../../wishlist/viewmodel/wishlist_viewmodel.dart';
import '../model/category_model.dart';
import '../viewmodel/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<HomeViewModel>().initialize();

      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppDrawer(
        userName: viewModel.userName,
        userEmail: viewModel.userEmail,
      ),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserSection(context, viewModel),
            const SizedBox(height: AppSpacing.lg),
            _buildBannerSection(context, viewModel),
            const SizedBox(height: AppSpacing.lg),
            _buildCategorySection(viewModel),
            const SizedBox(height: AppSpacing.lg),
            _buildProductSection(context, viewModel),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      foregroundColor: colorScheme.onSurface,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      title: Text(
        AppLanguage.appName[AppConstant.language],
        style: AppStyles.mainHeading.copyWith(color: colorScheme.onSurface),
      ),
      actions: [
        Consumer<NotificationViewModel>(
          builder: (context, notificationViewModel, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
                if (notificationViewModel.unreadCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: _buildBadge(
                      notificationViewModel.unreadCount > 99
                          ? '99+'
                          : notificationViewModel.unreadCount.toString(),
                    ),
                  ),
              ],
            );
          },
        ),
        Consumer<CartViewModel>(
          builder: (context, cartViewModel, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    context.read<NavigationViewModel>().changeTab(3);
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
                if (cartViewModel.totalProducts > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: _buildBadge(
                      cartViewModel.totalProducts > 99
                          ? '99+'
                          : cartViewModel.totalProducts.toString(),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBadge(String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.whiteColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, HomeViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final userName = viewModel.userName.isNotEmpty
        ? viewModel.userName
        : AppLanguage.defaultUser[AppConstant.language];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: isDark
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.lightPurple,
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLanguage.hello[AppConstant.language]}, $userName 👋',
                  style: AppStyles.headerText.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppLanguage.welcomeBack[AppConstant.language],
                  style: AppStyles.subHeading.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isLoading) {
      return const SizedBox(height: 180);
    }

    if (viewModel.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bannerHeight = width >= 1200
            ? 260.0
            : width >= 600
            ? 220.0
            : 160.0;

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: bannerHeight,
              child: PageView.builder(
                itemCount: viewModel.banners.length,
                onPageChanged: viewModel.setBannerIndex,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: HomeBanner(banner: viewModel.banners[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(viewModel.banners.length, (index) {
                final isSelected = index == viewModel.currentBannerIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySection(HomeViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SectionHeader(
            title: AppLanguage.categories[AppConstant.language],
            onViewAll: () {
              viewModel.selectCategory('all');
            },
          ),
        ),
        if (viewModel.isLoading)
          const CategoryShimmer()
        else
          SizedBox(
            height: 105,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final allCategory = CategoryModel(
                    id: 'all',
                    name: AppLanguage.all[AppConstant.language],
                    imageUrl: '',
                    isActive: true,
                    order: 0,
                  );

                  return CategoryItem(
                    category: allCategory,
                    isAll: true,
                    isSelected: viewModel.selectedCategory == 'all',
                    onTap: () {
                      viewModel.selectCategory('all');
                    },
                  );
                }

                final category = viewModel.categories[index - 1];

                final categoryKey = category.name.trim().toLowerCase();

                return CategoryItem(
                  category: category,
                  isSelected: viewModel.selectedCategory == categoryKey,
                  onTap: () {
                    viewModel.selectCategory(categoryKey);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProductSection(BuildContext context, HomeViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;

    final products = viewModel.filteredProducts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          SectionHeader(
            title: AppLanguage.featuredProducts[AppConstant.language],
            onViewAll: () {
              viewModel.selectCategory('all');
            },
          ),
          if (viewModel.isLoading)
            const ProductShimmer()
          else if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  AppLanguage.noProductsFound[AppConstant.language],
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = _getProductColumnCount(
                  constraints.maxWidth,
                );

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return ProductCard(
                      product: product,
                      isWishlist: context
                          .watch<WishlistViewModel>()
                          .isInWishlist(product.id),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      onWishlist: () {
                        context.read<WishlistViewModel>().toggleWishlist(
                          product,
                        );
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  int _getProductColumnCount(double width) {
    if (width >= 1200) {
      return 5;
    }

    if (width >= 900) {
      return 4;
    }

    if (width >= 600) {
      return 3;
    }

    return 2;
  }
}

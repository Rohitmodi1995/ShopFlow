import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../cart/view/cart_screen.dart';
import '../../../cart/viewmodel/cart_viewmodel.dart';
import '../../../categories/view/categories_screen.dart';
import '../../../home/view/home_screen.dart';
import '../../../profile/view/profile_screen.dart';
import '../../../wishlist/view/wishlist_screen.dart';
import '../../../wishlist/viewmodel/wishlist_viewmodel.dart';
import '../viewmodel/navigation_viewmodel.dart';
import 'app_bottom_navigation.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<WishlistViewModel>().loadWishlist();
      context.read<CartViewModel>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.select<NavigationViewModel, int>(
      (viewModel) => viewModel.currentIndex,
    );

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeScreen(),
          CategoriesScreen(),
          WishlistScreen(),
          CartScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }
}

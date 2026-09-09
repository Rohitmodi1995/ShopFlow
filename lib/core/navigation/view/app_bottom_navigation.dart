import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_languages.dart';
import '../viewmodel/navigation_viewmodel.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<NavigationViewModel, int>(
      selector: (_, viewModel) => viewModel.currentIndex,
      builder: (
        context,
        currentIndex,
        child,
      ) {
        return BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          onTap: (index) {
            context
                .read<NavigationViewModel>()
                .changeTab(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.home_outlined,
              ),
              activeIcon: const Icon(
                Icons.home,
              ),
              label: AppLanguage.home[AppConstant.language],
            ),
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.grid_view_outlined,
              ),
              activeIcon: const Icon(
                Icons.grid_view,
              ),
              label: AppLanguage.categories[AppConstant.language],
            ),
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.favorite_border,
              ),
              activeIcon: const Icon(
                Icons.favorite,
              ),
              label: AppLanguage.wishlist[AppConstant.language],
            ),
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.shopping_cart_outlined,
              ),
              activeIcon: const Icon(
                Icons.shopping_cart,
              ),
              label: AppLanguage.cart[AppConstant.language],
            ),
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.person_outline,
              ),
              activeIcon: const Icon(
                Icons.person,
              ),
              label: AppLanguage.profile[AppConstant.language],
            ),
          ],
        );
      },
    );
  }
}
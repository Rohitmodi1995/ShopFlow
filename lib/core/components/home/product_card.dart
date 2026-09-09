import 'package:flutter/material.dart';

import '../../../home/model/product_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../theme/app_styles.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlist;
  final bool isWishlist;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlist,
    this.isWishlist = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor =
        isDark ? colorScheme.surface : AppColors.background;

    final imageBackground = isDark
        ? AppColors.primary.withValues(alpha: 0.10)
        : AppColors.lightPurple;

    final borderColor =
        isDark ? theme.dividerColor : AppColors.inputBorder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: imageBackground,
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child;
                                }

                                return const Center(
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Center(
                                  child: Icon(
                                    Icons
                                        .image_not_supported_outlined,
                                    color:
                                        AppColors.primary,
                                    size: 50,
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.primary,
                                size: 55,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor.withValues(
                          alpha: 0.90,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onWishlist,
                        icon: Icon(
                          isWishlist
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppStyles.headerText.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.xs,
                  ),
                  Row(
                    children: [
                      Text(
                        '₹${product.discountPrice.toStringAsFixed(0)}',
                        style:
                            AppStyles.headerText.copyWith(
                          color:
                              colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(
                        width: AppSpacing.xs,
                      ),
                      if (product.price >
                          product.discountPrice)
                        Flexible(
                          child: Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              decoration:
                                  TextDecoration
                                      .lineThrough,
                              color: colorScheme
                                  .onSurface
                                  .withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.xs,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(
                        width: AppSpacing.xs,
                      ),
                      Text(
                        product.rating
                            .toStringAsFixed(1),
                        style:
                            AppStyles.subHeading.copyWith(
                          color: colorScheme
                              .onSurface
                              .withValues(
                            alpha: 0.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
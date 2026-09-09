import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_spacing.dart';

class ProductDetailsShimmer
    extends StatelessWidget {
  const ProductDetailsShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.inputBorder,
      highlightColor: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius:
                    BorderRadius.circular(6),
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            AspectRatio(
              aspectRatio: 1.05,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius:
                      BorderRadius.circular(24),
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Container(
              width: 180,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius:
                    BorderRadius.circular(6),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Container(
              width: 130,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius:
                    BorderRadius.circular(6),
              ),
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            Container(
              width: double.infinity,
              height: 65,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius:
                    BorderRadius.circular(6),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Container(
              width: double.infinity,
              height: 14,
              color: AppColors.whiteColor,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Container(
              width: double.infinity,
              height: 14,
              color: AppColors.whiteColor,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Container(
              width: 220,
              height: 14,
              color: AppColors.whiteColor,
            ),
          ],
        ),
      ),
    );
  }
}
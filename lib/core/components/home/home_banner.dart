import 'package:flutter/material.dart';

import '../../../home/model/banner_model.dart';

class HomeBanner extends StatelessWidget {
  final BannerModel banner;

  const HomeBanner({
    super.key,
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final imageUrl =
        screenWidth < 600 &&
                banner.mobileImageUrl.trim().isNotEmpty
            ? banner.mobileImageUrl.trim()
            : banner.imageUrl.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        color: colorScheme.surface,
        child: imageUrl.isEmpty
            ? _buildErrorWidget(context)
            : Image.network(
                imageUrl,
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
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _buildErrorWidget(context);
                },
              ),
      ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: 40,
        color: colorScheme.onSurface.withValues(
          alpha: 0.45,
        ),
      ),
    );
  }
}
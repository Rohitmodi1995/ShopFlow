import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AddressShimmer extends StatelessWidget {
  const AddressShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, _) =>
            const SizedBox(height: 12),
        itemBuilder: (_, _) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _box(
                      width: 22,
                      height: 22,
                      radius: 11,
                    ),
                    const SizedBox(width: 12),
                    _box(
                      width: 130,
                      height: 16,
                    ),
                    const Spacer(),
                    _box(
                      width: 65,
                      height: 22,
                      radius: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _box(
                  width: 100,
                  height: 13,
                ),
                const SizedBox(height: 10),
                _box(
                  width: double.infinity,
                  height: 13,
                ),
                const SizedBox(height: 8),
                _box(
                  width: 220,
                  height: 13,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _box(
                      width: 65,
                      height: 28,
                      radius: 6,
                    ),
                    const SizedBox(width: 12),
                    _box(
                      width: 70,
                      height: 28,
                      radius: 6,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(radius),
      ),
    );
  }
}
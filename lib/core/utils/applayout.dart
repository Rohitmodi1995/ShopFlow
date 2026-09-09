import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppLayout {
  static double getFormWidth(double constraintsWidth) {
    if (constraintsWidth > 1024) return 500;

    if (constraintsWidth > 600) {
      return constraintsWidth * 0.75;
    }

    return constraintsWidth;
  }

  static double getSplashLogoSize(BoxConstraints constraints) {
    final shortestSide = constraints.biggest.shortestSide;

    if (shortestSide > 1024) {
      return math.min(shortestSide * 0.35, 450);
    }

    if (shortestSide > 600) {
      return math.min(shortestSide * 0.50, 400);
    }

    return math.min(shortestSide * 0.70, 300);
  }
}
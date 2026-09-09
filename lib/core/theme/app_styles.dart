import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppStyles {
  AppStyles._();

  static TextStyle customFont({
    required double fontSize,
    required Color color,
    required FontWeight fontWeight,
  }) {
    return GoogleFonts.lato(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  static final TextStyle mainHeading = customFont(
    fontSize: 32,
    color: AppColors.blackColor,
    fontWeight: FontWeight.w900,
  );

  static final TextStyle subHeading = customFont(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle headerText = customFont(
      fontSize: 14, color: AppColors.blackColor, fontWeight: FontWeight.w400);

  static final TextStyle inputText = customFont(
    fontSize: 15,
    color: AppColors.blackColor,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle inputHint = customFont(
    fontSize: 14,
    color: AppColors.blackColor,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle buttonText = customFont(
    fontSize: 14,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle forgotPassword = customFont(
    fontSize: 13,
    color: AppColors.secondary,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle normalText = customFont(
    fontSize: 14,
    color: AppColors.blackColor,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle linkText = customFont(
    fontSize: 14,
    color: AppColors.blackColor,
    fontWeight: FontWeight.w700,
  );

  static TextStyle textinputStyle = customFont(
      fontSize: 14, color: AppColors.blackColor, fontWeight: FontWeight.w500);


      static final TextStyle orText = customFont(
  fontSize: 14,
  color: AppColors.textPrimary,
  fontWeight: FontWeight.w500,
);

static final TextStyle socialButtonText = customFont(
  fontSize: 14,
  color: AppColors.textPrimary,
  fontWeight: FontWeight.w500,
);

static final footerforloginandsignupText = customFont(
                    fontSize: 16,
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w700);
}

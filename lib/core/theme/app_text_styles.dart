import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const largeTitle = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: 0.37,
    color: AppColors.label, height: 1.2,
  );

  static const title2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3,
    color: AppColors.label,
  );

  static const title3 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2,
    color: AppColors.label,
  );

  static const headline = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.15,
    color: AppColors.label,
  );

  static const body = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.2,
    color: AppColors.label, height: 1.4,
  );

  static const subhead = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: -0.15,
    color: AppColors.secondaryLabel,
  );

  static const footnote = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: -0.08,
    color: AppColors.secondaryLabel,
  );

  static const caption1 = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.tertiaryLabel,
  );

  static const caption2 = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.tertiaryLabel,
  );

  // ── Numeric ──
  static const numericLarge = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.3,
    color: AppColors.label,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const numericMedium = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3,
    color: AppColors.label,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const numericSmall = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2,
    color: AppColors.label,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ── Hero ──
  static const heroValue = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.3,
    color: AppColors.label,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const heroLabel = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.secondaryLabel,
  );
}

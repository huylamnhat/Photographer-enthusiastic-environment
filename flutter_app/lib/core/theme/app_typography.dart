
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const List<String> fontSans = ['IBM Plex Sans', 'Inter', 'system-ui', 'sans-serif'];
  static const List<String> fontMono = ['IBM Plex Mono', 'Menlo', 'Courier', 'monospace'];

  static const TextStyle pageTitle = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.ink,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.ink,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.ink,
  );

  static const TextStyle bodyMedium = body;

  static const TextStyle bodyMuted = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.inkMuted,
  );

  static const TextStyle tableCell = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.ink,
  );

  static const TextStyle caption = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.inkMuted,
  );

  static const TextStyle bodySmall = caption;

  static const TextStyle labelCaps = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.06,
    color: AppColors.inkMuted,
  );

  static const TextStyle metric = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.1,
    color: AppColors.ink,
  );

  static const TextStyle dataMono = TextStyle(
    fontFamilyFallback: fontMono,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.ink,
  );

  static const TextStyle monoSm = TextStyle(
    fontFamilyFallback: fontMono,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.04,
    color: AppColors.inkMuted,
  );

  static const TextStyle button = TextStyle(
    fontFamilyFallback: fontSans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          surface: AppColors.scaffoldBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        cupertinoOverrideTheme: const CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: AppColors.accent,
          scaffoldBackgroundColor: AppColors.scaffoldBg,
          barBackgroundColor: Color(0xF2FFFFFF),
          textTheme: CupertinoTextThemeData(
            navLargeTitleTextStyle: TextStyle(
              inherit: false,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: AppColors.label,
              fontFamily: '.SF Pro Display',
              decoration: TextDecoration.none,
            ),
            navTitleTextStyle: TextStyle(
              inherit: false,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
              color: AppColors.label,
              fontFamily: '.SF Pro Text',
              decoration: TextDecoration.none,
            ),
            navActionTextStyle: TextStyle(
              inherit: false,
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: AppColors.accent,
              fontFamily: '.SF Pro Text',
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
}

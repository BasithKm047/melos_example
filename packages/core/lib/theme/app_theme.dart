import 'package:flutter/material.dart';
import 'package:core/colors/app_colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
    useMaterial3: true,
  );
}

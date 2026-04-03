import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class ChangeIndicator extends StatelessWidget {
  final double value;
  final double fontSize;
  final bool compact;

  const ChangeIndicator({super.key, required this.value, this.fontSize = 13, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isUp = value >= 0;
    final color = isUp ? AppColors.green : AppColors.red;
    return Text(
      '${compact ? '' : (isUp ? '\u25B2 ' : '\u25BC ')}${Formatters.percent(value.abs(), showSign: false)}',
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: color,
        fontFeatures: const [FontFeature.tabularFigures()]),
    );
  }
}

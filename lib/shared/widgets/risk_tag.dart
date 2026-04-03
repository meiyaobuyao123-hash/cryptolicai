import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RiskTag extends StatelessWidget {
  final String level;
  const RiskTag({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      '低' => AppColors.green,
      '中' => AppColors.orange,
      '高' => AppColors.red,
      _ => AppColors.gray,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text('$level风险', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

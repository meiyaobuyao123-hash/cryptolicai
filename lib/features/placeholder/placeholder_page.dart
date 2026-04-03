import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(largeTitle: Text(title), backgroundColor: AppColors.scaffoldBg, border: null),
          SliverFillRemaining(hasScrollBody: false, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14)),
              child: const Icon(CupertinoIcons.rocket, size: 24, color: AppColors.tertiaryLabel)),
            const SizedBox(height: 14),
            Text('即将开放', style: AppTextStyles.headline.copyWith(color: AppColors.secondaryLabel)),
            const SizedBox(height: 4),
            Text('敬请期待', style: AppTextStyles.caption1),
          ]))),
        ],
      ),
    );
  }
}

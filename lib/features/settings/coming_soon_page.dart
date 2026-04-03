import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;
  const ComingSoonPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(title),
            backgroundColor: AppColors.scaffoldBg,
            border: null,
            previousPageTitle: '我的',
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(14)),
                child: const Icon(CupertinoIcons.hammer, size: 24, color: AppColors.tertiaryLabel),
              ),
              const SizedBox(height: 16),
              Text('Coming Soon', style: AppTextStyles.headline.copyWith(color: AppColors.secondaryLabel)),
              const SizedBox(height: 6),
              Text('功能开发中，敬请期待', style: AppTextStyles.footnote),
            ])),
          ),
        ],
      ),
    );
  }
}

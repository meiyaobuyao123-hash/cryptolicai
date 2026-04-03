import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('关于'),
            backgroundColor: AppColors.scaffoldBg,
            border: null,
            previousPageTitle: '我的',
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverToBoxAdapter(child: Column(
              children: [
                const SizedBox(height: 32),
                // App icon
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0F1E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text('C',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
                const SizedBox(height: 16),
                Text('Crypto Earn', style: AppTextStyles.title2),
                const SizedBox(height: 4),
                Text('v1.0.0', style: AppTextStyles.footnote),
                const SizedBox(height: 8),
                Text('加密理财数据平台', style: AppTextStyles.caption1),
                const SizedBox(height: 40),
                // Info items
                Container(
                  decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(14)),
                  child: Column(children: [
                    _InfoRow('数据来源', 'DefiLlama · CoinGecko'),
                    Container(height: 0.5, color: AppColors.separator, margin: const EdgeInsets.only(left: 20)),
                    _InfoRow('支持网络', 'Ethereum · Arbitrum · Base · Solana'),
                    Container(height: 0.5, color: AppColors.separator, margin: const EdgeInsets.only(left: 20)),
                    _InfoRow('开源协议', 'MIT License'),
                  ]),
                ),
                const SizedBox(height: 24),
                Text('数据仅供参考，不构成投资建议', style: AppTextStyles.caption2),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 15)),
        const Spacer(),
        Text(value, style: AppTextStyles.footnote),
      ]),
    );
  }
}

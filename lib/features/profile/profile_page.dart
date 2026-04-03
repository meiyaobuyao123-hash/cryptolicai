import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../wallet/providers/wallet_provider.dart';
import '../wallet/models/wallet_state.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Initialize wallet modal with context
      ref.read(walletProvider.notifier).initModal(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(largeTitle: const Text('我的'), backgroundColor: AppColors.scaffoldBg, border: null),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _WalletCard(wallet: wallet, ref: ref),
              const SizedBox(height: 24),
              _buildGroup(context, [
                _Item(CupertinoIcons.bell, '通知设置', AppColors.red, AppColors.iconBgRed, '/profile/notifications'),
                _Item(CupertinoIcons.shield, '安全中心', AppColors.green, AppColors.iconBgGreen, '/profile/security'),
                _Item(CupertinoIcons.globe, '语言', AppColors.accent, AppColors.iconBgBlue, '/profile/language'),
              ]),
              const SizedBox(height: 16),
              _buildGroup(context, [
                _Item(CupertinoIcons.question_circle, '帮助与反馈', AppColors.purple, AppColors.iconBgPurple, '/profile/help'),
                _Item(CupertinoIcons.info_circle, '关于', AppColors.gray, AppColors.fill, '/profile/about'),
              ]),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, List<_Item> items) {
    return Container(
      decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(14)),
      child: Column(children: items.asMap().entries.map((e) {
        final item = e.value; final isLast = e.key == items.length - 1;
        return Column(children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(item.route),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Container(width: 28, height: 28,
                  decoration: BoxDecoration(color: item.bg, borderRadius: BorderRadius.circular(7)),
                  child: Icon(item.icon, size: 15, color: item.color)),
                const SizedBox(width: 12),
                Expanded(child: Text(item.title, style: AppTextStyles.body.copyWith(fontSize: 15))),
                const Icon(CupertinoIcons.chevron_right, size: 13, color: AppColors.tertiaryLabel),
              ])),
          ),
          if (!isLast) Padding(padding: const EdgeInsets.only(left: 56), child: Container(height: 0.5, color: AppColors.separator)),
        ]);
      }).toList()),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final WalletState wallet;
  final WidgetRef ref;
  const _WalletCard({required this.wallet, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (wallet.isConnected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(CupertinoIcons.checkmark_shield_fill, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('已连接', style: AppTextStyles.headline.copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(wallet.displayAddress ?? '', style: AppTextStyles.footnote),
            ])),
            if (wallet.chainName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(wallet.chainName!, style: AppTextStyles.caption2.copyWith(color: AppColors.accent)),
              ),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 36,
            child: CupertinoButton(
              padding: EdgeInsets.zero, color: AppColors.fill, borderRadius: BorderRadius.circular(10),
              onPressed: () => ref.read(walletProvider.notifier).disconnect(),
              child: Text('断开连接', style: AppTextStyles.footnote.copyWith(color: AppColors.red)),
            ),
          ),
        ]),
      );
    }

    // Disconnected — show connect button
    return GestureDetector(
      onTap: () => ref.read(walletProvider.notifier).connect(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.iconBgBlue, borderRadius: BorderRadius.circular(12)),
            child: const Icon(CupertinoIcons.link, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('连接钱包', style: AppTextStyles.headline),
            const SizedBox(height: 2),
            Text('MetaMask、Trust Wallet、Rainbow 等', style: AppTextStyles.caption1),
          ])),
          const Icon(CupertinoIcons.chevron_right, size: 14, color: AppColors.tertiaryLabel),
        ]),
      ),
    );
  }
}

class _Item {
  final IconData icon; final String title; final Color color, bg; final String route;
  const _Item(this.icon, this.title, this.color, this.bg, this.route);
}

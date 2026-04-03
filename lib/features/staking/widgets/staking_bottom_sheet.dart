import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/risk_tag.dart';
import '../../../shared/widgets/change_indicator.dart';
import '../../data_tab/models/yield_pool.dart';
import '../../wallet/providers/wallet_provider.dart';

class StakingBottomSheet extends ConsumerStatefulWidget {
  final YieldPool pool;
  const StakingBottomSheet({super.key, required this.pool});

  static void show(BuildContext context, YieldPool pool) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StakingBottomSheet(pool: pool),
    );
  }

  @override
  ConsumerState<StakingBottomSheet> createState() => _State();
}

class _State extends ConsumerState<StakingBottomSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final pool = widget.pool;
    final pad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Padding(padding: const EdgeInsets.only(top: 10),
            child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.separator, borderRadius: BorderRadius.circular(2)))),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(pool.symbol, style: AppTextStyles.title2),
                  const SizedBox(width: 8),
                  if (pool.isStablecoin) _Tag('稳定币', AppColors.accent),
                  if (pool.isStablecoin) const SizedBox(width: 4),
                  _Tag(pool.exposureLabel, AppColors.secondaryLabel),
                ]),
                const SizedBox(height: 4),
                Text('${pool.project} · ${pool.chain}', style: AppTextStyles.footnote),
              ])),
              RiskTag(level: pool.riskLevel),
            ]),
          ),

          const SizedBox(height: 16),

          // APY section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(Formatters.apy(pool.apy),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.green,
                      fontFeatures: const [FontFeature.tabularFigures()])),
                  const SizedBox(width: 4),
                  Text('APY', style: AppTextStyles.caption1),
                  const Spacer(),
                  if (pool.apyPct7D != null) ...[
                    ChangeIndicator(value: pool.apyPct7D!, fontSize: 13),
                    Text(' 7天', style: AppTextStyles.caption2),
                  ],
                ]),
                if (pool.apyBase != null && pool.apyBase! > 0) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('基础收益 ${pool.apyBase!.toStringAsFixed(1)}%', style: AppTextStyles.footnote),
                    if (pool.apyReward != null && pool.apyReward! > 0)
                      Text('  +  代币奖励 ${pool.apyReward!.toStringAsFixed(1)}%',
                        style: AppTextStyles.footnote.copyWith(
                          color: pool.isRewardHeavy ? AppColors.orange : AppColors.secondaryLabel)),
                  ]),
                  if (pool.isRewardHeavy)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('⚠ 收益主要来自代币奖励，可能不可持续',
                        style: AppTextStyles.caption2.copyWith(color: AppColors.orange)),
                    ),
                ],
                if (pool.apyMean30d != null) ...[
                  const SizedBox(height: 6),
                  Text('30天均值 ${pool.apyMean30d!.toStringAsFixed(1)}% · ${pool.stabilityLabel}',
                    style: AppTextStyles.caption2),
                ],
              ]),
            ),
          ),

          const SizedBox(height: 12),

          // Key metrics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _InfoBox('TVL', Formatters.compactUsd(pool.tvlUsd)),
              const SizedBox(width: 8),
              _InfoBox('参与者', pool.addressCount != null ? '${_fmt(pool.addressCount!)}' : '-'),
              const SizedBox(width: 8),
              _InfoBox('无常损失', pool.ilRisk == 'no' ? '无' : '有',
                color: pool.ilRisk == 'no' ? AppColors.green : AppColors.orange),
            ]),
          ),

          // Trend prediction
          if (pool.predictedTrend != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: pool.trendIcon == '↗' ? AppColors.green.withValues(alpha: 0.06)
                       : pool.trendIcon == '↘' ? AppColors.red.withValues(alpha: 0.06)
                       : AppColors.fill,
                  borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Text('趋势预测', style: AppTextStyles.caption1),
                  const Spacer(),
                  Text('${pool.trendIcon} ${pool.predictedTrend}', style: AppTextStyles.footnote.copyWith(
                    color: pool.trendIcon == '↗' ? AppColors.green : (pool.trendIcon == '↘' ? AppColors.red : AppColors.label),
                    fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Amount input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('质押金额', style: AppTextStyles.footnote),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _ctrl,
                placeholder: '输入金额',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(12)),
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(pool.symbol.split('-').first, style: AppTextStyles.footnote),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 10),

          // Projected return
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('预估年化收益', style: AppTextStyles.footnote),
                ValueListenableBuilder(
                  valueListenable: _ctrl,
                  builder: (_, __, ___) {
                    final amt = double.tryParse(_ctrl.text) ?? 0;
                    final annual = amt * pool.apy / 100;
                    return Text(annual > 0 ? '\$${annual.toStringAsFixed(2)}' : '-',
                      style: AppTextStyles.numericSmall.copyWith(color: AppColors.green));
                  },
                ),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // Action button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity, height: 50,
              child: CupertinoButton(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
                onPressed: () async {
                  if (!wallet.isConnected) {
                    await ref.read(walletProvider.notifier).initModal(context);
                    ref.read(walletProvider.notifier).connect();
                  } else {
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Text(
                  wallet.isConnected ? '质押' : '连接钱包',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ),

          // Disclaimer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text('APY 为实时浮动，资金将存入链上智能合约，非平台托管',
              style: AppTextStyles.caption2, textAlign: TextAlign.center),
          ),

          SizedBox(height: pad + 16),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text; final Color color;
  const _Tag(this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label, value; final Color? color;
  const _InfoBox(this.label, this.value, {this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label, style: AppTextStyles.caption2),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
          color: color ?? AppColors.label, fontFeatures: const [FontFeature.tabularFigures()])),
      ]),
    ));
  }
}

String _fmt(int n) {
  if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

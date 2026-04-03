import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/change_indicator.dart';
import '../../../shared/widgets/skeleton.dart';
import '../providers/providers.dart';

class MarketPulseSection extends ConsumerWidget {
  const MarketPulseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prices = ref.watch(pricesProvider);
    return prices.when(
      loading: () => Row(children: [
        Expanded(child: Skeleton(height: 72, borderRadius: 16)),
        const SizedBox(width: 12),
        Expanded(child: Skeleton(height: 72, borderRadius: 16)),
      ]),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final btc = data['bitcoin'] ?? {};
        final eth = data['ethereum'] ?? {};
        return Row(children: [
          Expanded(child: _Tile(symbol: 'BTC',
            price: (btc['usd'] as num?)?.toDouble() ?? 0,
            change: (btc['usd_24h_change'] as num?)?.toDouble() ?? 0,
            color: AppColors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _Tile(symbol: 'ETH',
            price: (eth['usd'] as num?)?.toDouble() ?? 0,
            change: (eth['usd_24h_change'] as num?)?.toDouble() ?? 0,
            color: AppColors.indigo)),
        ]);
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final String symbol; final double price, change; final Color color;
  const _Tile({required this.symbol, required this.price, required this.change, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(symbol[0], style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)))),
          const SizedBox(width: 8),
          Text(symbol, style: AppTextStyles.headline.copyWith(fontSize: 15)),
        ]),
        const SizedBox(height: 10),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text(Formatters.usd(price), style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.label,
            fontFeatures: const [FontFeature.tabularFigures()]))),
        const SizedBox(height: 4),
        ChangeIndicator(value: change, fontSize: 13),
      ]),
    );
  }
}

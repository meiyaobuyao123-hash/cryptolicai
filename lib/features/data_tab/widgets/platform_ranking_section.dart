import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/change_indicator.dart';
import '../../../shared/widgets/skeleton.dart';
import '../data_definitions.dart';
import '../models/protocol.dart';
import '../providers/providers.dart';

class PlatformRankingSection extends ConsumerStatefulWidget {
  const PlatformRankingSection({super.key});
  @override
  ConsumerState<PlatformRankingSection> createState() => _State();
}

class _State extends ConsumerState<PlatformRankingSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(protocolFilterProvider);
    final ranking = ref.watch(protocolRankingProvider);

    return SectionCard(
      title: '理财平台排行',
      subtitle: 'DefiLlama · 按锁仓量排序',
      icon: CupertinoIcons.list_number,
      iconColor: AppColors.orange,
      iconBg: AppColors.iconBgOrange,
      infoTitle: DataDefinitions.platformRankingTitle,
      infoSource: DataDefinitions.platformRankingSource,
      infoFields: DataDefinitions.platformRankingFields,
      trailing: SegmentedControl(
        items: const ['全部', 'DeFi', 'CeFi'],
        selected: filter,
        onChanged: (v) => ref.read(protocolFilterProvider.notifier).update(v),
      ),
      padding: const EdgeInsets.only(top: 14),
      child: ranking.when(
        loading: () => Padding(padding: EdgeInsets.zero,
          child: Column(children: List.generate(4, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 10), child: Skeleton(height: 48))))),
        error: (_, __) => Padding(padding: const EdgeInsets.all(16),
          child: Center(child: Text('加载失败', style: AppTextStyles.footnote))),
        data: (protocols) {
          final list = _expanded ? protocols : protocols.take(5).toList();
          return Column(children: [
            // Table header
            Padding(
              padding: EdgeInsets.zero,
              child: Row(children: [
                SizedBox(width: 28, child: Text('#', style: AppTextStyles.caption1)),
                const SizedBox(width: 8),
                Expanded(child: Text('平台', style: AppTextStyles.caption1)),
                SizedBox(width: 80, child: Text('TVL', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
                SizedBox(width: 56, child: Text('7d', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
              ]),
            ),
            const SizedBox(height: 8),
            ...list.asMap().entries.map((e) => _Row(rank: e.key + 1, protocol: e.value)),
            if (protocols.length > 5)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_expanded ? '收起' : '查看全部 ${protocols.length} 个',
                    style: AppTextStyles.footnote.copyWith(color: AppColors.accent))),
              ),
          ]);
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final int rank;
  final Protocol protocol;
  const _Row({required this.rank, required this.protocol});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!protocol.isCefi) {
          context.push('/data/platform/${protocol.slug}?name=${Uri.encodeComponent(protocol.name)}');
        }
      },
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        SizedBox(width: 28, child: Text('$rank',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: rank <= 3 ? [AppColors.gold, AppColors.silver, AppColors.bronze][rank - 1] : AppColors.tertiaryLabel))),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(protocol.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, fontSize: 14)),
          Text(protocolCategoryLabel(protocol.category),
            style: AppTextStyles.caption2.copyWith(color: protocol.isCefi ? AppColors.orange : AppColors.accent)),
        ])),
        SizedBox(width: 80, child: Text(Formatters.compactUsd(protocol.tvl),
          style: AppTextStyles.numericSmall.copyWith(fontSize: 14), textAlign: TextAlign.right)),
        SizedBox(width: 56, child: protocol.change7d != null
          ? Align(alignment: Alignment.centerRight, child: ChangeIndicator(value: protocol.change7d!, fontSize: 12, compact: true))
          : Text('-', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
      ]),
    ));
  }
}

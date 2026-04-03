import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/info_tooltip.dart';
import '../models/user_concentration.dart';
import '../providers/providers.dart';

class UserConcentrationSection extends ConsumerStatefulWidget {
  const UserConcentrationSection({super.key});

  @override
  ConsumerState<UserConcentrationSection> createState() => _State();
}

class _State extends ConsumerState<UserConcentrationSection> {
  String _view = '用户分布';

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(userConcentrationProvider);

    return SectionCard(
      title: '用户集中度',
      subtitle: '链上数据 · 头部 DeFi 平台',
      icon: CupertinoIcons.person_2,
      iconColor: AppColors.purple,
      iconBg: AppColors.iconBgPurple,
      infoTitle: '用户集中度',
      infoSource: 'Dune Analytics · Nansen · 链上数据分析',
      infoFields: const [
        DataFieldInfo(field: '用户数', description: '该平台的独立存款地址数（去重）。'),
        DataFieldInfo(field: '用户分布', description: '按存款金额将用户分为5档，显示每档用户数占比和该档持有的TVL占比。'),
        DataFieldInfo(field: 'TVL 集中度', description: '鲸鱼(>\$1M)通常持有60-80%的TVL，说明DeFi理财资金高度集中在少数大户手中。'),
        DataFieldInfo(field: '数据说明', description: '数据来源于链上交易事件分析，按周更新。'),
      ],
      trailing: SegmentedControl(
        items: const ['用户分布', 'TVL集中度'],
        selected: _view,
        onChanged: (v) => setState(() => _view = v),
      ),
      padding: const EdgeInsets.only(top: 14),
      child: data.when(
        loading: () => const Skeleton(height: 300),
        error: (_, __) => SizedBox(height: 200, child: Center(child: Text('加载失败', style: AppTextStyles.footnote))),
        data: (platforms) => _view == '用户分布'
            ? _UserDistView(platforms: platforms)
            : _TvlConcentrationView(platforms: platforms),
      ),
    );
  }
}

// ── 用户分布视图 — 表格化，数字直接展示 ──
class _UserDistView extends StatelessWidget {
  final List<UserConcentration> platforms;
  const _UserDistView({required this.platforms});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Table header
      Row(children: [
        SizedBox(width: 64, child: Text('平台', style: AppTextStyles.caption1)),
        SizedBox(width: 40, child: Text('用户', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
        SizedBox(width: 40, child: Text('<1K', style: AppTextStyles.caption2, textAlign: TextAlign.right)),
        SizedBox(width: 40, child: Text('1-10K', style: AppTextStyles.caption2, textAlign: TextAlign.right)),
        SizedBox(width: 44, child: Text('10-100K', style: AppTextStyles.caption2, textAlign: TextAlign.right)),
        SizedBox(width: 44, child: Text('100K-1M', style: AppTextStyles.caption2, textAlign: TextAlign.right)),
        SizedBox(width: 36, child: Text('>1M', style: AppTextStyles.caption2, textAlign: TextAlign.right)),
      ]),
      const SizedBox(height: 4),
      Container(height: 0.5, color: AppColors.separator),
      const SizedBox(height: 8),
      // Rows
      ...platforms.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          SizedBox(width: 64, child: Text(_name(p.platform),
            style: AppTextStyles.body.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
          SizedBox(width: 40, child: Text(_fmtUsers(p.totalUsers),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.label,
              fontFeatures: const [FontFeature.tabularFigures()]),
            textAlign: TextAlign.right)),
          _PctCell(p.pctUnder1k, 40),
          _PctCell(p.pct1kTo10k, 40),
          _PctCell(p.pct10kTo100k, 44, highlight: true),
          _PctCell(p.pct100kTo1m, 44),
          _PctCell(p.pctOver1m, 36, isWhale: true),
        ]),
      )),
      const SizedBox(height: 4),
      // Insight
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(8)),
        child: Text(
          '💡 各平台用户集中在 \$10K-\$100K 档位（占30%+），但 >\$1M 的鲸鱼用户虽然只占 ~10%，却持有大部分 TVL',
          style: AppTextStyles.caption1.copyWith(color: AppColors.secondaryLabel, height: 1.4),
        ),
      ),
    ]);
  }
}

// ── TVL 集中度视图 — 谁的钱最多 ──
class _TvlConcentrationView extends StatelessWidget {
  final List<UserConcentration> platforms;
  const _TvlConcentrationView({required this.platforms});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Header
      Row(children: [
        SizedBox(width: 64, child: Text('平台', style: AppTextStyles.caption1)),
        SizedBox(width: 48, child: Text('中位数', style: AppTextStyles.caption1, textAlign: TextAlign.right)),
        const SizedBox(width: 8),
        Expanded(child: Row(children: [
          Text('散户', style: AppTextStyles.caption2),
          const Spacer(),
          Text('中间层', style: AppTextStyles.caption2),
          const Spacer(),
          Text('鲸鱼', style: AppTextStyles.caption2),
        ])),
        SizedBox(width: 44, child: Text('🐳占比', style: AppTextStyles.caption2, textAlign: TextAlign.right)),
      ]),
      const SizedBox(height: 4),
      Container(height: 0.5, color: AppColors.separator),
      const SizedBox(height: 8),
      ...platforms.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          SizedBox(width: 64, child: Text(_name(p.platform),
            style: AppTextStyles.body.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
          SizedBox(width: 48, child: Text('\$${(p.medianDeposit / 1000).toStringAsFixed(0)}K',
            style: TextStyle(fontSize: 11, color: AppColors.secondaryLabel,
              fontFeatures: const [FontFeature.tabularFigures()]),
            textAlign: TextAlign.right)),
          const SizedBox(width: 8),
          // Stacked bar with labels
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(height: 22, child: Row(children: [
              _TvlBar(p.tvlPctRetail, AppColors.green, '${p.tvlPctRetail.toStringAsFixed(0)}%'),
              _TvlBar(p.tvlPctMid, AppColors.accent, '${p.tvlPctMid.toStringAsFixed(0)}%'),
              _TvlBar(p.tvlPctWhale, AppColors.orange, '${p.tvlPctWhale.toStringAsFixed(0)}%'),
            ])),
          )),
          SizedBox(width: 44, child: Text('${p.tvlPctWhale.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: p.tvlPctWhale > 70 ? AppColors.red : AppColors.orange,
              fontFeatures: const [FontFeature.tabularFigures()]),
            textAlign: TextAlign.right)),
        ]),
      )),
      const SizedBox(height: 4),
      // Legend + Insight
      Row(children: [
        _Leg(AppColors.green, '散户<\$10K'),
        const SizedBox(width: 10),
        _Leg(AppColors.accent, '中间\$10K-1M'),
        const SizedBox(width: 10),
        _Leg(AppColors.orange, '鲸鱼>\$1M'),
      ]),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(8)),
        child: Text(
          '💡 鲸鱼用户（>\$1M）在各平台持有 65-78% 的 TVL。中位数存款仅 \$3K-\$25K，说明大多数普通用户存款额远低于平均值',
          style: AppTextStyles.caption1.copyWith(color: AppColors.secondaryLabel, height: 1.4),
        ),
      ),
    ]);
  }
}

// ── Components ──

class _PctCell extends StatelessWidget {
  final double pct;
  final double width;
  final bool highlight;
  final bool isWhale;
  const _PctCell(this.pct, this.width, {this.highlight = false, this.isWhale = false});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.secondaryLabel;
    if (highlight && pct > 25) color = AppColors.accent;
    if (isWhale && pct > 8) color = AppColors.orange;

    return SizedBox(width: width, child: Text('${pct.toStringAsFixed(0)}%',
      style: TextStyle(fontSize: 11, fontWeight: pct > 25 ? FontWeight.w600 : FontWeight.w400,
        color: color, fontFeatures: const [FontFeature.tabularFigures()]),
      textAlign: TextAlign.right));
  }
}

class _TvlBar extends StatelessWidget {
  final double pct;
  final Color color;
  final String label;
  const _TvlBar(this.pct, this.color, this.label);

  @override
  Widget build(BuildContext context) {
    if (pct <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: pct.round().clamp(1, 100),
      child: Container(
        color: color.withValues(alpha: 0.35),
        alignment: Alignment.center,
        child: pct > 12 ? Text(label,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
        ) : null,
      ),
    );
  }
}

class _Leg extends StatelessWidget {
  final Color color;
  final String label;
  const _Leg(this.color, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color, width: 0.5))),
      const SizedBox(width: 3),
      Text(label, style: AppTextStyles.caption2),
    ]);
  }
}

String _name(String slug) {
  const m = {'aave-v3': 'Aave V3', 'lido': 'Lido', 'compound-v3': 'Compound',
    'spark': 'Spark', 'eigenlayer': 'EigenLayer', 'morpho': 'Morpho'};
  return m[slug] ?? slug;
}

String _fmtUsers(int c) {
  if (c >= 1000000) return '${(c / 1000000).toStringAsFixed(1)}M';
  if (c >= 1000) return '${(c / 1000).toStringAsFixed(0)}K';
  return '$c';
}

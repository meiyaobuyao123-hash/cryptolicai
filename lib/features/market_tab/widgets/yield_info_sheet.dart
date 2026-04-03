import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/platform_yield_info.dart';

void showYieldInfoSheet(BuildContext context, String projectSlug) {
  final info = PlatformYieldInfo.get(projectSlug);
  if (info == null) return;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => YieldInfoSheet(info: info),
  );
}

class YieldInfoSheet extends StatelessWidget {
  final PlatformYieldInfo info;
  const YieldInfoSheet({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Padding(padding: const EdgeInsets.only(top: 10),
          child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: AppColors.separator, borderRadius: BorderRadius.circular(2)))),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(info.name, style: AppTextStyles.title2),
              const SizedBox(height: 2),
              Text(info.type, style: AppTextStyles.caption1),
            ])),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(width: 28, height: 28,
                decoration: BoxDecoration(color: AppColors.fill, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: AppColors.secondaryLabel)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        // One-liner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
            child: Text(info.oneLiner,
              style: AppTextStyles.body.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.green)),
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 0.5, color: AppColors.separator, margin: const EdgeInsets.symmetric(horizontal: 20)),
        // Scrollable content
        Flexible(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Analogy
            Text('通俗理解', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text(info.analogy, style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.5, color: AppColors.secondaryLabel)),
            const SizedBox(height: 20),
            // How it works — step by step
            Text('收益怎么来的', style: AppTextStyles.headline),
            const SizedBox(height: 10),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(12)),
              child: Text(info.howItWorks, style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.7)),
            ),
            const SizedBox(height: 20),
            // Main risk — highlighted
            Text('最需要注意的', style: AppTextStyles.headline),
            const SizedBox(height: 10),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.2)),
              ),
              child: Text(info.mainRisk, style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.5)),
            ),
            // Other risks
            if (info.otherRisks.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...info.otherRisks.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('· ', style: AppTextStyles.footnote),
                  Expanded(child: Text(r, style: AppTextStyles.footnote.copyWith(height: 1.4))),
                ]),
              )),
            ],
            const SizedBox(height: 20),
            // Suitable / Not suitable
            Row(children: [
              Expanded(child: _FitBox(
                icon: '✅', title: '适合',
                text: info.suitableFor,
                color: AppColors.green,
              )),
              const SizedBox(width: 10),
              Expanded(child: _FitBox(
                icon: '❌', title: '不适合',
                text: info.notSuitableFor,
                color: AppColors.red,
              )),
            ]),
            const SizedBox(height: 16),
          ]),
        )),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
      ]),
    );
  }
}

class _FitBox extends StatelessWidget {
  final String icon, title, text;
  final Color color;
  const _FitBox({required this.icon, required this.title, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$icon $title', style: AppTextStyles.footnote.copyWith(fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 6),
        Text(text, style: AppTextStyles.caption1.copyWith(height: 1.4, color: AppColors.secondaryLabel)),
      ]),
    );
  }
}

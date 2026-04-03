import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DataFieldInfo {
  final String field;
  final String description;
  const DataFieldInfo({required this.field, required this.description});
}

class InfoTooltipButton extends StatelessWidget {
  final String title;
  final String dataSource;
  final List<DataFieldInfo> fields;
  final Color iconColor;

  const InfoTooltipButton({
    super.key,
    required this.title,
    required this.dataSource,
    required this.fields,
    this.iconColor = AppColors.tertiaryLabel,
  });

  factory InfoTooltipButton.light({
    Key? key,
    required String title,
    required String dataSource,
    required List<DataFieldInfo> fields,
  }) {
    return InfoTooltipButton(
      key: key, title: title, dataSource: dataSource, fields: fields,
      iconColor: AppColors.tertiaryLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _show(context),
      behavior: HitTestBehavior.opaque,
      child: Icon(CupertinoIcons.question_circle, size: 18, color: AppColors.tertiaryLabel),
    );
  }

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _InfoSheet(title: title, dataSource: dataSource, fields: fields),
    );
  }
}

class _InfoSheet extends StatelessWidget {
  final String title;
  final String dataSource;
  final List<DataFieldInfo> fields;
  const _InfoSheet({required this.title, required this.dataSource, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.separator, borderRadius: BorderRadius.circular(2))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: AppColors.iconBgBlue, borderRadius: BorderRadius.circular(8)),
                child: const Icon(CupertinoIcons.info, size: 18, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: AppTextStyles.title3)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppColors.fill, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 14, color: AppColors.secondaryLabel),
                ),
              ),
            ]),
          ),
          Container(height: 0.5, color: AppColors.separator, margin: const EdgeInsets.symmetric(horizontal: 16)),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Data source tag
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.iconBgBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('数据来源：$dataSource',
                    style: AppTextStyles.footnote.copyWith(color: AppColors.accent, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 20),
                Text('字段说明', style: AppTextStyles.headline),
                const SizedBox(height: 14),
                ...fields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(margin: const EdgeInsets.only(top: 6), width: 4, height: 4,
                      decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.field, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(f.description, style: AppTextStyles.footnote.copyWith(height: 1.5)),
                    ])),
                  ]),
                )),
              ]),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LanguageNotifier extends Notifier<String> {
  @override
  String build() => '简体中文';
  void update(String v) => state = v;
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('语言'),
            backgroundColor: AppColors.scaffoldBg,
            border: null,
            previousPageTitle: '我的',
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  _LangRow(
                    title: '简体中文',
                    subtitle: 'Simplified Chinese',
                    isSelected: current == '简体中文',
                    onTap: () => ref.read(languageProvider.notifier).update('简体中文'),
                  ),
                  Container(height: 0.5, color: AppColors.separator, margin: const EdgeInsets.only(left: 56)),
                  _LangRow(
                    title: 'English',
                    subtitle: '英文',
                    isSelected: current == 'English',
                    onTap: () => ref.read(languageProvider.notifier).update('English'),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  const _LangRow({required this.title, required this.subtitle, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.body.copyWith(fontSize: 15)),
            Text(subtitle, style: AppTextStyles.caption1),
          ])),
          if (isSelected)
            const Icon(CupertinoIcons.checkmark_alt, size: 18, color: AppColors.accent),
        ]),
      ),
    );
  }
}

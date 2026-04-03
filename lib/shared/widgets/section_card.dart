import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'info_tooltip.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets? padding;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBg;
  final String? infoTitle;
  final String? infoSource;
  final List<DataFieldInfo>? infoFields;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding,
    this.icon,
    this.iconColor,
    this.iconBg,
    this.infoTitle,
    this.infoSource,
    this.infoFields,
  });

  @override
  Widget build(BuildContext context) {
    final hasInfo = infoTitle != null && infoSource != null && infoFields != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: iconBg ?? AppColors.iconBgBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor ?? AppColors.accent),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headline),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.caption1),
                ],
              )),
              if (hasInfo) InfoTooltipButton(
                title: infoTitle!, dataSource: infoSource!, fields: infoFields!),
            ],
          ),
        ),
        // Controls
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 4),
            child: trailing!,
          ),
        // Content
        Padding(
          padding: padding ?? const EdgeInsets.only(top: 14),
          child: child,
        ),
        // Bottom divider
        const SizedBox(height: 6),
        Container(height: 1, color: AppColors.separator),
      ],
    );
  }
}

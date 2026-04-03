import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';

class FrostedTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FrostedTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: const Color(0xF5F5F5F5),
      activeColor: AppColors.label,
      inactiveColor: AppColors.tertiaryLabel,
      iconSize: 22,
      height: 50,
      border: Border(top: BorderSide(color: AppColors.separator, width: 0.5)),
      items: const [
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar), activeIcon: Icon(CupertinoIcons.chart_bar_fill), label: '数据'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.compass), activeIcon: Icon(CupertinoIcons.compass_fill), label: '市场'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.arrow_right_arrow_left), activeIcon: Icon(CupertinoIcons.arrow_right_arrow_left_circle_fill), label: '交易'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), activeIcon: Icon(CupertinoIcons.person_fill), label: '我的'),
      ],
    );
  }
}

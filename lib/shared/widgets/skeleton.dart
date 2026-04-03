import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class Skeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  const Skeleton({super.key, this.width = double.infinity, required this.height, this.borderRadius = 8});
  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _a, builder: (_, __) => Container(
      width: widget.width, height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: Color.lerp(AppColors.fill, AppColors.separator, _a.value * 0.3),
      ),
    ));
  }
}

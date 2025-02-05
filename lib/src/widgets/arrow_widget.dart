import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../json_view.dart';
import '../painters/arrow_painter.dart';

class ArrowWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final bool expanded;
  final JsonConfigData config;

  const ArrowWidget({
    super.key,
    this.onTap,
    this.expanded = false,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final cs = config.color ?? JsonConfigData.defaultColor(context);
    Widget? arrow = config.style?.arrow;
    if (arrow != null) {
      arrow = IconTheme(
        data: IconThemeData(color: cs.normalColor, size: 16),
        child: arrow,
      );
    } else {
      arrow = CustomPaint(
        painter: ArrowPainter(color: cs.markColor ?? Colors.black),
        size: const Size(16, 16),
      );
    }

    if (config.animation ?? JsonConfigData.kUseAnimation) {
      arrow = AnimatedRotation(
        turns: expanded ? .25 : 0,
        duration: config.animationDuration ?? JsonConfigData.kAnimationDuration,
        curve: config.animationCurve ?? JsonConfigData.kAnimationCurve,
        child: arrow,
      );
    } else {
      arrow = Transform.rotate(
        angle: expanded ? .25 * math.pi * 2.0 : 0,
        child: arrow,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: arrow,
      ),
    );
  }
}

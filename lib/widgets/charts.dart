import 'dart:math';

import 'package:flutter/material.dart';

/// Кольцевая диаграмма расходов по категориям, рисуется вручную —
/// с зазорами между секторами и скруглёнными концами.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.values,
    required this.colors,
    this.strokeWidth = 22,
    this.child,
  });

  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => CustomPaint(
        painter: _DonutPainter(
          values: values,
          colors: colors,
          strokeWidth: strokeWidth,
          progress: progress,
          trackColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.values,
    required this.colors,
    required this.strokeWidth,
    required this.progress,
    required this.trackColor,
  });

  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final double progress;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(rect, 0, 2 * pi, false, track);

    final total = values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return;

    const gap = 0.035; // зазор между секторами, радианы
    var start = -pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi * progress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = colors[i % colors.length];
      final effectiveSweep = max(0.0, sweep - gap);
      if (effectiveSweep > 0.01) {
        canvas.drawArc(rect, start + gap / 2, effectiveSweep, false, paint);
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.values != values;
}

/// Плавная линия расходов с градиентной заливкой под кривой.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.strokeWidth = 3,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: color,
          strokeWidth: strokeWidth,
          progress: progress,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(max);
    if (maxV <= 0) return;

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * (1 - 0.85 * values[i] / maxV) - 2;
      points.add(Offset(x, y));
    }

    // Плавная кривая Катмулла — Рома через точки.
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[0] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width * progress, size.height),
    );

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.30), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress || old.values != values;
}

/// Столбчатый график расходов по дням со скруглёнными барами
/// и подсветкой максимума.
class DailyBars extends StatelessWidget {
  const DailyBars({super.key, required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => CustomPaint(
        painter: _BarsPainter(
          values: values,
          color: color,
          progress: progress,
          baseColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.color,
    required this.progress,
    required this.baseColor,
  });

  final List<double> values;
  final Color color;
  final double progress;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce(max);
    final slot = size.width / values.length;
    final barWidth = min(slot * 0.62, 14.0);

    for (var i = 0; i < values.length; i++) {
      final x = slot * i + (slot - barWidth) / 2;
      final isMax = maxV > 0 && values[i] == maxV;
      final h = maxV <= 0
          ? 0.0
          : max(barWidth, size.height * 0.9 * (values[i] / maxV) * progress);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barWidth, h),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = values[i] <= 0
              ? baseColor
              : isMax
                  ? color
                  : color.withValues(alpha: 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.progress != progress || old.values != values;
}

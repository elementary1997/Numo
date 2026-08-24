import 'dart:math';

import 'package:flutter/material.dart';

import '../core/money.dart';

/// Подпись на канве графика.
void _paintLabel(
  Canvas canvas,
  String text,
  Offset position, {
  required Color color,
  double fontSize = 10,
  FontWeight weight = FontWeight.w600,
  TextAlign align = TextAlign.left,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final dx = switch (align) {
    TextAlign.right => position.dx - painter.width,
    TextAlign.center => position.dx - painter.width / 2,
    _ => position.dx,
  };
  painter.paint(canvas, Offset(dx, position.dy));
}

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

/// Плавная линия с градиентной заливкой, сеткой и подписями
/// минимума/максимума. [labels] — реальные значения ряда для подписей
/// (сам [values] может быть нормализован).
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.labels,
    this.strokeWidth = 3,
  });

  final List<double> values;
  final Color color;
  final List<double>? labels;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => CustomPaint(
        painter: _SparklinePainter(
          values: values,
          labels: labels,
          color: color,
          strokeWidth: strokeWidth,
          progress: progress,
          gridColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          labelColor: theme.colorScheme.onSurfaceVariant,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.strokeWidth,
    required this.progress,
    required this.gridColor,
    required this.labelColor,
  });

  final List<double> values;
  final List<double>? labels;
  final Color color;
  final double strokeWidth;
  final double progress;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(max);
    if (maxV <= 0) return;

    // Горизонтальная сетка.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final fraction in [0.15, 0.5, 0.85]) {
      final y = size.height * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

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

    if (progress >= 1 && labels != null && labels!.length == values.length) {
      // Конечная точка с текущим значением.
      final endPoint = points.last;
      canvas.drawCircle(endPoint, 4, Paint()..color = color);
      _paintLabel(
        canvas,
        formatMoney(labels!.last),
        Offset(size.width - 2, max(0, endPoint.dy - 18)),
        color: color,
        fontSize: 11,
        weight: FontWeight.w700,
        align: TextAlign.right,
      );
      // Минимум и максимум ряда.
      final minLabel = labels!.reduce(min);
      final maxLabel = labels!.reduce(max);
      if (maxLabel > minLabel) {
        _paintLabel(canvas, formatMoney(maxLabel), const Offset(2, 2),
            color: labelColor);
        _paintLabel(canvas, formatMoney(minLabel),
            Offset(2, size.height - 14),
            color: labelColor);
      }
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress || old.values != values;
}

/// Столбчатый график расходов по дням: сетка со значениями, подпись
/// максимума, выбор дня тапом.
class DailyBars extends StatelessWidget {
  const DailyBars({
    super.key,
    required this.values,
    required this.color,
    this.selectedIndex,
    this.onBarTap,
  });

  final List<double> values;
  final Color color;
  final int? selectedIndex;
  final ValueChanged<int>? onBarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: onBarTap == null
            ? null
            : (details) {
                final slot = constraints.maxWidth / values.length;
                final index =
                    (details.localPosition.dx / slot).floor().clamp(
                        0, values.length - 1);
                onBarTap!(index);
              },
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, progress, _) => CustomPaint(
            painter: _BarsPainter(
              values: values,
              color: color,
              progress: progress,
              selectedIndex: selectedIndex,
              baseColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.07),
              gridColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.06),
              labelColor: theme.colorScheme.onSurfaceVariant,
              onSurface: theme.colorScheme.onSurface,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        ),
      );
    });
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.color,
    required this.progress,
    required this.baseColor,
    required this.gridColor,
    required this.labelColor,
    required this.onSurface,
    this.selectedIndex,
  });

  final List<double> values;
  final Color color;
  final double progress;
  final Color baseColor;
  final Color gridColor;
  final Color labelColor;
  final Color onSurface;
  final int? selectedIndex;

  static const _topPadding = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce(max);
    final slot = size.width / values.length;
    final barWidth = min(slot * 0.62, 14.0);
    final chartHeight = size.height - _topPadding;

    // Сетка: половина и максимум, с подписями сумм справа.
    if (maxV > 0) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 1;
      for (final fraction in [1.0, 0.5]) {
        final y = _topPadding + chartHeight * (1 - 0.9 * fraction);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
        _paintLabel(
          canvas,
          formatMoney(maxV * fraction),
          Offset(size.width - 2, y - 13),
          color: labelColor,
          align: TextAlign.right,
        );
      }
    }

    int? highlight = selectedIndex;
    if (highlight == null && maxV > 0) {
      highlight = values.indexOf(maxV);
    }

    for (var i = 0; i < values.length; i++) {
      final x = slot * i + (slot - barWidth) / 2;
      final isHighlight = i == highlight && values[i] > 0;
      final h = maxV <= 0
          ? 0.0
          : max(barWidth, chartHeight * 0.9 * (values[i] / maxV) * progress);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barWidth, h),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = values[i] <= 0
              ? baseColor
              : isHighlight
                  ? color
                  : color.withValues(alpha: 0.45),
      );

      // Значение над выделенным баром.
      if (isHighlight && progress >= 1) {
        _paintLabel(
          canvas,
          formatMoney(values[i]),
          Offset(
            (x + barWidth / 2).clamp(18.0, size.width - 18.0),
            size.height - h - 16,
          ),
          color: onSurface,
          fontSize: 11,
          weight: FontWeight.w700,
          align: TextAlign.center,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.progress != progress ||
      old.values != values ||
      old.selectedIndex != selectedIndex;
}

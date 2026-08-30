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

/// Подпись-чип с подложкой; центр по [anchorX], верх по [top].
/// Не выходит за границы [bounds].
void _paintChip(
  Canvas canvas,
  String text, {
  required double anchorX,
  required double top,
  required Size bounds,
  required Color background,
  required Color foreground,
  Color? border,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
          fontSize: 10.5, fontWeight: FontWeight.w700, color: foreground),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  const padX = 7.0;
  const padY = 3.5;
  final w = painter.width + padX * 2;
  final h = painter.height + padY * 2;
  final left = (anchorX - w / 2).clamp(2.0, bounds.width - w - 2);
  final clampedTop = top.clamp(2.0, bounds.height - h - 2);
  final rect = RRect.fromRectAndRadius(
    Rect.fromLTWH(left, clampedTop, w, h),
    const Radius.circular(7),
  );
  canvas.drawRRect(
    rect,
    Paint()
      ..color = background
      ..style = PaintingStyle.fill,
  );
  if (border != null) {
    canvas.drawRRect(
      rect,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
  painter.paint(canvas, Offset(left + padX, clampedTop + padY));
}

/// Кольцевая диаграмма расходов по категориям, рисуется вручную —
/// с зазорами между секторами и скруглёнными концами.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    this.semanticsLabel,
    required this.values,
    required this.colors,
    this.strokeWidth = 22,
    this.child,
  });

  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final Widget? child;

  /// Что скажет скринридер вместо картинки.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return _labelled(
        semanticsLabel,
        TweenAnimationBuilder<double>(
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
    ));
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

    final sweeps = donutSweeps(values);
    if (sweeps.isEmpty) return;

    const gap = 0.035; // зазор между секторами, радианы
    var start = -pi / 2;
    for (var i = 0; i < sweeps.length; i++) {
      final sweep = sweeps[i] * progress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = colors[i % colors.length];
      // Зазор не должен съедать сам сегмент: у мелких долей он меньше.
      final effectiveGap = min(gap, sweep * 0.4);
      final effectiveSweep = sweep - effectiveGap;
      if (effectiveSweep > 0.005) {
        canvas.drawArc(
            rect, start + effectiveGap / 2, effectiveSweep, false, paint);
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.values != values;
}

/// Наименьшая заметная дуга сектора (радианы, ≈6°). Доля в один
/// процент — это 3,6°: без нижней границы такой сектор превращается
/// в невидимую царапину.
const minDonutSweep = 0.105;

/// Углы секторов пончика: мелкие доли получают минимальную заметную
/// дугу, а крупные ужимаются пропорционально, чтобы круг оставался
/// полным. Вынесено из художника, чтобы проверяться тестами.
List<double> donutSweeps(List<double> values, {double? minSweep}) {
  final positive = values.map((v) => v < 0 ? 0.0 : v).toList();
  final total = positive.fold(0.0, (a, b) => a + b);
  if (total <= 0) return const [];

  final floor = minSweep ?? minDonutSweep;
  const fullCircle = 2 * pi;
  // Если даже равные доли меньше минимума (секторов очень много),
  // делим круг поровну — иначе на всех не хватит.
  if (floor * positive.length >= fullCircle) {
    return List.filled(positive.length, fullCircle / positive.length);
  }

  final sweeps = positive.map((v) => v / total * fullCircle).toList();
  // Сколько круга занимают поднятые до минимума сектора и сколько
  // остаётся на пропорциональные.
  var liftedCount = 0;
  var restShare = 0.0;
  for (final sweep in sweeps) {
    if (sweep < floor) {
      liftedCount++;
    } else {
      restShare += sweep;
    }
  }
  if (liftedCount == 0) return sweeps;

  final available = fullCircle - floor * liftedCount;
  return [
    for (final sweep in sweeps)
      if (sweep < floor) floor else sweep / restShare * available,
  ];
}

/// Плавная линия с градиентной заливкой, сеткой и аккуратными
/// подписями (не наезжают на линию и края). [labels] — реальные
/// значения ряда для подписей.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    this.semanticsLabel,
    required this.values,
    required this.color,
    this.labels,
    this.strokeWidth = 2.5,
  });

  final List<double> values;
  final Color color;
  final List<double>? labels;
  final double strokeWidth;

  /// Что скажет скринридер вместо картинки.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _labelled(
        semanticsLabel,
        TweenAnimationBuilder<double>(
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
          gridColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          labelColor: theme.colorScheme.onSurfaceVariant,
          chipBackground: theme.colorScheme.surface,
          chipBorder: theme.colorScheme.onSurface.withValues(alpha: 0.10),
        ),
        size: Size.infinite,
      ),
    ));
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
    required this.chipBackground,
    required this.chipBorder,
  });

  final List<double> values;
  final List<double>? labels;
  final Color color;
  final double strokeWidth;
  final double progress;
  final Color gridColor;
  final Color labelColor;
  final Color chipBackground;
  final Color chipBorder;

  static const _topPad = 24.0;
  static const _bottomPad = 16.0;
  static const _sidePad = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(max);
    if (maxV <= 0) return;
    final chartHeight = size.height - _topPad - _bottomPad;
    final chartWidth = size.width - _sidePad * 2;

    // Горизонтальная сетка.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final fraction in [0.0, 0.5, 1.0]) {
      final y = _topPad + chartHeight * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = _sidePad + chartWidth * i / (values.length - 1);
      final y = _topPad + chartHeight * (1 - values[i] / maxV);
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
      ..lineTo(points.last.dx, size.height - _bottomPad + 8)
      ..lineTo(points.first.dx, size.height - _bottomPad + 8)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
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
      // Конечная точка с белым кольцом.
      final endPoint = points.last;
      canvas.drawCircle(
          endPoint, 5.5, Paint()..color = chipBackground);
      canvas.drawCircle(endPoint, 3.5, Paint()..color = color);

      // Значение на конце: над точкой, а если точка у верхнего края —
      // под ней; чип не выходит за границы.
      final labelTop =
          endPoint.dy > 34 ? endPoint.dy - 30 : endPoint.dy + 10;
      _paintChip(
        canvas,
        formatMoney(labels!.last),
        anchorX: endPoint.dx - 20,
        top: labelTop,
        bounds: size,
        background: chipBackground,
        foreground: color,
        border: chipBorder,
      );

      // Минимум и максимум ряда — мелко по левому краю.
      final minLabel = labels!.reduce(min);
      final maxLabel = labels!.reduce(max);
      if (maxLabel > minLabel) {
        _paintLabel(canvas, formatMoney(maxLabel),
            Offset(_sidePad, _topPad - 16),
            color: labelColor, fontSize: 9.5);
        _paintLabel(canvas, formatMoney(minLabel),
            Offset(_sidePad, size.height - _bottomPad + 3),
            color: labelColor, fontSize: 9.5);
      }
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress || old.values != values;
}

/// Столбчатый график расходов по дням: градиентные бары, сетка со
/// значениями, чип с суммой над выбранным днём, выбор тапом.
class DailyBars extends StatelessWidget {
  const DailyBars({
    super.key,
    this.semanticsLabel,
    required this.values,
    required this.color,
    this.selectedIndex,
    this.onBarTap,
  });

  final List<double> values;
  final Color color;
  final int? selectedIndex;
  final ValueChanged<int>? onBarTap;

  /// Что скажет скринридер вместо картинки.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _labelled(semanticsLabel,
        LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: onBarTap == null
            ? null
            : (details) {
                final slot = constraints.maxWidth / values.length;
                final index = (details.localPosition.dx / slot)
                    .floor()
                    .clamp(0, values.length - 1);
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
                  theme.colorScheme.onSurface.withValues(alpha: 0.06),
              gridColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.05),
              labelColor: theme.colorScheme.onSurfaceVariant,
              chipBackground: theme.colorScheme.surface,
              chipForeground: theme.colorScheme.onSurface,
              chipBorder:
                  theme.colorScheme.onSurface.withValues(alpha: 0.10),
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        ),
      );
    }));
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
    required this.chipBackground,
    required this.chipForeground,
    required this.chipBorder,
    this.selectedIndex,
  });

  final List<double> values;
  final Color color;
  final double progress;
  final Color baseColor;
  final Color gridColor;
  final Color labelColor;
  final Color chipBackground;
  final Color chipForeground;
  final Color chipBorder;
  final int? selectedIndex;

  static const _topPad = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce(max);
    final slot = size.width / values.length;
    final barWidth = min(slot * 0.58, 12.0);
    final chartHeight = size.height - _topPad;

    // Сетка: максимум и половина, суммы мелко над линиями справа.
    if (maxV > 0) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 1;
      for (final fraction in [1.0, 0.5]) {
        final y = _topPad + chartHeight * (1 - fraction);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
        _paintLabel(
          canvas,
          formatMoney(maxV * fraction),
          Offset(size.width - 2, y - 12),
          color: labelColor,
          fontSize: 9.5,
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
          : max(barWidth, chartHeight * (values[i] / maxV) * progress);
      final barRect = Rect.fromLTWH(x, size.height - h, barWidth, h);

      final rrect = RRect.fromRectAndCorners(
        barRect,
        topLeft: Radius.circular(barWidth / 2),
        topRight: Radius.circular(barWidth / 2),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      );
      final paint = Paint();
      if (values[i] <= 0) {
        paint.color = baseColor;
      } else if (isHighlight) {
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withValues(alpha: 0.75)],
        ).createShader(barRect);
      } else {
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.45),
            color.withValues(alpha: 0.28),
          ],
        ).createShader(barRect);
      }
      canvas.drawRRect(rrect, paint);

      // Чип с суммой над выбранным баром.
      if (isHighlight && progress >= 1) {
        _paintChip(
          canvas,
          formatMoney(values[i]),
          anchorX: x + barWidth / 2,
          top: size.height - h - 26,
          bounds: size,
          background: chipBackground,
          foreground: chipForeground,
          border: chipBorder,
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

/// Оборачивает график в Semantics: сам по себе CustomPaint для
/// скринридера — пустое место.
Widget _labelled(String? label, Widget chart) => label == null
    ? chart
    : Semantics(label: label, image: true, excludeSemantics: true, child: chart);

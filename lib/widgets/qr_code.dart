import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// QR-код кодом приглашения (ADR-0016). Кодирует пакет `qr`,
/// рисуем сами — как и остальную графику в проекте.
class InviteQr extends StatelessWidget {
  const InviteQr({
    super.key,
    required this.data,
    this.size = 180,
    this.semanticsLabel,
  });

  final String data;
  final double size;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Уровень коррекции M: код приглашения короткий, запас на
    // блики и палец на экране не мешает.
    final code = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    final image = QrImage(code);

    return Semantics(
      label: semanticsLabel,
      image: true,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(10), // тихая зона по краям
        decoration: BoxDecoration(
          // Белый фон независимо от темы: тёмный QR на тёмном фоне
          // сканеры читают заметно хуже.
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
        ),
        child: CustomPaint(painter: _QrPainter(image)),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final modules = image.moduleCount;
    final cell = size.shortestSide / modules;
    final paint = Paint()..color = const Color(0xFF1A1A1C);

    for (var x = 0; x < modules; x++) {
      for (var y = 0; y < modules; y++) {
        if (!image.isDark(y, x)) continue;
        // Плюс волосок к стороне: иначе между модулями просвечивают
        // щели от округления координат.
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell + 0.5, cell + 0.5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.image != image;
}

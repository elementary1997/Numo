import 'dart:math';

import 'package:flutter/material.dart';

import '../core/brands.dart';
import '../models/account.dart';

/// Аватар счёта: брендовый значок (`brand:<key>`) или обычная иконка
/// в цвете счёта. Узнаваемые бренды рисуются векторно, остальные —
/// монограммой в фирменном цвете.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.account, this.size = 46});

  final Account account;
  final double size;

  @override
  Widget build(BuildContext context) {
    final brand = brandFromIconKey(account.iconKey);
    if (brand != null) {
      return BrandBadge(brand: brand, size: size);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: account.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Icon(account.icon, color: account.color, size: size * 0.5),
    );
  }
}

/// Значок бренда: для известных — рисованное лого, иначе монограмма.
class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key, required this.brand, this.size = 46});

  final Brand brand;
  final double size;

  static const _drawn = {'sber', 'tbank', 'mts', 'ozon', 'sovcom', 'yandex'};

  @override
  Widget build(BuildContext context) {
    if (_drawn.contains(brand.key)) {
      return CustomPaint(
        size: Size.square(size),
        painter: _BrandLogoPainter(brand.key),
      );
    }
    final circle = brand.key == 'usdt';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: brand.background,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            circle ? null : BorderRadius.circular(size * 0.22),
      ),
      child: Text(
        brand.label,
        style: TextStyle(
          color: brand.foreground,
          fontWeight: FontWeight.w800,
          fontSize: brand.label.length > 1 ? size * 0.30 : size * 0.44,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

/// Стилизованные векторные лого узнаваемых брендов.
class _BrandLogoPainter extends CustomPainter {
  _BrandLogoPainter(this.key);

  final String key;

  void _text(Canvas canvas, Size size, String text, Color color,
      {double scale = 0.4, FontWeight weight = FontWeight.w800}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size.height * scale,
          fontWeight: weight,
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset((size.width - painter.width) / 2,
          (size.height - painter.height) / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    switch (key) {
      case 'sber':
        // Зелёный круг, незамкнутое белое кольцо с галочкой у разрыва.
        canvas.drawCircle(
            center, radius, Paint()..color = const Color(0xFF21A038));
        final ring = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.11
          ..strokeCap = StrokeCap.round
          ..color = Colors.white;
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius * 0.58),
            -pi / 3,
            1.75 * pi,
            false,
            ring);
        // Галочка входит в круг сверху справа.
        final check = Path()
          ..moveTo(size.width * 0.40, size.height * 0.48)
          ..lineTo(size.width * 0.55, size.height * 0.58)
          ..lineTo(size.width * 0.95, size.height * 0.22);
        canvas.drawPath(
            check,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size.width * 0.11
              ..strokeCap = StrokeCap.round
              ..color = Colors.white);
      case 'tbank':
        // Жёлтый скруглённый квадрат, чёрный щит, жёлтая «Т».
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                rect, Radius.circular(size.width * 0.22)),
            Paint()..color = const Color(0xFFFFDD2D));
        final shield = Path()
          ..moveTo(size.width * 0.30, size.height * 0.24)
          ..lineTo(size.width * 0.70, size.height * 0.24)
          ..lineTo(size.width * 0.70, size.height * 0.55)
          ..quadraticBezierTo(size.width * 0.70, size.height * 0.70,
              size.width * 0.50, size.height * 0.80)
          ..quadraticBezierTo(size.width * 0.30, size.height * 0.70,
              size.width * 0.30, size.height * 0.55)
          ..close();
        canvas.drawPath(shield, Paint()..color = const Color(0xFF1F1F1F));
        final t = Paint()..color = const Color(0xFFFFDD2D);
        canvas.drawRect(
            Rect.fromLTWH(size.width * 0.38, size.height * 0.33,
                size.width * 0.24, size.height * 0.075),
            t);
        canvas.drawRect(
            Rect.fromLTWH(size.width * 0.465, size.height * 0.33,
                size.width * 0.07, size.height * 0.33),
            t);
      case 'mts':
        // Красный скруглённый квадрат с белым яйцом.
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                rect, Radius.circular(size.width * 0.22)),
            Paint()..color = const Color(0xFFE30611));
        final egg = Path();
        final cx = size.width / 2;
        egg.moveTo(cx, size.height * 0.18);
        egg.cubicTo(
            size.width * 0.72, size.height * 0.34,
            size.width * 0.78, size.height * 0.56,
            size.width * 0.78, size.height * 0.62);
        egg.arcToPoint(Offset(size.width * 0.22, size.height * 0.62),
            radius: Radius.circular(size.width * 0.28), clockwise: true);
        egg.cubicTo(
            size.width * 0.22, size.height * 0.56,
            size.width * 0.28, size.height * 0.34,
            cx, size.height * 0.18);
        canvas.drawPath(egg, Paint()..color = Colors.white);
      case 'ozon':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                rect, Radius.circular(size.width * 0.22)),
            Paint()..color = const Color(0xFF005BFF));
        _text(canvas, size, 'ozon', Colors.white, scale: 0.30);
      case 'sovcom':
        // Круг из красной и синей половин с белым просветом.
        canvas.drawCircle(center, radius, Paint()..color = Colors.white);
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius * 0.86),
            pi + 0.25,
            pi - 0.5,
            true,
            Paint()..color = const Color(0xFFFF4D5A));
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius * 0.86),
            0.25,
            pi - 0.5,
            true,
            Paint()..color = const Color(0xFF00348D));
      case 'yandex':
        canvas.drawCircle(
            center, radius, Paint()..color = const Color(0xFFFC3F1D));
        _text(canvas, size, 'Я', Colors.white, scale: 0.5);
    }
  }

  @override
  bool shouldRepaint(_BrandLogoPainter old) => old.key != key;
}

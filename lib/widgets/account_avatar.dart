import 'package:flutter/material.dart';

import '../core/brands.dart';
import '../models/account.dart';

/// Аватар счёта: официальная иконка бренда (`brand:<key>`) на белой
/// подложке или обычная иконка в цвете счёта.
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

/// Иконка бренда: официальный логотип на белой карточке — так и
/// прозрачные лого (МТС, ВТБ) читаются в тёмной теме.
class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key, required this.brand, this.size = 46});

  final Brand brand;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.14),
        child: Image.asset(
          'assets/brands/${brand.key}.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              brand.label,
              style: TextStyle(
                color: brand.background,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

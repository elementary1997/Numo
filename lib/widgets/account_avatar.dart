import 'package:flutter/material.dart';

import '../core/brands.dart';
import '../models/account.dart';

/// Аватар счёта: брендовый бейдж (`brand:<key>`) или обычная иконка
/// в цвете счёта.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.account, this.size = 46});

  final Account account;
  final double size;

  @override
  Widget build(BuildContext context) {
    final brand = brandFromIconKey(account.iconKey);
    if (brand != null) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: brand.background,
          borderRadius: BorderRadius.circular(size * 0.22),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.tx, this.showTime = true});

  final Tx tx;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final category = Categories.byId(tx.categoryId);
    final theme = Theme.of(context);
    final subtitle = [
      if (tx.note.isNotEmpty) tx.note,
      if (showTime)
        DateFormat.Hm('ru').format(tx.date)
      else
        DateFormat('d MMM', 'ru').format(tx.date),
    ].join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(category.icon, color: category.color, size: 23),
      ),
      title: Text(
        category.title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        formatSigned(tx.amount, isExpense: tx.isExpense),
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: tx.isExpense ? theme.colorScheme.onSurface : NumoColors.mint,
        ),
      ),
    );
  }
}

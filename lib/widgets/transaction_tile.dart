import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/l10n.dart';
import '../core/money.dart';
import '../core/theme.dart';
import '../models/category.dart';
import '../models/member.dart';
import '../models/transaction.dart';
import '../state/providers.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.tx,
    this.showTime = true,
    this.onTap,
  });

  final Tx tx;
  final bool showTime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoriesProvider).byId(tx.categoryId);
    final theme = Theme.of(context);
    final locale = context.localeCode;
    // Автора показываем только у операций, внесённых другим участником
    // общего счёта, — свои и так свои.
    final author = ref.watch(membersProvider).tryById(tx.authorId);
    final otherAuthor = author != null && !author.isMe ? author : null;
    final subtitle = [
      if (tx.note.isNotEmpty) tx.note,
      if (showTime)
        DateFormat.Hm(locale).format(tx.date)
      else
        DateFormat('d MMM', locale).format(tx.date),
    ].join(' · ');

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(category.icon, color: category.color, size: 23),
      ),
      title: Text(
        category.title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (otherAuthor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: otherAuthor.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              otherAuthor.name,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: otherAuthor.color, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

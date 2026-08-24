import 'package:flutter/material.dart';

import '../core/l10n.dart';

/// Выбор дня месяца календарной сеткой 7×5 — вместо длинного
/// выпадающего списка «1-е … 31-е».
Future<int?> showMonthDayPicker(BuildContext context,
    {required int selected}) {
  return showDialog<int>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: Text(context.l10n.dayLabel),
        content: SizedBox(
          width: 308,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var d = 1; d <= 31; d++)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pop(d),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: d == selected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                    ),
                    child: Text(
                      '$d',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            d == selected ? FontWeight.w700 : FontWeight.w500,
                        color: d == selected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

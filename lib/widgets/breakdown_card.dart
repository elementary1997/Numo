import 'package:flutter/material.dart';

import '../core/money.dart';
import 'charts.dart';

/// Строка легенды кольцевой диаграммы: цвет, название, сумма и доля.
class BreakdownEntry {
  const BreakdownEntry({
    required this.title,
    required this.color,
    required this.value,
    this.icon,
  });

  final String title;
  final Color color;
  final double value;
  final IconData? icon;
}

/// Карточка «кольцевая диаграмма + легенда» — используется на экранах
/// категорий и счетов.
class BreakdownCard extends StatelessWidget {
  const BreakdownCard({
    super.key,
    required this.title,
    required this.entries,
    this.centerLabel,
    this.maxLegendRows = 6,
  });

  final String title;
  final List<BreakdownEntry> entries;
  final String? centerLabel;
  final int maxLegendRows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = entries.fold(0.0, (sum, e) => sum + e.value);
    if (total <= 0) return const SizedBox.shrink();
    final top = entries.take(maxLegendRows).toList();
    final restValue = entries
        .skip(maxLegendRows)
        .fold(0.0, (sum, e) => sum + e.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 118,
                  height: 118,
                  child: DonutChart(
                    values: [
                      for (final e in top) e.value,
                      if (restValue > 0) restValue,
                    ],
                    colors: [
                      for (final e in top) e.color,
                      if (restValue > 0)
                        theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.35),
                    ],
                    strokeWidth: 18,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (centerLabel != null)
                          Text(centerLabel!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                        FittedBox(
                          child: Text(
                            formatMoney(total),
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      for (final e in top)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                    color: e.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  e.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatMoney(e.value),
                                style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 34,
                                child: Text(
                                  '${(e.value / total * 100).round()}%',
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

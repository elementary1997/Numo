import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/category_rule.dart';
import '../state/providers.dart';

/// Правила автокатегоризации: «подстрока в описании → категория».
class RulesScreen extends ConsumerWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rules = ref.watch(rulesProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Автокатегории'),
        actions: [
          if (rules.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final changed = await ref
                    .read(rulesProvider.notifier)
                    .applyToExisting();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(SnackBar(
                        content: Text(changed == 0
                            ? 'Совпадений не нашлось'
                            : 'Переклассифицировано операций: $changed')));
                }
              },
              icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
              label: const Text('Применить'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRuleDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Правило'),
      ),
      body: rules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Например: «ПЯТЕРОЧКА → Продукты». Правила срабатывают '
                  'при импорте выписок, а кнопкой «Применить» — '
                  'и на уже существующих операциях.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                for (final rule in rules)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onTap: () =>
                        _showRuleDialog(context, ref, initial: rule),
                    leading: Icon(
                      categories.byId(rule.categoryId).icon,
                      color: categories.byId(rule.categoryId).color,
                    ),
                    title: Text('«${rule.pattern}»',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    subtitle:
                        Text(categories.byId(rule.categoryId).title),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: theme.colorScheme.onSurfaceVariant),
                      onPressed: () => ref
                          .read(rulesProvider.notifier)
                          .remove(rule.id),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _showRuleDialog(BuildContext context, WidgetRef ref,
      {CategoryRule? initial}) async {
    final controller = TextEditingController(text: initial?.pattern ?? '');
    final categories = ref
        .read(categoriesProvider)
        .where((c) => !c.archived && c.id != Categories.transfer.id)
        .toList();
    var categoryId = initial?.categoryId ?? categories.first.id;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(initial == null ? 'Новое правило' : 'Изменить правило'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Подстрока в описании',
                  hintText: 'ПЯТЕРОЧКА',
                ),
              ),
              const SizedBox(height: 14),
              DropdownMenu<String>(
                initialSelection: categoryId,
                label: const Text('Категория'),
                expandedInsets: EdgeInsets.zero,
                onSelected: (v) =>
                    setState(() => categoryId = v ?? categoryId),
                dropdownMenuEntries: [
                  for (final c in categories)
                    DropdownMenuEntry(value: c.id, label: c.title),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final pattern = controller.text.trim();
                if (pattern.isEmpty) return;
                ref.read(rulesProvider.notifier).upsert(CategoryRule(
                      id: initial?.id ??
                          'crule-${DateTime.now().microsecondsSinceEpoch}',
                      pattern: pattern,
                      categoryId: categoryId,
                    ));
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }
}

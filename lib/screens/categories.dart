import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../state/providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final expense = categories.where((c) => !c.isIncome).toList();
    final income = categories.where((c) => c.isIncome).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCategoryEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новая'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          _Section(title: 'Расходы', categories: expense),
          const SizedBox(height: 20),
          _Section(title: 'Доходы', categories: income),
        ],
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({required this.title, required this.categories});

  final String title;
  final List<TxCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Активные сверху, архивные приглушённо в конце.
    final sorted = [
      ...categories.where((c) => !c.archived),
      ...categories.where((c) => c.archived),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        for (final c in sorted)
          Opacity(
            opacity: c.archived ? 0.45 : 1,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: () => showCategoryEditor(context, initial: c),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(c.icon, color: c.color, size: 22),
              ),
              title: Text(c.title,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              subtitle: c.archived
                  ? Text('В архиве',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant))
                  : null,
              trailing: IconButton(
                tooltip: c.archived ? 'Вернуть из архива' : 'В архив',
                icon: Icon(
                  c.archived
                      ? Icons.unarchive_rounded
                      : Icons.archive_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => ref
                    .read(categoriesProvider.notifier)
                    .setArchived(c.id, !c.archived),
              ),
            ),
          ),
      ],
    );
  }
}

/// Sheet создания/редактирования категории.
Future<void> showCategoryEditor(
  BuildContext context, {
  TxCategory? initial,
  bool isIncome = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 520),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _CategoryEditor(initial: initial, isIncome: isIncome),
  );
}

class _CategoryEditor extends ConsumerStatefulWidget {
  const _CategoryEditor({this.initial, required this.isIncome});

  final TxCategory? initial;
  final bool isIncome;

  @override
  ConsumerState<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends ConsumerState<_CategoryEditor> {
  late final TextEditingController _title;
  late String _iconKey;
  late Color _color;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _title = TextEditingController(text: c?.title ?? '');
    _iconKey = c?.iconKey ?? 'category';
    _color = c?.color ?? CategoryColors.palette.first;
    _isIncome = c?.isIncome ?? widget.isIncome;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final notifier = ref.read(categoriesProvider.notifier);
    final initial = widget.initial;
    if (initial != null) {
      await notifier.update(
          initial.copyWith(title: title, iconKey: _iconKey, color: _color));
    } else {
      await notifier.add(TxCategory(
        id: 'user-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        iconKey: _iconKey,
        color: _color,
        isIncome: _isIncome,
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initial != null;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEditing ? 'Изменить категорию' : 'Новая категория',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(CategoryIcons.resolve(_iconKey),
                      color: _color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _title,
                    autofocus: !isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Название',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!isEditing) ...[
              const SizedBox(height: 14),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Расход')),
                  ButtonSegment(value: true, label: Text('Доход')),
                ],
                selected: {_isIncome},
                onSelectionChanged: (s) =>
                    setState(() => _isIncome = s.first),
                showSelectedIcon: false,
              ),
            ],
            const SizedBox(height: 18),
            Text('Иконка',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in CategoryIcons.byKey.entries)
                  _PickTile(
                    selected: _iconKey == entry.key,
                    color: _color,
                    onTap: () => setState(() => _iconKey = entry.key),
                    child: Icon(
                      entry.value,
                      size: 21,
                      color: _iconKey == entry.key
                          ? _color
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Цвет',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in CategoryColors.palette)
                  _PickTile(
                    selected: _color == color,
                    color: color,
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _title.text.trim().isEmpty ? null : _save,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  textStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                child: Text(isEditing ? 'Сохранить' : 'Создать'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.selected,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? color.withValues(alpha: 0.16)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: selected
                ? Border.all(color: color, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../screens/update_flow.dart';
import '../state/providers.dart';

/// Постоянное напоминание о вышедшей версии. Снекбар при запуске легко
/// пропустить — он живёт десять секунд и показывается один раз за
/// сессию; баннер висит на дашборде, пока не обновишься или не скажешь
/// «позже» (тогда молчит до следующего релиза).
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(pendingUpdateProvider);
    if (info == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: context.l10n.updateBannerTitle(info.version),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.system_update_alt_rounded,
                color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.updateBannerTitle(info.version),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.updateBannerBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => runUpdateFlow(context, info),
                        child: Text(context.l10n.updateNow),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(updateServiceProvider)
                              .dismissVersion(info.version);
                          ref.read(dismissedUpdateProvider.notifier).state =
                              info.version;
                        },
                        child: Text(context.l10n.updateLater),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

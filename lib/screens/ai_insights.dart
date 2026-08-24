import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/ai_service.dart';
import '../data/insights.dart';
import '../state/providers.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService());

/// AI-аналитика: локальные инсайты + разбор от Claude по ключу
/// пользователя (ADR-0011).
class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  bool _configured = false;
  bool _running = false;
  String? _review;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(aiServiceProvider).configured.then((value) {
      if (mounted) setState(() => _configured = value);
    });
  }

  static String _providerName(AiProvider provider) => switch (provider) {
        AiProvider.anthropic => 'Claude (Anthropic)',
        AiProvider.cloudru => 'Cloud.ru',
        AiProvider.lmstudio => 'LM Studio (локально)',
        AiProvider.custom => 'OpenAI-compatible',
      };

  Future<void> _configureKey() async {
    final service = ref.read(aiServiceProvider);
    var provider = await service.provider;
    final endpointController =
        TextEditingController(text: await service.endpoint);
    final keyController = TextEditingController(text: await service.apiKey);
    final modelController = TextEditingController(text: await service.model);
    if (!mounted) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.aiSetKey),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownMenu<AiProvider>(
                  initialSelection: provider,
                  label: Text(context.l10n.aiProviderLabel),
                  expandedInsets: EdgeInsets.zero,
                  onSelected: (p) {
                    if (p == null) return;
                    setDialogState(() {
                      provider = p;
                      final defaults = aiProviderDefaults(p);
                      endpointController.text = defaults.endpoint;
                      modelController.text = defaults.model;
                    });
                  },
                  dropdownMenuEntries: [
                    for (final p in AiProvider.values)
                      DropdownMenuEntry(
                          value: p, label: _providerName(p)),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: endpointController,
                  decoration: InputDecoration(
                      labelText: context.l10n.aiEndpointLabel),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: keyController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: context.l10n.aiKeyGenericLabel),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: modelController,
                  decoration: InputDecoration(
                      labelText: context.l10n.aiModelLabel),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      await service.configure(
        provider: provider,
        endpoint: endpointController.text.trim(),
        key: keyController.text.trim(),
        model: modelController.text.trim(),
      );
      final ok = await service.configured;
      if (mounted) setState(() => _configured = ok);
    }
    endpointController.dispose();
    keyController.dispose();
    modelController.dispose();
  }

  Future<void> _run() async {
    // Явное согласие на отправку сводки (ADR-0011).
    final consent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.aiConsentTitle),
        content: Text(context.l10n.aiConsentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.aiSend),
          ),
        ],
      ),
    );
    if (consent != true || !mounted) return;

    setState(() {
      _running = true;
      _error = null;
    });
    try {
      final summary = AiService.buildSummary(
        transactions: ref.read(transactionsProvider),
        categories: ref.read(categoriesProvider),
        accounts: ref.read(accountsProvider),
        budgets: ref.read(budgetsProvider),
        now: DateTime.now(),
      );
      final languageCode =
          mounted ? Localizations.localeOf(context).languageCode : 'ru';
      final text = await ref.read(aiServiceProvider).review(
            summary: summary,
            languageCode: languageCode,
          );
      if (mounted) setState(() => _review = text);
    } on AiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insights = buildInsights(
      l10n: context.l10n,
      transactions: ref.watch(transactionsProvider),
      categories: ref.watch(categoriesProvider),
      budgets: ref.watch(budgetsProvider),
      now: DateTime.now(),
    );

    Color toneColor(InsightTone tone) => switch (tone) {
          InsightTone.good => NumoColors.mint,
          InsightTone.warn => NumoColors.amber,
          InsightTone.neutral => NumoColors.violet,
        };
    IconData toneIcon(InsightTone tone) => switch (tone) {
          InsightTone.good => Icons.trending_up_rounded,
          InsightTone.warn => Icons.priority_high_rounded,
          InsightTone.neutral => Icons.lightbulb_outline_rounded,
        };

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.menuAi)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(context.l10n.insightsTitle,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final insight in insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  dense: true,
                  leading: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color:
                          toneColor(insight.tone).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(toneIcon(insight.tone),
                        size: 18, color: toneColor(insight.tone)),
                  ),
                  title: Text(insight.text,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          const SizedBox(height: 18),
          Text(context.l10n.aiSectionTitle,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_review == null)
                    Text(
                      context.l10n.aiExplainer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.aiError(_error!),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ],
                  if (_review != null)
                    SelectableText(
                      _review!,
                      style:
                          theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _configured && !_running ? _run : null,
                        icon: _running
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.auto_awesome_rounded,
                                size: 18),
                        label: Text(context.l10n.aiRun),
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: _configureKey,
                        icon: const Icon(Icons.key_rounded, size: 18),
                        label: Text(context.l10n.aiSetKey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

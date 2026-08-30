import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/l10n.dart';
import 'data/startup.dart';
import 'core/theme.dart';
import 'core/ui_scale.dart';

import 'screens/lock.dart';
import 'screens/onboarding.dart';
import 'screens/sync_root.dart';
import 'state/providers.dart';
import 'screens/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  // Окно открывается сразу: подготовка хранилищ идёт уже под ним.
  // Раньше она шла до runApp, и любая заминка оставляла пользователя
  // с висящим процессом без единого окна.
  runApp(const NumoBootstrap());
}

/// Экран запуска: показывает приложение, когда хранилища готовы, и
/// объясняет, что случилось, если подготовка не удалась.
class NumoBootstrap extends StatefulWidget {
  const NumoBootstrap({super.key, this.startup});

  /// Подготовка приложения; тесты подставляют свою, чтобы проверить
  /// поведение при заминке и при ошибке, не трогая настоящую базу.
  final Startup? startup;

  @override
  State<NumoBootstrap> createState() => _NumoBootstrapState();
}

class _NumoBootstrapState extends State<NumoBootstrap> {
  late final Startup _startup = widget.startup ?? Startup();
  List<Override>? _overrides;
  StartupFailure? _failure;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    setState(() => _failure = null);
    try {
      final overrides = await _startup.run().timeout(Startup.timeout);
      _startup.writeLog();
      if (mounted) setState(() => _overrides = overrides);
    } catch (error) {
      _startup.writeLog(error: error);
      if (mounted) {
        setState(() => _failure =
            StartupFailure(step: _startup.currentStep, error: error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final overrides = _overrides;
    if (overrides != null) {
      return ProviderScope(overrides: overrides, child: const NumoApp());
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: NumoTheme.light(NumoColors.violet),
      darkTheme: NumoTheme.dark(NumoColors.violet),
      home: _failure == null
          ? const _StartupProgress()
          : _StartupFailureScreen(
              failure: _failure!,
              steps: _startup.steps,
              onRetry: _prepare,
            ),
    );
  }
}

class _StartupProgress extends StatelessWidget {
  const _StartupProgress();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
}

/// Подготовка не удалась: показываем, на каком шаге и почему —
/// вместо молчаливого окна или его отсутствия.
class _StartupFailureScreen extends StatelessWidget {
  const _StartupFailureScreen({
    required this.failure,
    required this.steps,
    required this.onRetry,
  });

  final StartupFailure failure;
  final List<String> steps;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 36, color: theme.colorScheme.error),
                const SizedBox(height: 14),
                Text('Numo не смог открыть данные',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Шаг: ${failure.step}. Данные никуда не делись — они '
                  'лежат отдельно от приложения. Попробуйте ещё раз, а '
                  'если не поможет, распакуйте свежую сборку заново.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    'пройдено: ${steps.join(' → ')}\n${failure.error}',
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// На desktop горизонтальные списки должны таскаться и мышью.
class _NumoScrollBehavior extends MaterialScrollBehavior {
  const _NumoScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class NumoApp extends ConsumerWidget {
  const NumoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(lockedProvider);
    final onboarded = ref.watch(onboardedProvider);
    final localeOverride = ref.watch(localeOverrideProvider);
    final themeOverride = ref.watch(themeOverrideProvider);
    final accentValue = ref.watch(accentColorProvider);
    final accent =
        accentValue == null ? NumoColors.violet : Color(accentValue);
    final uiScale = ref.watch(uiScaleProvider);
    return MaterialApp(
      title: 'Numo',
      scrollBehavior: const _NumoScrollBehavior(),
      // Масштаб интерфейса: см. UiScaler (lib/core/ui_scale.dart).
      builder: (context, child) =>
          UiScaler(scale: uiScale, child: child ?? const SizedBox()),
      debugShowCheckedModeBanner: false,
      theme: NumoTheme.light(accent),
      darkTheme: NumoTheme.dark(accent),
      themeMode: switch (themeOverride) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: localeOverride == null ? null : Locale(localeOverride),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: locked
          ? const LockScreen()
          : !onboarded
              ? const OnboardingScreen()
              : const SyncRoot(child: HomeShell()),
    );
  }
}

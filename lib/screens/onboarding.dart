import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../state/providers.dart';

const onboardedKey = 'numo.onboarded.v1';

/// Знакомство при первом запуске: три экрана о главном.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      icon: Icons.donut_small_rounded,
      title: 'Знай, куда уходят деньги',
      text: 'Быстрое добавление трат, наглядная структура расходов '
          'и аналитика по месяцам. Для начала уже добавлены '
          'демо-данные — их можно просто удалить.',
    ),
    (
      icon: Icons.track_changes_rounded,
      title: 'Планируй, а не вспоминай',
      text: 'Бюджеты по категориям с подсказкой «сколько можно тратить '
          'сегодня», регулярные платежи создаются сами, выписки из '
          'банка импортируются из CSV.',
    ),
    (
      icon: Icons.lock_rounded,
      title: 'Данные — только твои',
      text: 'Всё хранится на устройстве, без серверов и аккаунтов. '
          'PIN-код, бэкапы одним файлом и синхронизация через '
          'твоё собственное облако.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardedKey, true);
    ref.read(onboardedProvider.notifier).state = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextButton(
                      onPressed: _finish,
                      child: const Text('Пропустить'),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      final page = _pages[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: NumoColors.heroGradient,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: NumoColors.violetDeep
                                        .withValues(alpha: 0.35),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Icon(page.icon,
                                  color: Colors.white, size: 64),
                            ),
                            const SizedBox(height: 36),
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              page.text,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: i == _page ? 26 : 9,
                        height: 9,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: i == _page
                              ? NumoColors.violet
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.15),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: isLast
                          ? _finish
                          : () => _controller.nextPage(
                                duration:
                                    const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              ),
                      style: FilledButton.styleFrom(
                        backgroundColor: NumoColors.violet,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        textStyle: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      child: Text(isLast ? 'Начать' : 'Далее'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

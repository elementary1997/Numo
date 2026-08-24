import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../state/providers.dart';

/// Экран блокировки: PIN на входе в приложение.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _entered = '';
  bool _error = false;

  void _tap(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      _error = false;
      if (key == '⌫') {
        if (_entered.isNotEmpty) {
          _entered = _entered.substring(0, _entered.length - 1);
        }
        return;
      }
      if (_entered.length >= 6) return;
      _entered += key;
    });
    if (_entered.length >= 4 &&
        ref.read(securityRepositoryProvider).verify(_entered)) {
      ref.read(lockedProvider.notifier).state = false;
    } else if (_entered.length == 6) {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = true;
        _entered = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: NumoColors.heroGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text('Numo заблокирован',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    _error ? 'Неверный PIN, попробуйте ещё раз' : 'Введите PIN',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _error
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 6; i++)
                        Container(
                          width: 14,
                          height: 14,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _entered.length
                                ? NumoColors.violet
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.7,
                    children: [
                      for (final key in [
                        '1', '2', '3',
                        '4', '5', '6',
                        '7', '8', '9',
                        '', '0', '⌫',
                      ])
                        key.isEmpty
                            ? const SizedBox.shrink()
                            : Material(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _tap(key),
                                  child: Center(
                                    child: key == '⌫'
                                        ? Icon(Icons.backspace_outlined,
                                            size: 22,
                                            color: theme.colorScheme
                                                .onSurfaceVariant)
                                        : Text(
                                            key,
                                            style: theme
                                                .textTheme.titleLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                  ),
                                ),
                              ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

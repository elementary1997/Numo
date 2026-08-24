import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../core/theme.dart';
import '../state/providers.dart';
import '../core/l10n.dart';

/// Экран блокировки: PIN на входе в приложение.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _entered = '';
  bool _error = false;
  bool _biometricsAvailable = false;
  final _localAuth = LocalAuthentication();

  bool get _biometricsSupported =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows ||
          Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    final enabled =
        ref.read(securityRepositoryProvider).biometricsEnabled;
    if (_biometricsSupported && enabled) {
      _localAuth.isDeviceSupported().then((supported) async {
        final canCheck =
            supported && await _localAuth.canCheckBiometrics;
        if (!mounted) return;
        setState(() => _biometricsAvailable = canCheck);
        // Авто-попытка — после первого кадра: на macOS вызов до
        // появления окна молча проваливается.
        if (canCheck) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _tryBiometrics());
        }
      }).catchError((_) {});
    }
  }

  Future<void> _tryBiometrics() async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason:
            context.mounted ? context.l10n.biometricsReason : 'Numo',
        biometricOnly: true,
      );
      if (ok && mounted) {
        ref.read(lockedProvider.notifier).state = false;
      }
    } catch (_) {
      // Биометрия недоступна/отменена — остаётся PIN.
    }
  }

  void _tap(String key) {
    final security = ref.read(securityRepositoryProvider);
    final length = security.pinLength;
    HapticFeedback.selectionClick();
    setState(() {
      _error = false;
      if (key == '⌫') {
        if (_entered.isNotEmpty) {
          _entered = _entered.substring(0, _entered.length - 1);
        }
        return;
      }
      if (_entered.length >= length) return;
      _entered += key;
    });
    if (_entered.length == length) {
      if (security.verify(_entered)) {
        ref.read(lockedProvider.notifier).state = false;
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _error = true;
          _entered = '';
        });
      }
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
                      gradient: numoHeroGradient(theme.colorScheme.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(context.l10n.lockedTitle,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    _error ? context.l10n.wrongPinRetry : context.l10n.enterPin,
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
                      for (var i = 0;
                          i <
                              ref
                                  .read(securityRepositoryProvider)
                                  .pinLength;
                          i++)
                        Container(
                          width: 14,
                          height: 14,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _entered.length
                                ? theme.colorScheme.primary
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
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
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
                  if (_biometricsAvailable) ...[
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: _tryBiometrics,
                      icon: const Icon(Icons.fingerprint_rounded, size: 20),
                      label: Text(context.l10n.biometricsButton),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

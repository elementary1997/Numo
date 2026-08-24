import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

/// Короткий доступ к строкам: `context.l10n.totalBalance`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Код локали для intl-форматтеров дат.
  String get localeCode => Localizations.localeOf(this).toString();
}

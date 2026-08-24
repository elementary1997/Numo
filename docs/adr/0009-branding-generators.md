# 0009. Иконки и splash — через генераторы flutter_launcher_icons и flutter_native_splash

Дата: 2026-08-24
Статус: accepted

## Context

v1.0 требует фирменную иконку приложения и splash-экран на всех платформах. Вручную это ~30 файлов разных размеров и форматов (mipmap-плотности Android, AppIcon.appiconset iOS/macOS, ICO Windows, PWA-иконки) плюс нативные конфиги splash.

## Decision

Исходники бренда живут в `assets/branding/` (`icon.png` 1024², `splash.png` с прозрачными углами). Платформенные ассеты генерируются dev-зависимостями `flutter_launcher_icons` и `flutter_native_splash` (стандарт де-факто во Flutter-сообществе), конфигурация — в pubspec.yaml. Сгенерированные файлы коммитятся; при смене бренда правится исходник и перезапускаются генераторы:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Consequences

- Обе зависимости — dev-only, в рантайм приложения не попадают.
- Linux-иконку пакет не покрывает — она появится вместе с пакетированием для Linux (deb/flatpak), отдельной задачей.
- Splash в тёмной теме использует тёмный фон приложения (`#0E0D17`), в светлой — светлый.

# AGENTS.md — Numo

Инструкции для AI-агентов (Claude Code, Cursor, Copilot и др.). Единый источник правды; `CLAUDE.md` — symlink на этот файл.

## Project

Numo — кроссплатформенное приложение контроля трат и анализа личных финансов. Flutter, одна кодовая база на iOS / Android / macOS / Windows / Linux / Web. Язык интерфейса — русский, валюта — ₽, локаль `ru`.

## Dev environment

- Flutter stable (Dart SDK ≥ 3.9). На этой машине (WSL2) SDK лежит в `~/tools/flutter/bin` и добавлен в PATH через `~/.bashrc`.
- Никаких переменных окружения и секретов проект не требует.
- Быстрая проверка руками: `flutter run -d web-server --web-port 8377` и открыть `http://localhost:8377`; в WSL2 работает и `flutter run -d linux` (окно через WSLg).

## Build & test

```bash
make setup   # flutter pub get
make check   # analyze + test — ровно то, что гоняет CI
make test    # только тесты
make build   # web-сборка (smoke-check компиляции)
```

CI (`.github/workflows/ci.yml`) выполняет тот же `analyze + test + build web`. Релизы: тег `vX.Y.Z` → `release.yml` собирает desktop-артефакты (Linux/Windows/macOS) в GitHub Release.

YOU MUST: прогнать `make check` перед каждым коммитом; оба должны быть зелёными.

## Architecture overview

Подробнее — `docs/architecture.md`. Кратко, поток данных в один конец:

`TransactionsRepository` (JSON в shared_preferences) → Riverpod-провайдеры (`state/providers.dart`: список операций + производные `monthStatsProvider`, `balanceProvider`) → экраны (`screens/`) → переиспользуемые виджеты (`widgets/`).

- `lib/models/` — доменные типы (`Tx`, `TxCategory`). Сумма `Tx.amount` всегда положительная, знак определяет `TxType`; в баланс идёт `signedAmount`.
- `lib/data/repository.dart` — ЕДИНСТВЕННАЯ точка чтения/записи хранилища.
- `lib/widgets/charts.dart` — все графики рисуются собственными `CustomPainter`.
- `lib/core/` — тема (`NumoColors`, `NumoTheme`) и форматирование денег.

## Conventions

- Императивно: НЕ ходить в shared_preferences напрямую из UI или провайдеров — только через `TransactionsRepository`.
- НЕ добавлять чартовые библиотеки (fl_chart и т.п.) — графики пишем CustomPainter'ами в `lib/widgets/charts.dart`.
- НЕ создавать сумму со знаком минус — расход выражается `TxType.expense`.
- Цвета и градиенты — только из `NumoColors`; произвольные `Color(0x...)` в экранах не заводить.
- Все пользовательские строки — по-русски, с корректной типографикой («ёлочки», длинное тире, знак «−» для минуса в суммах).
- Деньги форматировать только через `lib/core/money.dart`, даты — `intl` с локалью `'ru'`.
- Новые зависимости — только с обоснованием в ADR (`docs/adr/`).
- Стиль кода: `flutter_lints` (см. `analysis_options.yaml`), никакого `dynamic` без причины.

## Git workflow

- Ветка `main`, коммиты в стиле Conventional Commits, сообщения на английском (`feat: ...`, `fix: ...`).
- Описание изменений в PR — на русском.

## Security

- Секретов в репо нет и быть не должно. Приложение полностью офлайн, данные пользователя живут локально (shared_preferences).
- НЕ добавлять сетевые вызовы и аналитику без явного решения в ADR.

## Gotchas

- **Ключ хранилища версионирован**: `numo.transactions.v1` в `repository.dart`. Меняешь схему JSON — поднимай версию и пиши миграцию, иначе у пользователя молча пропадут данные.
- **Демо-данные**: при первом запуске репозиторий сидируется демо-операциями (`_demoData()`, флаг `numo.seeded.v1`). В тестах и при отладке хранилища это может удивить.
- **`intl: any` в pubspec** — намеренно: точную версию диктует `flutter_localizations`. Не пиновать.
- **google_fonts качает Manrope в рантайме** — без сети приложение падает на системный шрифт; это ожидаемо, не «баг».
- **`initializeDateFormatting('ru')` обязателен до `runApp`** — иначе `DateFormat(..., 'ru')` бросает исключение.
- **Web-сборка кэшируется браузером** — после пересборки смотреть через Ctrl+F5.
- Переименование продукта в `Numo` затрагивает нативные раннеры (linux/windows/macos) — macOS-бандл называется `Numo.app`, это захардкожено в `release.yml`.

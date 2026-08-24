# Архитектура Numo

Однонаправленный поток данных: хранилище → состояние → UI. Никаких обходных путей — UI никогда не пишет в хранилище напрямую.

```mermaid
flowchart TB
    subgraph storage["Хранилище"]
        SP[("shared_preferences\nJSON, ключ numo.transactions.v1")]
    end

    subgraph data["lib/data"]
        REPO["TransactionsRepository\nloadAll / saveAll / сидирование демо"]
    end

    subgraph state["lib/state — Riverpod"]
        TXS["transactionsProvider\nсписок операций"]
        STATS["monthStatsProvider(month)\nдоходы, расходы, по категориям, по дням"]
        BAL["balanceProvider\nобщий баланс"]
    end

    subgraph ui["lib/screens + lib/widgets"]
        DASH["Обзор"]
        LIST["Операции"]
        AN["Аналитика"]
        ADD["Добавление (bottom sheet)"]
        CHARTS["charts.dart\nDonut / Sparkline / Bars\n(CustomPainter)"]
    end

    SP <--> REPO
    REPO --> TXS
    TXS --> STATS & BAL
    STATS --> DASH & AN
    BAL --> DASH
    TXS --> LIST
    ADD -- "add()/remove()" --> TXS
    DASH & AN --- CHARTS
```

## Слои

| Слой | Код | Ответственность |
|---|---|---|
| Модели | `lib/models/` | `Tx` (операция: тип, положительная сумма, категория, дата, заметка), `TxCategory` (фиксированный набор в `Categories`) |
| Данные | `lib/data/repository.dart` | Сериализация JSON ↔ `Tx`, единственная точка I/O, демо-сидирование первого запуска |
| Состояние | `lib/state/providers.dart` | `TransactionsNotifier` (add/remove с записью в репозиторий), производная аналитика месяца |
| UI | `lib/screens/`, `lib/widgets/` | Экраны без бизнес-логики; графики — собственные `CustomPainter` |
| Ядро | `lib/core/` | Тема (`NumoColors`, `NumoTheme`), форматирование денег |

## Ключевые инварианты

1. `Tx.amount > 0` всегда; знак несёт `TxType` (`signedAmount` — единственное место, где появляется минус).
2. Схема хранения версионируется ключом (`...v1`); изменение формата = новый ключ + миграция.
3. Провайдеры пересчитывают статистику из полного списка операций — кэшей, требующих инвалидации, нет.

## Осознанные упрощения MVP (см. ADR)

- Хранилище — JSON в shared_preferences, а не SQLite: объёмы данных малы, интерфейс репозитория позволяет мигрировать на drift без изменения UI (ADR-0003).
- Категории фиксированы в коде; пользовательские категории потребуют вынести их в хранилище.
- Один счёт, одна валюта (₽).

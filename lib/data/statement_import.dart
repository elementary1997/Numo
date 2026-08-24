import '../models/category_rule.dart';
import '../models/transaction.dart';
import 'csv.dart';

/// Назначение колонок CSV-файла полям операции.
class ColumnMapping {
  const ColumnMapping({
    required this.dateColumn,
    required this.amountColumn,
    this.noteColumn,
    this.unsignedIsExpense = false,
  });

  final int dateColumn;
  final int amountColumn;
  final int? noteColumn;

  /// Если в выписке все суммы без знака — считать их расходами.
  final bool unsignedIsExpense;
}

/// Строка предпросмотра импорта.
class ParsedRow {
  const ParsedRow({
    required this.source,
    this.tx,
    this.duplicate = false,
  });

  final List<String> source;
  final Tx? tx;

  /// Уже есть такая операция (по детерминированному id импорта).
  final bool duplicate;

  bool get importable => tx != null && !duplicate;
}

/// Превращает разобранный CSV в операции. Детерминированный id по
/// содержимому строки даёт дедупликацию: повторный импорт того же
/// файла не создаёт дублей.
abstract final class StatementImporter {
  /// Пытается угадать колонки по заголовку; null — не заголовок.
  static ColumnMapping? guessMapping(List<String> header) {
    int? date;
    int? amount;
    int? note;
    for (var i = 0; i < header.length; i++) {
      final h = header[i].toLowerCase();
      if (date == null && (h.contains('дат') || h.contains('date'))) {
        date = i;
      }
      if (amount == null &&
          (h.contains('сумм') || h.contains('amount') || h == 'value')) {
        amount = i;
      }
      if (note == null &&
          (h.contains('опис') ||
              h.contains('назнач') ||
              h.contains('description') ||
              h.contains('merchant') ||
              h.contains('категор'))) {
        note = i;
      }
    }
    if (date == null || amount == null) return null;
    return ColumnMapping(
        dateColumn: date, amountColumn: amount, noteColumn: note);
  }

  /// Есть ли в первой строке заголовок (дата в ней не парсится).
  static bool hasHeader(List<List<String>> rows, ColumnMapping mapping) {
    if (rows.isEmpty) return false;
    final first = rows.first;
    if (mapping.dateColumn >= first.length) return true;
    return parseStatementDate(first[mapping.dateColumn]) == null;
  }

  static List<ParsedRow> parseRows({
    required List<List<String>> rows,
    required ColumnMapping mapping,
    required String accountId,
    required List<CategoryRule> rules,
    required Set<String> existingIds,
    bool skipFirstRow = false,
  }) {
    final result = <ParsedRow>[];
    final seenInFile = <String>{};
    for (var i = skipFirstRow ? 1 : 0; i < rows.length; i++) {
      final row = rows[i];
      String cell(int? column) =>
          column != null && column < row.length ? row[column].trim() : '';

      final date = parseStatementDate(cell(mapping.dateColumn));
      final rawAmount = parseStatementAmount(cell(mapping.amountColumn));
      if (date == null || rawAmount == null || rawAmount == 0) {
        result.add(ParsedRow(source: row));
        continue;
      }

      final note = cell(mapping.noteColumn);
      final isExpense =
          rawAmount < 0 || (mapping.unsignedIsExpense && rawAmount > 0);
      final amount = rawAmount.abs();
      final categoryId = categorizeByRules(note, rules) ?? 'other';
      final id = 'imp-${_fnv1a('$accountId|$date|$rawAmount|$note')}';

      final tx = Tx(
        id: id,
        type: isExpense ? TxType.expense : TxType.income,
        amount: amount,
        categoryId: categoryId,
        date: date,
        accountId: accountId,
        note: note,
      );
      final duplicate =
          existingIds.contains(id) || !seenInFile.add(id);
      result.add(ParsedRow(source: row, tx: tx, duplicate: duplicate));
    }
    return result;
  }

  /// FNV-1a: детерминированный короткий хэш содержимого строки.
  static int _fnv1a(String input) {
    var hash = 0x811c9dc5;
    for (final code in input.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}

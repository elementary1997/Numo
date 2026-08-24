/// Минимальный CSV без внешних зависимостей: разбор с кавычками,
/// автоопределение разделителя (`;` частая практика русских банков,
/// `,` — международная) и запись с экранированием.
abstract final class Csv {
  /// Определяет разделитель по первой строке: побеждает тот,
  /// которого больше вне кавычек.
  static String detectDelimiter(String firstLine) {
    var semicolons = 0;
    var commas = 0;
    var tabs = 0;
    var inQuotes = false;
    for (final char in firstLine.split('')) {
      if (char == '"') inQuotes = !inQuotes;
      if (inQuotes) continue;
      if (char == ';') semicolons++;
      if (char == ',') commas++;
      if (char == '\t') tabs++;
    }
    if (tabs >= semicolons && tabs >= commas && tabs > 0) return '\t';
    return semicolons >= commas ? ';' : ',';
  }

  /// Разбирает CSV-текст в строки-списки ячеек. Пустые строки
  /// пропускаются; кавычки и переводы строк внутри кавычек — по RFC 4180.
  static List<List<String>> parse(String text, {String? delimiter}) {
    final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (normalized.trim().isEmpty) return const [];
    final delim = delimiter ??
        detectDelimiter(normalized.split('\n').first);

    final rows = <List<String>>[];
    var row = <String>[];
    final cell = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < normalized.length; i++) {
      final char = normalized[i];
      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < normalized.length && normalized[i + 1] == '"') {
            cell.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          cell.write(char);
        }
      } else if (char == '"') {
        inQuotes = true;
      } else if (char == delim) {
        row.add(cell.toString());
        cell.clear();
      } else if (char == '\n') {
        row.add(cell.toString());
        cell.clear();
        if (row.any((c) => c.trim().isNotEmpty)) rows.add(row);
        row = <String>[];
      } else {
        cell.write(char);
      }
    }
    row.add(cell.toString());
    if (row.any((c) => c.trim().isNotEmpty)) rows.add(row);
    return rows;
  }

  /// Собирает CSV-текст (разделитель `;`, кавычки по необходимости) —
  /// такой файл корректно открывает русский Excel.
  static String write(List<List<Object?>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escape).join(';'));
    }
    return buffer.toString();
  }

  static String _escape(Object? value) {
    final s = value?.toString() ?? '';
    if (s.contains(';') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}

/// Разбор дат банковских выписок: ISO, dd.MM.yyyy, dd/MM/yyyy,
/// с необязательным временем.
DateTime? parseStatementDate(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final iso = DateTime.tryParse(s);
  if (iso != null) return iso;
  // Серийная дата Excel (дней с 30.12.1899) — так xlsx хранит даты.
  final serial = double.tryParse(s);
  if (serial != null && serial > 20000 && serial < 80000) {
    return DateTime(1899, 12, 30)
        .add(Duration(milliseconds: (serial * 86400000).round()));
  }
  final match = RegExp(
          r'^(\d{1,2})[./](\d{1,2})[./](\d{2,4})(?:[ T](\d{1,2}):(\d{2}))?')
      .firstMatch(s);
  if (match == null) return null;
  var year = int.parse(match.group(3)!);
  if (year < 100) year += 2000;
  return DateTime(
    year,
    int.parse(match.group(2)!),
    int.parse(match.group(1)!),
    int.parse(match.group(4) ?? '0'),
    int.parse(match.group(5) ?? '0'),
  );
}

/// Разбор сумм выписок: «1 234,56», «-1234.56», «1 234,56 ₽».
double? parseStatementAmount(String raw) {
  var s = raw
      .replaceAll(' ', '')
      .replaceAll(' ', '')
      .replaceAll(RegExp(r'[₽$€₸]|RUB|USD|EUR', caseSensitive: false), '')
      .trim();
  if (s.isEmpty) return null;
  // Если есть и точка и запятая — последняя из них десятичный знак.
  if (s.contains('.') && s.contains(',')) {
    if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else {
      s = s.replaceAll(',', '');
    }
  } else {
    s = s.replaceAll(',', '.');
  }
  return double.tryParse(s);
}

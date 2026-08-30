import 'dart:convert';
import 'dart:ui' show Color;

import '../core/theme.dart';

/// Участник общих счетов (ADR-0014): человек, с которым ведётся общий
/// бюджет. Ровно один участник помечен [isMe] — это владелец устройства,
/// его идентификатор попадает в поле автора операций.
class Member {
  const Member({
    required this.id,
    required this.name,
    required this.color,
    this.isMe = false,
  });

  final String id;
  final String name;
  final Color color;
  final bool isMe;

  /// Инициал для аватара — первая буква имени.
  String get initial => name.isEmpty ? '?' : name.substring(0, 1);

  /// Код приглашения: строка, которую человек передаёт близкому любым
  /// способом (мессенджер, вслух, бумажка). В ней только визитка —
  /// идентификатор, имя и цвет; доступ к данным даёт не она, а общая
  /// папка в облаке (ADR-0014).
  String get inviteCode {
    final payload = base64Url.encode(utf8.encode(jsonEncode({
      'i': id,
      'n': name,
      'c': color.toARGB32(),
    })));
    return '$invitePrefix${payload.replaceAll('=', '')}';
  }

  static const invitePrefix = 'numo1:';

  /// Разбирает код приглашения; null — это не код Numo или он побит.
  /// Пробелы и переносы строк по краям прощаются: код часто прилетает
  /// из мессенджера вместе с ними.
  static Member? fromInviteCode(String raw) {
    final trimmed = raw.trim();
    final lower = trimmed.toLowerCase();
    if (!lower.startsWith(invitePrefix)) return null;
    var payload = trimmed.substring(invitePrefix.length).trim();
    // base64url без выравнивания — дополняем сами.
    payload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
    try {
      final json =
          jsonDecode(utf8.decode(base64Url.decode(payload))) as Map;
      final id = json['i'] as String?;
      final name = json['n'] as String?;
      if (id == null || id.isEmpty || name == null || name.isEmpty) {
        return null;
      }
      return Member(
        id: id,
        name: name,
        color: Color((json['c'] as num?)?.toInt() ??
            NumoColors.violet.toARGB32()),
      );
    } catch (_) {
      return null;
    }
  }

  Member copyWith({String? name, Color? color, bool? isMe}) => Member(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
        isMe: isMe ?? this.isMe,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
        'isMe': isMe,
      };

  /// Разбор участника из файла обмена. Флаг «это я» не переносится:
  /// на чужом устройстве этот человек — просто участник.
  factory Member.fromJson(Map<String, dynamic> json, {bool isMe = false}) =>
      Member(
        id: json['id'] as String,
        name: json['name'] as String,
        color: Color((json['color'] as num?)?.toInt() ??
            NumoColors.violet.toARGB32()),
        isMe: isMe,
      );
}

extension MemberLookup on List<Member> {
  /// Участник по id; для незнакомого id — заглушка с самим id в имени,
  /// чтобы операция из чужого файла не осталась без подписи.
  Member? tryById(String? id) {
    if (id == null) return null;
    for (final m in this) {
      if (m.id == id) return m;
    }
    return null;
  }

  Member? get me {
    for (final m in this) {
      if (m.isMe) return m;
    }
    return null;
  }
}

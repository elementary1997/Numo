import 'dart:ui' show Color;

import '../core/theme.dart';

/// Участник общих счетов (ADR-0013): человек, с которым ведётся общий
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

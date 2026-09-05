/// An in-app notification shown to the user.
///
/// These are stored locally (no cost) and rendered in the in-app
/// notification center. They also drive local device notifications.
class AppNotification {
  final String id;
  final String type; // 'revision' | 'streak' | 'practice' | 'learning_path' | 'recommendation' | 'system'
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      type: map['type'] ?? 'system',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      read: map['read'] ?? false,
    );
  }

  String get icon {
    switch (type) {
      case 'revision':
        return '🔁';
      case 'streak':
        return '🔥';
      case 'practice':
        return '✍️';
      case 'learning_path':
        return '🗺️';
      case 'recommendation':
        return '🎯';
      default:
        return '🔔';
    }
  }
}

import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';

part 'notification_model.g.dart';

@HiveType(typeId: HiveTypeIds.notificationModel)
class NotificationModel extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String title;
  @HiveField(2)
  late String body;
  @HiveField(3)
  late String status;
  @HiveField(5)
  late DateTime createdAt;
  @HiveField(6)
  String? imageUrl;
  @HiveField(7)
  String? actionUrl;
  @HiveField(8)
  late String channel;
  @HiveField(9)
  late bool read;

  bool get isRead => read;
  bool get isUnread => !read;

  NotificationModel();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel()
      ..id = json['id']?.toString() ?? ''
      ..title = json['title'] as String? ?? ''
      ..body = json['body'] as String? ?? ''
      ..status = json['status'] as String? ?? 'sent'
      ..channel = json['channel'] as String? ?? 'push'
      ..createdAt =
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now()
      ..imageUrl = json['image_url'] as String?
      ..actionUrl = json['actionUrl'] as String?
      ..read = json['read'] as bool? ?? false;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'status': status,
    'channel': channel,
    'createdAt': createdAt.toIso8601String(),
    'image_url': imageUrl,
    'actionUrl': actionUrl,
    'read': read,
  };
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? status,
    String? channel,
    DateTime? createdAt,
    String? imageUrl,
    String? actionUrl,
    bool? read,
  }) {
    return NotificationModel()
      ..id = id ?? this.id
      ..title = title ?? this.title
      ..body = body ?? this.body
      ..status = status ?? this.status
      ..channel = channel ?? this.channel
      ..createdAt = createdAt ?? this.createdAt
      ..imageUrl = imageUrl ?? this.imageUrl
      ..actionUrl = actionUrl ?? this.actionUrl
      ..read = read ?? this.read;
  }

  @override
  String toString() =>
      'NotificationModel(id: $id, title: $title, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

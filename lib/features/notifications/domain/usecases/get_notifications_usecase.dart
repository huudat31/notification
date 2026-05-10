import 'package:notification/data/models/notification_model.dart';
import 'package:notification/data/repositories/notification_repository.dart';

import '../../../../core/constants/api_constants.dart';

class GetNotificationsResult {
  final List<NotificationModel> notifications;
  final String? nextCursor;
  final bool hasMore;

  const GetNotificationsResult({
    required this.notifications,
    required this.nextCursor,
    required this.hasMore,
  });
}

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  List<NotificationModel> getCached() => _repository.getCached();

  Future<GetNotificationsResult> execute({
    required List<NotificationModel> existing,
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    final page = await _repository.getNotifications(
      cursor: cursor,
      limit: limit,
    );

    final existingIds = {for (final n in existing) n.id};

    final newItems = page.items
        .where((n) => !existingIds.contains(n.id))
        .toList();

    final merged = cursor == null ? page.items : [...existing, ...newItems];

    return GetNotificationsResult(
      notifications: merged,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }
}

import 'package:get/get.dart';
import 'package:notification/features/notifications/presentation/bindings/notification_binding.dart';
import 'package:notification/features/notifications/presentation/views/notification_list_view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => NotificationListView(),
      binding: NotificationBinding(),
    ),
  ];
}

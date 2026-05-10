import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:notification/core/di/app_initializer.dart';
import 'package:notification/core/di/dependency_injection.dart';
import 'package:notification/core/controllers/settings_controller.dart';
import 'package:notification/core/localization/app_translations.dart';
import 'package:notification/core/theme/app_theme.dart';
import 'package:notification/features/auth/presentation/controllers/auth_controller.dart';
import 'package:notification/features/auth/presentation/middlewares/auth_middleware.dart';
import 'package:notification/features/auth/presentation/views/auth_views.dart';
import 'package:notification/features/notifications/presentation/bindings/notification_binding.dart';
import 'package:notification/features/notifications/presentation/views/notification_detail_view.dart';
import 'package:notification/features/notifications/presentation/views/notification_list_view.dart';
import 'package:notification/features/settings/presentation/settings_view.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    DependencyInjection.initCore();
    await AppInitializer.init();

    final authController = Get.find<AuthController>();
    final initialRoute = authController.state.value.isAuthenticated
        ? '/notifications'
        : '/login';

    runApp(MyApp(initialRoute: initialRoute));
  } catch (e) {
    debugPrint('Initialization error: $e');
    // Fallback to login if initialization fails
    runApp(const MyApp(initialRoute: '/login'));
  }
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<AuthController>().onAppResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.to;

    return GetMaterialApp(
      title: 'Auto Login App',
      debugShowCheckedModeBanner: false,

      translations: AppTranslations(),
      locale: settings.locale,
      fallbackLocale: const Locale('vi', 'VN'),

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,

      initialRoute: widget.initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(
          name: '/notifications',
          page: () => const NotificationListView(),
          binding: NotificationBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/notification-detail',
          page: () => const NotificationDetailView(),
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsView(),
          binding: NotificationBinding(),
          middlewares: [AuthMiddleware()],
        ),
      ],
    );
  }
}

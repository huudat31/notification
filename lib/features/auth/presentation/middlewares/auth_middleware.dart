import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:notification/features/auth/presentation/controllers/auth_controller.dart';
import 'package:notification/features/auth/presentation/controllers/auth_state.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authState = Get.find<AuthController>().state.value;

    if (authState is Bootstrapping) return null;

    if (authState is Unauthenticated && route != '/login') {
      return const RouteSettings(name: '/login');
    }

    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification/data/models/notification_model.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/constants/ui_constants.dart';

class NotificationDetailView extends StatelessWidget {
  const NotificationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final NotificationModel? notification = Get.arguments as NotificationModel?;

    if (notification == null) {
      return Scaffold(
        appBar: AppBar(title: Text('notification_detail'.tr)),
        body: Center(child: Text('not_found'.tr)),
      );
    }

    final timeString = DateFormatter.formatDateTime(notification.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'notification_detail'.tr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: UiConstants.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: UiConstants.paddingLg),

            if (notification.imageUrl != null &&
                notification.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: UiConstants.paddingLg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    UiConstants.borderRadiusLg,
                  ),
                  child: Image.network(
                    notification.imageUrl!,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            Text(
              notification.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: UiConstants.paddingSm),

            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 6),
                Text(
                  timeString,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: UiConstants.paddingLg),

            Container(
              height: 1,
              width: double.infinity,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),

            const SizedBox(height: UiConstants.paddingLg),

            Text(
              notification.body,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.8,
                color: colorScheme.onSurface.withValues(alpha: 0.85),
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

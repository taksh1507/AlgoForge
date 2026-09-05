import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../utils/helpers.dart';
import '../providers/notification_provider.dart';
import '../models/app_notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTextStyles.heading3(),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.feed.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Mark all read',
                icon: Icon(Icons.done_all, color: palette.accent),
                onPressed: provider.markAllRead,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            final feed = provider.feed;
            if (feed.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none,
                        color: palette.line, size: 56),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No notifications yet',
                      style: AppTextStyles.label(color: palette.faint),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your reminders will appear here',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: feed.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final notification = feed[index];
                return _NotificationTile(notification: notification);
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: () =>
          context.read<NotificationProvider>().markRead(notification.id),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.read ? palette.bg : palette.accentSoft,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: notification.read ? palette.line : palette.accent,
            width: notification.read ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.icon,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.label(
                      color: notification.read
                          ? palette.muted
                          : palette.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodySmall(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeAgo(notification.createdAt),
                    style: AppTextStyles.labelTiny(color: palette.faint),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

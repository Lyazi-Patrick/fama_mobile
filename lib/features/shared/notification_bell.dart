import 'package:flutter/material.dart';
import '../../core/theme/fama_theme.dart';

/// Shared top-right bell icon, matching every Stitch screen's header.
/// Currently opens a placeholder list -- FAMA doesn't have a user-facing
/// notifications API yet (AdminNotification.php on the web is admin-only).
/// Swap NotificationsScreen's body for a real feed once that endpoint exists.
class NotificationBellAction extends StatelessWidget {
  const NotificationBellAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_none_outlined),
      tooltip: 'Notifications',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_none_outlined, size: 56, color: FamaColors.outline),
              const SizedBox(height: 16),
              Text('No notifications yet', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                "You'll see updates about your requests and orders here.",
                textAlign: TextAlign.center,
                style: TextStyle(color: FamaColors.onBackground.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

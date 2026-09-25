import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String mobile;

  const NotificationsScreen({super.key, required this.mobile});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<AppNotification>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = ApiService.getNotifications(widget.mobile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<AppNotification>>(
        future: notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return const Center(child: Text('Unable to load notifications'));
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No notifications'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(item.title),
                  subtitle: Text(item.message),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

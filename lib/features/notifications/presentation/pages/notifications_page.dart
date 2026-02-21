import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bildirishnomalar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Primary'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NotificationList(type: 'general'),
            _NotificationList(type: 'primary'),
          ],
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(title: Text('$type — bildirishnomalar')),
      ],
    );
  }
}

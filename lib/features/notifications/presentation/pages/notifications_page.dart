import 'package:flutter/material.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.notifications),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.general),
              Tab(text: l10n.primary),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _NotificationList(title: l10n.notificationsList(l10n.general)),
            _NotificationList(title: l10n.notificationsList(l10n.primary)),
          ],
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [ListTile(title: Text(title))],
    );
  }
}

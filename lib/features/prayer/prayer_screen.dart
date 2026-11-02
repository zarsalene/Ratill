import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'notifications_screen.dart';
import 'qibla_tab.dart';
import 'tasbih_tab.dart';
import 'times_tab.dart';

/// The Prayer tab: prayer times with the Adhan, the Qibla, and the tasbih.
class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.navPrayer),
          actions: [
            IconButton(
              tooltip: t.notifyTitle,
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const NotificationsScreen())),
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(text: t.prayerTabTimes),
            Tab(text: t.prayerTabQibla),
            Tab(text: t.prayerTabTasbih),
          ]),
        ),
        body: const TabBarView(children: [TimesTab(), QiblaTab(), TasbihTab()]),
      ),
    );
  }
}

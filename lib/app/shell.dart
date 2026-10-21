import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation with four destinations. Each tab keeps its own
/// navigation and scroll state.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Hari ini'),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Riwayat',
          ),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Ringkasan'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}

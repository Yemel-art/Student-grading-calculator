// lib/views/app_shell.dart
// Root scaffold: NavigationRail on the left, content on the right.
// Hosts Home, Vault, and Settings views.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import 'home_view.dart';
import 'vault_view.dart';
import 'settings_view.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = NavIndex.home;

  static const _destinations = [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.archive_outlined),
      selectedIcon: Icon(Icons.archive),
      label: Text('Vault'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // ---- Navigation Rail ----
          _buildNavigationRail(context, colorScheme),

          // Divider
          VerticalDivider(thickness: 1, width: 1, color: Colors.grey.shade200),

          // ---- Content Area ----
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, ColorScheme colorScheme) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      extended: true,
      destinations: _destinations,
      leading: _buildRailHeader(context),
      trailing: _buildRailFooter(context),
      labelType: NavigationRailLabelType.none,
    );
  }

  Widget _buildRailHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grading',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Calculator',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRailFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 8),
      child: Consumer<SettingsController>(
        builder: (_, settings, __) => Row(
          children: [
            const Icon(Icons.light_mode, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Switch(
              value: settings.isDarkMode,
              onChanged: (_) => settings.toggleDarkMode(),
              activeColor: AppColors.thickOrange,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.dark_mode, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case NavIndex.home:
        return const HomeView();
      case NavIndex.vault:
        return const VaultView();
      case NavIndex.settings:
        return const SettingsView();
      default:
        return const HomeView();
    }
  }
}

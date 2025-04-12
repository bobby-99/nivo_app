import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nivo_app/providers/theme_provider.dart';
import 'package:nivo_app/widgets/app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSection(context, themeState, themeNotifier),
          const SizedBox(height: 16),
          _buildAppInfoSection(context),
          const SizedBox(height: 16),
          _buildStorageSection(context),
        ],
      ),
    );
  }

  Widget _buildThemeSection(
      BuildContext context, ThemeState state, ThemeNotifier notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dark Mode'),
                Switch(
                  value: state.isDarkMode,
                  onChanged: (_) => notifier.toggleTheme(),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Accent Color',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColorChoice(
                  context,
                  color: const Color(0xFF7E57C2),
                  isSelected: state.accentColor == AppAccentColor.purple,
                  onTap: () => notifier.setAccentColor(AppAccentColor.purple),
                ),
                _buildColorChoice(
                  context,
                  color: const Color(0xFF42A5F5),
                  isSelected: state.accentColor == AppAccentColor.blue,
                  onTap: () => notifier.setAccentColor(AppAccentColor.blue),
                ),
                _buildColorChoice(
                  context,
                  color: const Color(0xFF66BB6A),
                  isSelected: state.accentColor == AppAccentColor.green,
                  onTap: () => notifier.setAccentColor(AppAccentColor.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Enable Notifications'),
                Switch(
                  value: state.notificationsEnabled,
                  onChanged: (value) => notifier.toggleNotifications(value),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChoice(
    BuildContext context, {
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Info',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Nivō'),
              subtitle: const Text('Version 0.1.0'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Developer'),
              subtitle: const Text('YourName'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Description'),
              subtitle: const Text(
                'Minimal & aesthetic productivity tracker combining Tasks, Habits, and Pomodoro focus.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'All data is stored locally on your device using Hive for offline access and privacy.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () => _showClearDataDialog(context),
                child: const Text('Clear All Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Data?'),
          content: const Text(
            'This will permanently delete all your tasks, habits, and timer sessions. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _clearAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been cleared')),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllData() async {
    final boxes = await Hive.openBox('tasks');
    await boxes.clear();
    final habitsBox = await Hive.openBox('habits');
    await habitsBox.clear();
    final pomodoroBox = await Hive.openBox('pomodoro_sessions');
    await pomodoroBox.clear();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nivo_app/models/habit.dart';
import 'package:nivo_app/models/pomodoro_session.dart';
import 'package:nivo_app/models/task.dart';
import 'package:nivo_app/providers/navigation_provider.dart';
import 'package:nivo_app/providers/theme_provider.dart';
import 'package:nivo_app/screens/habits/habits_screen.dart';
import 'package:nivo_app/screens/settings/settings_screen.dart';
import 'package:nivo_app/screens/tasks/tasks_screen.dart';
import 'package:nivo_app/screens/timer/pomodoro_screen.dart';
import 'package:nivo_app/theme/app_theme.dart';
import 'package:nivo_app/widgets/app_bar.dart';
import 'package:nivo_app/widgets/custom_bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitFrequencyAdapter());
  Hive.registerAdapter(PomodoroSessionAdapter());
  Hive.registerAdapter(SessionTypeAdapter());
  runApp(const ProviderScope(child: NivoApp()));
}

class NivoApp extends ConsumerWidget {
  const NivoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    
    return AnimatedTheme(
      data: theme,
      duration: const Duration(milliseconds: 300),
      child: MaterialApp(
        title: 'Nivō',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const MainWrapper(),
      ),
    );
  }
}

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final pageTitles = ['Tasks', 'Habits', 'Timer'];

    return Scaffold(
      appBar: CustomAppBar(
        title: pageTitles[currentIndex],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                      const SettingsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransitionSwitcher(
        child: IndexedStack(
          key: ValueKey<int>(currentIndex), // Important for animations
          index: currentIndex,
          children: const [
            TasksScreen(),
            HabitsScreen(),
            PomodoroScreen(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
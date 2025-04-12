// Updated main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nivo_app/providers/task_provider.dart';
import 'package:nivo_app/providers/habit_provider.dart';
import 'package:nivo_app/providers/theme_provider.dart';
import 'package:nivo_app/screens/tasks/tasks_screen.dart';
import 'package:nivo_app/screens/habits/habits_screen.dart';
import 'package:nivo_app/screens/timer/pomodoro_screen.dart';
import 'package:nivo_app/screens/timer/flip_clock_screen.dart';
import 'package:nivo_app/screens/settings/settings_screen.dart';
import 'package:nivo_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: const NivoApp(),
    ),
  );
}

class NivoApp extends StatefulWidget {
  const NivoApp({Key? key}) : super(key: key);

  @override
  State<NivoApp> createState() => _NivoAppState();
}

class _NivoAppState extends State<NivoApp> {
  @override
  void initState() {
    super.initState();
    // Load data when app starts
    Future.delayed(Duration.zero, () {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      Provider.of<HabitProvider>(context, listen: false).loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Nivo',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          home: const HomeScreen(),
          routes: {
            '/settings': (context) => const SettingsScreen(),
            '/flip_clock': (context) => const FlipClockScreen(),
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Default to Tasks screen (center)
  
  final List<Widget> _screens = [
    const HabitsScreen(),
    const TasksScreen(),
    const PomodoroScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
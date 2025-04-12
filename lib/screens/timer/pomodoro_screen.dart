import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivo_app/providers/pomodoro_provider.dart';
import 'package:nivo_app/widgets/app_bar.dart';
import 'package:nivo_app/widgets/pomodoro_controls.dart';
import 'package:nivo_app/models/pomodoro_session.dart';

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for completed sessions
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    // Animate progress when time changes
    _progressController.reset();
    _progressController.forward();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Focus Timer'),
      body: Column(
        children: [
          const SizedBox(height: 32),
          _buildTimerDisplay(context, state),
          const SizedBox(height: 32),
          const PomodoroControls(),
          const SizedBox(height: 32),
          _buildStatsSection(context, notifier),
          const SizedBox(height: 16),
          _buildSessionHistory(context, state),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, PomodoroState state) {
    final minutes = state.remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = (state.remainingTime.inSeconds.remainder(60)).toString().padLeft(2, '0');
    final isCompleted = state.remainingTime.inSeconds == 0;
    final sessionType = state.currentSessionType;

    return ScaleTransition(
      scale: isCompleted ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
      child: Column(
        children: [
          Text(
            sessionType == SessionType.work 
                ? 'Focus Time' 
                : sessionType == SessionType.shortBreak 
                    ? 'Short Break' 
                    : 'Long Break',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: isCompleted 
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: 1 - (state.remainingTime.inSeconds / 
                          (sessionType == SessionType.work 
                              ? 25 * 60 
                              : sessionType == SessionType.shortBreak 
                                  ? 5 * 60 
                                  : 15 * 60)),
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                      color: sessionType == SessionType.work
                          ? Theme.of(context).colorScheme.primary
                          : Colors.green,
                    );
                  },
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Text(
                  '$minutes:$seconds',
                  key: ValueKey('$minutes$seconds'),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, PomodoroNotifier notifier) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Card(
        key: ValueKey('stats-${notifier.getTodayDuration().inMinutes}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Today',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(notifier.getTodayDuration()),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _formatDuration(notifier.getThisWeekDuration()),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Month',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _formatDuration(notifier.getThisMonthDuration()),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionHistory(BuildContext context, PomodoroState state) {
    final recentSessions = state.sessions.take(5).toList();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Recent Sessions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: recentSessions.length,
                itemBuilder: (context, index) {
                  final session = recentSessions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        session.type == SessionType.work
                            ? 'Work Session'
                            : session.type == SessionType.shortBreak
                                ? 'Short Break'
                                : 'Long Break',
                      ),
                      subtitle: Text(
                        '${_formatDuration(session.duration)} • ${session.startTime.toString().split(' ')[0]}',
                      ),
                      trailing: session.description != null
                          ? const Icon(Icons.note, size: 16)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionCompleteDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final lastSession = state.sessions.last;

    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Session Complete'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'What did you work on?',
              hintText: 'Brief description (optional)',
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  notifier.addSessionDescription(lastSession.id, controller.text);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
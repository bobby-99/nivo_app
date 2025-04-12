import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:nivo_app/models/pomodoro_session.dart';

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  return PomodoroNotifier();
});

class PomodoroState {
  final Duration remainingTime;
  final bool isRunning;
  final int completedSessions;
  final SessionType currentSessionType;
  final List<PomodoroSession> sessions;

  PomodoroState({
    required this.remainingTime,
    required this.isRunning,
    required this.completedSessions,
    required this.currentSessionType,
    required this.sessions,
  });

  PomodoroState copyWith({
    Duration? remainingTime,
    bool? isRunning,
    int? completedSessions,
    SessionType? currentSessionType,
    List<PomodoroSession>? sessions,
  }) {
    return PomodoroState(
      remainingTime: remainingTime ?? this.remainingTime,
      isRunning: isRunning ?? this.isRunning,
      completedSessions: completedSessions ?? this.completedSessions,
      currentSessionType: currentSessionType ?? this.currentSessionType,
      sessions: sessions ?? this.sessions,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  PomodoroNotifier()
      : super(PomodoroState(
          remainingTime: const Duration(minutes: 25),
          isRunning: false,
          completedSessions: 0,
          currentSessionType: SessionType.work,
          sessions: [],
        )) {
    _init();
  }

  Future<void> _init() async {
    final box = await Hive.openBox<PomodoroSession>('pomodoro_sessions');
    state = state.copyWith(sessions: box.values.toList());
  }

  Future<void> _saveSession(PomodoroSession session) async {
    final box = await Hive.openBox<PomodoroSession>('pomodoro_sessions');
    await box.add(session);
    state = state.copyWith(sessions: [...state.sessions, session]);
  }

  void startTimer() {
    state = state.copyWith(isRunning: true);
    _tick();
  }

  void pauseTimer() {
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    state = state.copyWith(
      isRunning: false,
      remainingTime: state.currentSessionType == SessionType.work
          ? const Duration(minutes: 25)
          : state.currentSessionType == SessionType.shortBreak
              ? const Duration(minutes: 5)
              : const Duration(minutes: 15),
    );
  }

  void _tick() {
    if (!state.isRunning) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (state.remainingTime.inSeconds <= 0) {
        _completeSession();
      } else {
        state = state.copyWith(
          remainingTime: state.remainingTime - const Duration(seconds: 1),
        );
        _tick();
      }
    });
  }

  void _completeSession() {
    final now = DateTime.now();
    final session = PomodoroSession(
      id: '${now.millisecondsSinceEpoch}',
      startTime: now.subtract(state.currentSessionType == SessionType.work
          ? const Duration(minutes: 25)
          : state.currentSessionType == SessionType.shortBreak
              ? const Duration(minutes: 5)
              : const Duration(minutes: 15)),
      endTime: now,
      type: state.currentSessionType,
    );

    _saveSession(session);

    final nextSessionType = state.currentSessionType == SessionType.work
        ? (state.completedSessions + 1) % 4 == 0
            ? SessionType.longBreak
            : SessionType.shortBreak
        : SessionType.work;

    state = state.copyWith(
      isRunning: false,
      completedSessions: state.currentSessionType == SessionType.work
          ? state.completedSessions + 1
          : state.completedSessions,
      currentSessionType: nextSessionType,
      remainingTime: nextSessionType == SessionType.work
          ? const Duration(minutes: 25)
          : nextSessionType == SessionType.shortBreak
              ? const Duration(minutes: 5)
              : const Duration(minutes: 15),
    );
  }

  void addSessionDescription(String id, String description) async {
    final box = await Hive.openBox<PomodoroSession>('pomodoro_sessions');
    final index = box.values.toList().indexWhere((session) => session.id == id);
    if (index != -1) {
      final session = box.getAt(index)!;
      await box.putAt(index, session.copyWith(description: description));
      state = state.copyWith(
        sessions: state.sessions.map((s) =>
            s.id == id ? s.copyWith(description: description) : s).toList(),
      );
    }
  }

  Duration getTodayDuration() {
    final today = DateTime.now();
    return state.sessions
        .where((s) =>
            s.startTime.year == today.year &&
            s.startTime.month == today.month &&
            s.startTime.day == today.day &&
            s.type == SessionType.work)
        .fold(Duration.zero, (sum, session) => sum + session.duration);
  }

  Duration getThisWeekDuration() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return state.sessions
        .where((s) =>
            s.startTime.isAfter(startOfWeek) &&
            s.type == SessionType.work)
        .fold(Duration.zero, (sum, session) => sum + session.duration);
  }

  Duration getThisMonthDuration() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return state.sessions
        .where((s) =>
            s.startTime.isAfter(startOfMonth) &&
            s.type == SessionType.work)
        .fold(Duration.zero, (sum, session) => sum + session.duration);
  }
}
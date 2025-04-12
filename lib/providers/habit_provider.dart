import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:nivo_app/models/habit.dart';


final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    final box = await Hive.openBox<Habit>('habits');
    state = box.values.toList();
  }

  Future<void> _saveToHive(List<Habit> habits) async {
    final box = await Hive.openBox<Habit>('habits');
    await box.clear();
    await box.addAll(habits);
  }

  void addHabit(Habit habit) {
    state = [...state, habit];
    _saveToHive(state);
  }

  void toggleHabitCompletion(String habitId) {
    final now = DateTime.now();
    state = [
      for (final habit in state)
        if (habit.id == habitId)
          habit.isCompletedToday()
              ? habit.copyWith(
                  completionDates: habit.completionDates
                      .where((date) =>
                          !(date.year == now.year &&
                              date.month == now.month &&
                              date.day == now.day))
                      .toList())
              : habit.copyWith(
                  completionDates: [...habit.completionDates, now])
        else
          habit
    ];
    _saveToHive(state);
  }

  void updateHabit(String habitId, Habit updatedHabit) {
    state = [
      for (final habit in state)
        if (habit.id == habitId) updatedHabit else habit
    ];
    _saveToHive(state);
  }

  void deleteHabit(String habitId) {
    state = state.where((habit) => habit.id != habitId).toList();
    _saveToHive(state);
  }
}
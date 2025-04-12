import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:nivo_app/models/task.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    final box = await Hive.openBox<Task>('tasks');
    state = box.values.toList();
  }

  Future<void> _saveToHive(List<Task> tasks) async {
    final box = await Hive.openBox<Task>('tasks');
    await box.clear();
    await box.addAll(tasks);
  }

  void addTask(Task task) {
    state = [...state, task];
    _saveToHive(state);
  }

  void updateTask(String id, Task updatedTask) {
    state = [
      for (final task in state)
        if (task.id == id) updatedTask else task
    ];
    _saveToHive(state);
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
    _saveToHive(state);
  }

  void toggleComplete(String id) {
    state = [
      for (final task in state)
        if (task.id == id) task.copyWith(isCompleted: !task.isCompleted) else task
    ];
    _saveToHive(state);
  }

  List<Task> getTasksByCategory(String category) {
    if (category == 'All Tasks') return state;
    return state.where((task) => task.category == category).toList();
  }

  List<String> get categories {
    final allCategories = state.map((task) => task.category).toSet().toList();
    return ['All Tasks', ...allCategories];
  }
}
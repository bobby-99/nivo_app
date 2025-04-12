// Updated storage_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nivo_app/models/task.dart';
import 'package:nivo_app/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tasksKey = 'nivo_tasks';
  static const String _habitsKey = 'nivo_habits';
  
  // Task methods
  Future<List<Task>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      
      if (tasksJson == null) {
        return [];
      }
      
      final List<dynamic> decodedTasks = jsonDecode(tasksJson);
      return decodedTasks.map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return [];
    }
  }
  
  Future<void> saveTask(Task task) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasks = await getTasks();
      
      tasks.add(task);
      await _saveTasks(prefs, tasks);
    } catch (e) {
      debugPrint('Error saving task: $e');
    }
  }
  
  Future<void> updateTask(Task task) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasks = await getTasks();
      
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task;
        await _saveTasks(prefs, tasks);
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }
  
  Future<void> deleteTask(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasks = await getTasks();
      
      tasks.removeWhere((task) => task.id == taskId);
      await _saveTasks(prefs, tasks);
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }
  
  Future<void> _saveTasks(SharedPreferences prefs, List<Task> tasks) async {
    final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }
  
  // Habit methods
  Future<List<Habit>> getHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString(_habitsKey);
      
      if (habitsJson == null) {
        return [];
      }
      
      final List<dynamic> decodedHabits = jsonDecode(habitsJson);
      return decodedHabits.map((habitJson) => Habit.fromJson(habitJson)).toList();
    } catch (e) {
      debugPrint('Error loading habits: $e');
      return [];
    }
  }
  
  Future<void> saveHabit(Habit habit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habits = await getHabits();
      
      habits.add(habit);
      await _saveHabits(prefs, habits);
    } catch (e) {
      debugPrint('Error saving habit: $e');
    }
  }
  
  Future<void> updateHabit(Habit habit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habits = await getHabits();
      
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        habits[index] = habit;
        await _saveHabits(prefs, habits);
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
    }
  }
  
  Future<void> deleteHabit(String habitId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habits = await getHabits();
      
      habits.removeWhere((habit) => habit.id == habitId);
      await _saveHabits(prefs, habits);
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
  }
  
  Future<void> _saveHabits(SharedPreferences prefs, List<Habit> habits) async {
    final habitsJson = jsonEncode(habits.map((habit) => habit.toJson()).toList());
    await prefs.setString(_habitsKey, habitsJson);
  }
  
  // Clear all data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }
}
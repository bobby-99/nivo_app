// Updated task_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nivo_app/models/task.dart';
import 'package:nivo_app/services/notification_service.dart';
import 'package:nivo_app/services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  List<Task> get tasks => _tasks;
  
  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  Future<void> loadTasks() async {
    try {
      _tasks = await _storageService.getTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _storageService.saveTask(task);
      _tasks.add(task);
      
      // Schedule notification if reminder is set
      if (task.reminderDateTime != null) {
        await _notificationService.scheduleTaskReminder(
          task.id,
          task.title,
          task.description ?? '',
          task.reminderDateTime!,
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _storageService.updateTask(task);
      
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        
        // Update notification if reminder changed
        if (task.reminderDateTime != null) {
          await _notificationService.cancelNotification(task.id);
          await _notificationService.scheduleTaskReminder(
            task.id,
            task.title,
            task.description ?? '',
            task.reminderDateTime!,
          );
        } else {
          await _notificationService.cancelNotification(task.id);
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _storageService.deleteTask(taskId);
      
      _tasks.removeWhere((task) => task.id == taskId);
      await _notificationService.cancelNotification(taskId);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final task = _tasks[index];
        final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
        
        await _storageService.updateTask(updatedTask);
        _tasks[index] = updatedTask;
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';


part 'habit.g.dart'; // For Hive code generation

enum HabitFrequency { daily, weekly, custom }

@HiveType(typeId: 1)
class Habit {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final DateTime startDate;
  @HiveField(4)
  final HabitFrequency frequency;
  @HiveField(5)
  final List<DateTime> completionDates;
  @HiveField(6)
  final TimeOfDay? reminderTime;
  @HiveField(7)
  final int colorValue;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.frequency,
    List<DateTime>? completionDates,
    this.reminderTime,
    this.colorValue = 0xFF7E57C2, // Default purple accent
  }) : completionDates = completionDates ?? [];

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    HabitFrequency? frequency,
    List<DateTime>? completionDates,
    TimeOfDay? reminderTime,
    int? colorValue,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      frequency: frequency ?? this.frequency,
      completionDates: completionDates ?? this.completionDates,
      reminderTime: reminderTime ?? this.reminderTime,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  bool isCompletedToday() {
    final now = DateTime.now();
    return completionDates.any((date) =>
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day);
  }

  int get currentStreak {
    if (completionDates.isEmpty) return 0;
    
    final dates = List<DateTime>.from(completionDates)
      ..sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    while (dates.any((d) => 
        d.year == currentDate.year &&
        d.month == currentDate.month &&
        d.day == currentDate.day)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  List<bool> get lastWeekCompletion {
    final now = DateTime.now();
    final weekDates = List.generate(7, (i) => 
        DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    
    return weekDates.map((date) => 
        completionDates.any((d) => 
            d.year == date.year &&
            d.month == date.month &&
            d.day == date.day)).toList();
  }
}
part 'habit.g.dart';

@HiveType(typeId: 1)
enum HabitFrequency { daily, weekly, custom }
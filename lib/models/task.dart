import 'package:hive/hive.dart';

part 'task.g.dart'; // For Hive code generation

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final bool isCompleted;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final String category;
  @HiveField(6)
  final bool isHighPriority;
  @HiveField(7)
  final DateTime? reminderTime;
  @HiveField(8)
  final String? repeatInterval;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    required this.category,
    this.isHighPriority = false,
    this.reminderTime,
    this.repeatInterval,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    String? category,
    bool? isHighPriority,
    DateTime? reminderTime,
    String? repeatInterval,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      isHighPriority: isHighPriority ?? this.isHighPriority,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatInterval: repeatInterval ?? this.repeatInterval,
    );
  }
}
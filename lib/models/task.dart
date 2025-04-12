// Updated task.dart
import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? reminderDateTime;
  final String category;
  final int priority; // 0: Low, 1: Medium, 2: High
  final Color colorTag;
  final bool isCompleted;
  final bool isRepeating;
  final String? repeatFrequency; // daily, weekly, monthly

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.reminderDateTime,
    required this.category,
    required this.priority,
    required this.colorTag,
    this.isCompleted = false,
    this.isRepeating = false,
    this.repeatFrequency,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? reminderDateTime,
    String? category,
    int? priority,
    Color? colorTag,
    bool? isCompleted,
    bool? isRepeating,
    String? repeatFrequency,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
// Continued from task.dart
      dueDate: dueDate ?? this.dueDate,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      colorTag: colorTag ?? this.colorTag,
      isCompleted: isCompleted ?? this.isCompleted,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'category': category,
      'priority': priority,
      'colorTag': colorTag.value,
      'isCompleted': isCompleted,
      'isRepeating': isRepeating,
      'repeatFrequency': repeatFrequency,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      reminderDateTime: json['reminderDateTime'] != null 
          ? DateTime.parse(json['reminderDateTime']) 
          : null,
      category: json['category'],
      priority: json['priority'],
      colorTag: Color(json['colorTag']),
      isCompleted: json['isCompleted'],
      isRepeating: json['isRepeating'],
      repeatFrequency: json['repeatFrequency'],
    );
  }
}
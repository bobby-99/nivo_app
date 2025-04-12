import 'package:flutter/material.dart';
import 'package:nivo_app/models/habit.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggleComplete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = habit.isCompletedToday();
    final streak = habit.currentStreak;
    final weekCompletion = habit.lastWeekCompletion;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Color(habit.colorValue).withOpacity(0.2),
      child: InkWell(
        onTap: onToggleComplete,
        onLongPress: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      habit.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: isCompleted ? theme.colorScheme.primary : theme.disabledColor,
                  ),
                ],
              ),
              if (habit.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    habit.description!,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text('$streak day${streak == 1 ? '' : 's'} streak'),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: weekCompletion.map((completed) {
                        return Container(
                          width: 4,
                          height: completed ? 20 : 10,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: completed 
                                ? theme.colorScheme.primary 
                                : theme.disabledColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
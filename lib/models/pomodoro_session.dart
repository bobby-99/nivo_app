import 'package:hive/hive.dart';

part 'pomodoro_session.g.dart';

enum SessionType { work, shortBreak, longBreak }

@HiveType(typeId: 2)
class PomodoroSession {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime startTime;
  @HiveField(2)
  final DateTime endTime;
  @HiveField(3)
  final SessionType type;
  @HiveField(4)
  final String? description;

  PomodoroSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.description,
  });

  Duration get duration => endTime.difference(startTime);
}
part 'pomodoro_session.g.dart';

@HiveType(typeId: 2)
enum SessionType { work, shortBreak, longBreak }
// Updated pomodoro_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nivo_app/models/pomodoro_session.dart';
import 'package:nivo_app/theme/palette.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int workDuration = 25 * 60; // 25 minutes in seconds
  static const int breakDuration = 5 * 60; // 5 minutes in seconds
  
  int _currentSeconds = workDuration;
  bool _isRunning = false;
  bool _isWorkSession = true;
  Timer? _timer;
  List<PomodoroSession> _sessions = [];
  
  TextEditingController _sessionNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sessionNoteController.dispose();
    super.dispose();
  }

  void _resetTimer() {
    setState(() {
      _currentSeconds = _isWorkSession ? workDuration : breakDuration;
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentSeconds > 0) {
          setState(() {
            _currentSeconds--;
          });
        } else {
          _timer?.cancel();
          _onSessionComplete();
        }
      });
    }
    
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _onSessionComplete() {
    // Log the completed session if it was a work session
    if (_isWorkSession) {
      _showSessionCompletionDialog();
    } else {
      // Automatically transition to work session
      setState(() {
        _isWorkSession = true;
        _currentSeconds = workDuration;
        _isRunning = false;
      });
    }
  }

  void _showSessionCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Work Session Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('What did you accomplish in this session?'),
              const SizedBox(height: 16),
              TextField(
                controller: _sessionNoteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter a brief description...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save the session
                final now = DateTime.now();
                _sessions.add(
                  PomodoroSession(
                    id: now.millisecondsSinceEpoch.toString(),
                    startTime: now.subtract(const Duration(minutes: 25)),
                    endTime: now,
                    notes: _sessionNoteController.text,
                  ),
                );
                
                // Reset controller
                _sessionNoteController.clear();
                
                // Start break session
                setState(() {
                  _isWorkSession = false;
                  _currentSeconds = breakDuration;
                  _isRunning = false;
                });
                
                Navigator.pop(context);
              },
              child: const Text('Save & Start Break'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Session type indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _isWorkSession ? primaryColor : Colors.green,
            child: Text(
              _isWorkSession ? 'WORK SESSION' : 'BREAK TIME',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          
          // Timer display
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(_currentSeconds),
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: isLightMode 
                          ? Colors.black 
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset button
                      ElevatedButton.icon(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLightMode 
                              ? Colors.grey[300] 
                              : Palette.darkSurface,
                          foregroundColor: isLightMode 
                              ? Colors.black 
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20, 
                            vertical: 12,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Start/Pause button
                      ElevatedButton.icon(
                        onPressed: _toggleTimer,
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'Pause' : 'Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20, 
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Sessions history
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: isLightMode ? Colors.grey[100] : Palette.darkSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Sessions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isLightMode ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _sessions.isEmpty
                      ? Center(
                          child: Text(
                            'Complete a session to see it here',
                            style: TextStyle(
                              color: isLightMode 
                                  ? Colors.black54 
                                  : Colors.white70,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            final session = _sessions[_sessions.length - 1 - index];
                            return ListTile(
                              title: Text(
                                '${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')} - ${session.endTime.hour}:${session.endTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode 
                                      ? Colors.black 
                                      : Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                session.notes.isEmpty 
                                    ? 'No notes' 
                                    : session.notes,
                                style: TextStyle(
                                  color: isLightMode 
                                      ? Colors.black54 
                                      : Colors.white70,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
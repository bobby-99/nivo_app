import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppAccentColor { purple, blue, green }

class ThemeState {
  final bool isDarkMode;
  final AppAccentColor accentColor;
  final bool notificationsEnabled;

  ThemeState({
    required this.isDarkMode,
    required this.accentColor,
    required this.notificationsEnabled,
  });

  ThemeState copyWith({
    bool? isDarkMode,
    AppAccentColor? accentColor,
    bool? notificationsEnabled,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColor: accentColor ?? this.accentColor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(
          isDarkMode: true,
          accentColor: AppAccentColor.purple,
          notificationsEnabled: true,
        ));

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setAccentColor(AppAccentColor color) {
    state = state.copyWith(accentColor: color);
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }
}
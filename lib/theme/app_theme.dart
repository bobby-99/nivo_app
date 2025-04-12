import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivo_app/providers/theme_provider.dart';

final appThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeProvider);
  return _buildThemeData(themeState);
});

ThemeData _buildThemeData(ThemeState state) {
  final primaryColor = state.accentColor == AppAccentColor.purple
      ? const Color(0xFF7E57C2)
      : state.accentColor == AppAccentColor.blue
          ? const Color(0xFF42A5F5)
          : const Color(0xFF66BB6A);

  return state.isDarkMode
      ? ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: primaryColor,
            secondary: primaryColor,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
          ),
        )
      : ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            secondary: primaryColor,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
          ),
        );
}
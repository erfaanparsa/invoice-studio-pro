import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggleTheme({Brightness? currentBrightness}) {
    final effectiveBrightness =
        currentBrightness ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    final isCurrentlyDark =
        state == ThemeMode.dark ||
        (state == ThemeMode.system && effectiveBrightness == Brightness.dark);

    state = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

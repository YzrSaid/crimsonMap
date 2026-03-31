import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool isDarkMode;

  const SettingsState({this.isDarkMode = false});

  SettingsState copyWith({bool? isDarkMode}) =>
      SettingsState(isDarkMode: isDarkMode ?? this.isDarkMode);
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void setDarkMode(bool value) => state = state.copyWith(isDarkMode: value);
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

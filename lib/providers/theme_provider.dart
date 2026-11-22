import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('SharedPreferences has not been initialized.'),
);

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _preferenceKey = 'theme_mode';

  late SharedPreferences _preferences;

  @override
  ThemeMode build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    final savedMode = _preferences.getString(_preferenceKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == savedMode,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final saved = await _preferences.setString(_preferenceKey, mode.name);
    if (!saved) {
      throw StateError('Could not save the selected theme mode.');
    }
    state = mode;
  }
}

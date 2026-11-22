import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../providers/auth_providers.dart';
import '../providers/theme_provider.dart';
import 'ui_helpers.dart';

class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return PopupMenuButton<String>(
      tooltip: 'Account',
      icon: CircleAvatar(radius: 16, child: Text(profile.initial)),
      onSelected: (value) async {
        final selectedTheme = switch (value) {
          'theme_system' => ThemeMode.system,
          'theme_light' => ThemeMode.light,
          'theme_dark' => ThemeMode.dark,
          _ => null,
        };
        if (selectedTheme != null) {
          try {
            await ref
                .read(themeModeProvider.notifier)
                .setThemeMode(selectedTheme);
          } catch (e) {
            if (context.mounted) {
              showMessage(context, 'Could not save theme preference: $e',
                  error: true);
            }
          }
          return;
        }
        if (value != 'logout') return;
        final error = await ref.read(authControllerProvider.notifier).signOut();
        if (error != null && context.mounted) {
          showMessage(context, error, error: true);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (profile.email != null) Text(profile.email!),
              Text(profile.isAdmin ? 'Administrator' : 'Customer'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'theme_system',
          child: _ThemeMenuItem(
            icon: Icons.settings_brightness,
            label: 'System default',
            selected: themeMode == ThemeMode.system,
          ),
        ),
        PopupMenuItem<String>(
          value: 'theme_light',
          child: _ThemeMenuItem(
            icon: Icons.light_mode_outlined,
            label: 'Light mode',
            selected: themeMode == ThemeMode.light,
          ),
        ),
        PopupMenuItem<String>(
          value: 'theme_dark',
          child: _ThemeMenuItem(
            icon: Icons.dark_mode_outlined,
            label: 'Dark mode',
            selected: themeMode == ThemeMode.dark,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 12),
              Text('Log out')
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeMenuItem extends StatelessWidget {
  const _ThemeMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (selected) const Icon(Icons.check, size: 18),
      ],
    );
  }
}

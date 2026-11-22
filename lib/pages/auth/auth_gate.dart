import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../widgets/async_value_view.dart';
import '../shell/admin_shell.dart';
import '../shell/customer_shell.dart';
import 'auth_page.dart';

/// Decides what to show from the live session + the role stored in the database:
/// signed out -> login/sign-up, admin -> admin app, otherwise -> customer app.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If the session changes while a pushed screen is open (logout, expiry),
    // drop back to the gate so no stale screen is left on top.
    ref.listen<String?>(currentUserIdProvider, (prev, next) {
      if (prev != next) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return const AuthPage();

    final profile = ref.watch(profileProvider);
    return profile.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: ErrorView(
          error: e,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),
        ),
      ),
      data: (p) {
        if (p == null) return const AuthPage();
        return p.isAdmin ? AdminShell(profile: p) : CustomerShell(profile: p);
      },
    );
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors.dart';
import '../models/user_profile.dart';
import 'core_providers.dart';

/// Live stream of Supabase auth events (login, logout, token refresh, deep link).
final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authServiceProvider).authChanges,
);

/// The signed-in user's id, or null. Everything user-specific watches this, so
/// state (cart, filters, orders, profile) resets automatically on login/logout.
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (s) => s.session?.user.id,
    loading: () => ref.read(authServiceProvider).currentSession?.user.id,
    error: (_, __) => null,
  );
});

/// The signed-in user's profile + role (read from the database, never from the client).
final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;
  return ref.watch(profileServiceProvider).fetchProfile(uid);
});

/// Login / sign-up / logout actions. Each returns an error message, or null on success.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<String?> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return friendlyError(e);
    }
  }

  Future<String?> signIn(String email, String password) =>
      _run(() => ref.read(authServiceProvider).signIn(email.trim(), password));

  Future<String?> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) =>
      _run(
        () => ref.read(authServiceProvider).signUp(
              email: email.trim(),
              password: password,
              firstname: firstname.trim(),
              lastname: lastname.trim(),
            ),
      );

  Future<String?> signInWithGoogle() =>
      _run(() => ref.read(authServiceProvider).signInWithGoogle());

  Future<String?> signOut() =>
      _run(() => ref.read(authServiceProvider).signOut());
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

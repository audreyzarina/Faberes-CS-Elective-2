import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';

/// The only place that talks to Supabase Auth.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Stream<AuthState> get authChanges => _auth.onAuthStateChange;

  Session? get currentSession => _auth.currentSession;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    await _auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: AppConfig.authRedirect,
      // Read by the handle_new_user trigger. The role is NOT taken from here:
      // the trigger always assigns "customer".
      data: {'firstname': firstname, 'lastname': lastname},
    );
  }

  Future<void> signInWithGoogle() async {
    await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.authRedirect,
    );
  }

  Future<void> signOut() => _auth.signOut();
}

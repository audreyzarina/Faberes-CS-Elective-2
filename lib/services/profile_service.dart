import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors.dart';
import '../models/user_profile.dart';

class ProfileService {
  ProfileService(this._client);

  final SupabaseClient _client;

  Future<UserProfile> fetchProfile(String userId) async {
    final row =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (row == null) {
      throw const AppException(
        'Your profile could not be found. Please log out and sign in again.',
      );
    }
    var role = 'customer';
    final roleId = row['role_id'];
    if (roleId != null) {
      final r = await _client
          .from('roles')
          .select('role')
          .eq('id', roleId)
          .maybeSingle();
      role = (r?['role'] as String?) ?? 'customer';
    }
    return UserProfile.fromMap(row, role);
  }
}

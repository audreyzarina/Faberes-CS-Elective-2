class UserProfile {
  const UserProfile({
    required this.id,
    this.email,
    this.firstname,
    this.lastname,
    required this.role,
  });

  final String id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String role;

  bool get isAdmin => role == 'admin';

  String get fullName {
    final name = [firstname, lastname]
        .where((s) => s != null && s.trim().isNotEmpty)
        .join(' ')
        .trim();
    if (name.isNotEmpty) return name;
    return email?.split('@').first ?? 'Guest';
  }

  String get initial => fullName.isEmpty ? '?' : fullName[0].toUpperCase();

  factory UserProfile.fromMap(Map<String, dynamic> m, String role) =>
      UserProfile(
        id: m['id'] as String,
        email: m['email'] as String?,
        firstname: m['firstname'] as String?,
        lastname: m['lastname'] as String?,
        role: role,
      );
}

import 'package:supabase_flutter/supabase_flutter.dart';

/// An error whose message is safe to show to the user as-is.
class AppException implements Exception {
  const AppException(this.message, {this.permissionDenied = false});
  final String message;
  final bool permissionDenied;

  @override
  String toString() => message;
}

bool isPermissionError(Object error) {
  if (error is AppException) return error.permissionDenied;
  if (error is PostgrestException) return error.code == '42501';
  if (error is StorageException) {
    return error.statusCode == '403' || error.statusCode == '401';
  }
  return false;
}

/// Turns any thrown object into a short, human-readable message.
String friendlyError(Object error) {
  if (error is AppException) return error.message;
  if (error is AuthException) return error.message;
  if (error is PostgrestException) {
    switch (error.code) {
      case '42501':
        return 'Permission denied. Your account is not allowed to do this.';
      case '23503':
        return 'This record is still used by other data.';
      case '23505':
        return 'That value already exists.';
      case '23514':
        return 'One of the values is outside the allowed range.';
    }
    return error.message;
  }
  if (error is StorageException) {
    return isPermissionError(error)
        ? 'Permission denied. Only admins can upload images.'
        : 'Image upload failed: ${error.message}';
  }
  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('Failed host lookup')) {
    return 'No internet connection. Please check your network and try again.';
  }
  return 'Something went wrong. Please try again.';
}

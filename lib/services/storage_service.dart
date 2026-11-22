import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';

class StorageService {
  StorageService(this._client);

  final SupabaseClient _client;

  /// Uploads a product image to Supabase Storage and returns its public URL.
  Future<String> uploadProductImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final dot = file.name.lastIndexOf('.');
    final ext = dot == -1 ? 'jpg' : file.name.substring(dot + 1).toLowerCase();
    final path = 'products/${DateTime.now().microsecondsSinceEpoch}.$ext';

    final bucket = _client.storage.from(AppConfig.productBucket);
    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: _mime(ext), upsert: false),
    );
    return bucket.getPublicUrl(path);
  }

  String _mime(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}

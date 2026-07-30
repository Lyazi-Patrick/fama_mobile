import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Laravel stores image_path as a relative path like "ads/abc123.jpg"
/// (via Storage::disk('public')), served at {APP_URL}/storage/{path} --
/// not under /api. This strips the /api suffix from API_BASE_URL and
/// builds the public storage URL.
String? storageUrl(String? relativePath) {
  if (relativePath == null || relativePath.isEmpty) return null;
  final apiBase = dotenv.env['API_BASE_URL'] ?? '';
  final serverRoot = apiBase.replaceFirst(RegExp(r'/api/?$'), '');
  return '$serverRoot/storage/$relativePath';
}

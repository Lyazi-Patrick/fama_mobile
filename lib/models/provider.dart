import '../core/utils/parsing.dart';

class ProviderItem {
  final int id;
  final int userId;
  final String name;
  final String? bio;
  final String? briefProfile;
  final String? whatsappNumber;
  final String? extensionService;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final List<String> tags;
  final String status;

  ProviderItem({
    required this.id,
    required this.userId,
    required this.name,
    this.bio,
    this.briefProfile,
    this.whatsappNumber,
    this.extensionService,
    this.imagePath,
    this.latitude,
    this.longitude,
    this.tags = const [],
    required this.status,
  });

  factory ProviderItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ProviderItem(
      id: asInt(json['id']),
      userId: asInt(json['user_id']),
      name: user?['name'] ?? 'Unknown provider',
      bio: json['bio'],
      briefProfile: json['brief_profile'],
      whatsappNumber: json['whatsapp_number'],
      extensionService: json['extension_service'] ?? user?['extension_service'],
      imagePath: json['image_path'],
      latitude: asDoubleOrNull(user?['latitude']),
      longitude: asDoubleOrNull(user?['longitude']),
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((t) => t['name'].toString())
          .toList(),
      status: json['status'] ?? 'pending',
    );
  }
}

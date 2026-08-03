import '../core/utils/parsing.dart';

class AppUser {
  final int id;
  final String name;
  final String email;
  final double? latitude;
  final double? longitude;
  final String? extensionService;
  final List<String> roles;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.latitude,
    this.longitude,
    this.extensionService,
    this.roles = const [],
  });

  bool get isDealer => roles.contains('dealer');
  bool get isExtensionWorker => roles.contains('extension_worker');
  bool get isFarmer => roles.contains('farmer') || roles.isEmpty;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: asInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      latitude: asDoubleOrNull(json['latitude']),
      longitude: asDoubleOrNull(json['longitude']),
      extensionService: json['extension_service'],
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((r) => r['name'].toString())
          .toList(),
    );
  }
}

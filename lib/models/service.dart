import '../core/utils/parsing.dart';

class ServiceItem {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final String? imagePath;
  final String status;
  final List<String> tags;

  ServiceItem({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.imagePath,
    required this.status,
    this.tags = const [],
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
        id: asInt(json['id']),
        userId: asInt(json['user_id']),
        name: json['name'] ?? '',
        description: json['description'],
        imagePath: json['image_path'],
        status: json['status'] ?? 'pending',
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((t) => t['name'].toString())
            .toList(),
      );
}

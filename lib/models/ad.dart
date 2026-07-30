import '../core/utils/parsing.dart';

class AdItem {
  final int id;
  final String description;
  final String? imagePath;
  final String status;

  AdItem({
    required this.id,
    required this.description,
    this.imagePath,
    required this.status,
  });

  factory AdItem.fromJson(Map<String, dynamic> json) => AdItem(
        id: asInt(json['id']),
        description: json['description'] ?? '',
        imagePath: json['image_path'],
        status: json['status'] ?? 'pending',
      );
}

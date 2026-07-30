import '../core/utils/parsing.dart';

class ServiceRequestItem {
  final int id;
  final int farmerId;
  final int extensionWorkerId;
  final String description;
  final String status;
  final String? responseMessage;

  ServiceRequestItem({
    required this.id,
    required this.farmerId,
    required this.extensionWorkerId,
    required this.description,
    required this.status,
    this.responseMessage,
  });

  factory ServiceRequestItem.fromJson(Map<String, dynamic> json) => ServiceRequestItem(
        id: asInt(json['id']),
        farmerId: asInt(json['farmer_id']),
        extensionWorkerId: asInt(json['extension_worker_id']),
        description: json['description'] ?? '',
        status: json['status'] ?? 'pending',
        responseMessage: json['response_message'],
      );
}

class WorkerProfileItem {
  final int id;
  final int userId;
  final String? bio;
  final String? whatsappNumber;
  final String status;

  WorkerProfileItem({
    required this.id,
    required this.userId,
    this.bio,
    this.whatsappNumber,
    required this.status,
  });

  factory WorkerProfileItem.fromJson(Map<String, dynamic> json) => WorkerProfileItem(
        id: asInt(json['id']),
        userId: asInt(json['user_id']),
        bio: json['bio'],
        whatsappNumber: json['whatsapp_number'],
        status: json['status'] ?? 'pending',
      );
}

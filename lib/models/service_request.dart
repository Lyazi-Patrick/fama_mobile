import '../core/utils/parsing.dart';

class ServiceRequestItem {
  final int id;
  final int farmerId;
  final int extensionWorkerId;
  final String description;
  final String status;
  final String? responseMessage;
  final String? farmerName;
  final String? extensionWorkerName;

  ServiceRequestItem({
    required this.id,
    required this.farmerId,
    required this.extensionWorkerId,
    required this.description,
    required this.status,
    this.responseMessage,
    this.farmerName,
    this.extensionWorkerName,
  });

  factory ServiceRequestItem.fromJson(Map<String, dynamic> json) {
    final farmer = json['farmer'] as Map<String, dynamic>?;
    // Note: the Laravel relation method is extensionWorker() (camelCase),
    // so Eloquent serializes it under that exact key, not extension_worker.
    final worker = json['extensionWorker'] as Map<String, dynamic>?;
    return ServiceRequestItem(
      id: asInt(json['id']),
      farmerId: asInt(json['farmer_id']),
      extensionWorkerId: asInt(json['extension_worker_id']),
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      responseMessage: json['response_message'],
      farmerName: farmer?['name'],
      extensionWorkerName: worker?['name'],
    );
  }
}

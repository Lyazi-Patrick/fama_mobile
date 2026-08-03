import '../core/utils/parsing.dart';

class Plan {
  final int id;
  final String title;
  final String targetRole;
  final double amount;
  final String? description;
  final String? duration;

  Plan({
    required this.id,
    required this.title,
    required this.targetRole,
    required this.amount,
    this.description,
    this.duration,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: asInt(json['id']),
        title: json['title'] ?? '',
        targetRole: json['target_role'] ?? '',
        amount: asDouble(json['amount']),
        description: json['description'],
        duration: json['duration']?.toString(),
      );
}

class SubscriptionItem {
  final int id;
  final String role;
  final String status;
  final String? phoneNumber;
  final int? planId;
  final String? startDate;
  final String? endDate;

  SubscriptionItem({
    required this.id,
    required this.role,
    required this.status,
    this.phoneNumber,
    this.planId,
    this.startDate,
    this.endDate,
  });

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) => SubscriptionItem(
        id: asInt(json['id']),
        role: json['role'] ?? '',
        status: json['status'] ?? 'pending',
        phoneNumber: json['phone_number'],
        planId: json['plan_id'] != null ? asInt(json['plan_id']) : null,
        startDate: json['start_date'],
        endDate: json['end_date'],
      );
}

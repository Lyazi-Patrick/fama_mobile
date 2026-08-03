import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class RoleUpgradeService {
  final _dio = ApiClient.instance.dio;

  /// POST /api/role-upgrade-requests as multipart/form-data so file fields
  /// (license, identity_card, profile_photo, supporting_documents) can ride
  /// alongside the text fields in one request.
  Future<void> submit({
    required String requestedRole, // 'dealer' or 'extension_worker'
    String? nin,
    String? extensionService,
    String? briefProfile,
    List<int> tagIds = const [],
    File? license,
    File? identityCard,
    File? profilePhoto,
    File? supportingDocuments,
  }) async {
    final formData = FormData.fromMap({
      'requested_role': requestedRole,
      if (nin != null && nin.isNotEmpty) 'nin': nin,
      if (extensionService != null && extensionService.isNotEmpty) 'extension_service': extensionService,
      if (briefProfile != null && briefProfile.isNotEmpty) 'brief_profile': briefProfile,
      if (tagIds.isNotEmpty) 'tags[]': tagIds,
      if (license != null) 'license': await MultipartFile.fromFile(license.path),
      if (identityCard != null) 'identity_card': await MultipartFile.fromFile(identityCard.path),
      if (profilePhoto != null) 'profile_photo': await MultipartFile.fromFile(profilePhoto.path),
      if (supportingDocuments != null)
        'supporting_documents': await MultipartFile.fromFile(supportingDocuments.path),
    });

    await _dio.post('/role-upgrade-requests', data: formData);
  }
}

import 'package:flutter/material.dart';

/// STUB — mirrors RoleUpgradeRequestForm.php / Farmer|Dealer|WorkerUpgradeRequestForm.php.
/// POST multipart form data (license, identity_card, profile_photo,
/// supporting_documents) to POST /api/role-upgrade-requests. Use
/// image_picker (already in pubspec.yaml) for the file fields.
class RoleUpgradeScreen extends StatelessWidget {
  const RoleUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Role')),
      body: const Center(child: Text('TODO: role upgrade request form (see ROADMAP.md)')),
    );
  }
}

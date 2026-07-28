import 'package:flutter/material.dart';

/// STUB — mirrors WorkerServiceForm.php (create) + the services listing.
/// Follow the pattern in ProductListScreen: add a ServicesApiService,
/// call GET /api/services, render a list, add a form screen posting to
/// POST /api/services.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: const Center(child: Text('TODO: list + create services (see ROADMAP.md)')),
    );
  }
}

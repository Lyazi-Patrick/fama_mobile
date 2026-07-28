import 'package:flutter/material.dart';

/// STUB — mirrors SearchProviders.php + ProviderMapDiscovery.php.
/// Use GET /api/providers with lat/lng for map view, and google_maps_flutter
/// (already in pubspec.yaml) to render pins, same idea as OutletController's
/// distance sort.
class ProvidersScreen extends StatelessWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Provider')),
      body: const Center(child: Text('TODO: map + list of extension workers (see ROADMAP.md)')),
    );
  }
}

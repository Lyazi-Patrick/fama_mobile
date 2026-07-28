import 'package:flutter/material.dart';

/// STUB — mirrors the Plans/Subscription payment flow on the web.
/// GET /api/plans to list options, POST /api/subscriptions with
/// { plan_id, phone_number } to start a mobile-money charge.
class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      body: const Center(child: Text('TODO: plans + mobile money checkout (see ROADMAP.md)')),
    );
  }
}

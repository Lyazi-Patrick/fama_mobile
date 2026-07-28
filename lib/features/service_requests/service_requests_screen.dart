import 'package:flutter/material.dart';

/// STUB — mirrors MyServiceRequests.php / IncomingServiceRequests.php /
/// ServiceRequestForm.php. Two tabs: "My requests" (farmer) and
/// "Incoming" (extension worker) hitting GET /api/service-requests/mine
/// and GET /api/service-requests/incoming respectively.
class ServiceRequestsScreen extends StatelessWidget {
  const ServiceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Service Requests'),
          bottom: const TabBar(tabs: [Tab(text: 'My Requests'), Tab(text: 'Incoming')]),
        ),
        body: const TabBarView(children: [
          Center(child: Text('TODO: GET /api/service-requests/mine')),
          Center(child: Text('TODO: GET /api/service-requests/incoming')),
        ]),
      ),
    );
  }
}

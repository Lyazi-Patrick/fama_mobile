import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/provider.dart';
import '../../models/service_request.dart';
import '../../services/provider_service.dart';
import '../../services/service_request_api_service.dart';
import '../auth/auth_provider.dart';
import '../shared/notification_bell.dart';

/// Mirrors MyServiceRequests.php (farmer view) and
/// IncomingServiceRequests.php (extension worker view). The Incoming tab
/// only appears for accounts that are actually extension workers -- a
/// plain farmer has nothing to receive, so showing an empty "Incoming"
/// tab would just be confusing.
class ServiceRequestsScreen extends StatelessWidget {
  const ServiceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isExtensionWorker = context.watch<AuthProvider>().user?.isExtensionWorker ?? false;

    if (!isExtensionWorker) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Requests'),
          actions: const [NotificationBellAction()],
        ),
        body: const _MyRequestsTab(),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Service Requests'),
          actions: const [NotificationBellAction()],
          bottom: const TabBar(tabs: [Tab(text: 'My Requests'), Tab(text: 'Incoming')]),
        ),
        body: const TabBarView(
          children: [_MyRequestsTab(), _IncomingRequestsTab()],
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'accepted':
      return FamaColors.primary;
    case 'declined':
      return FamaColors.error;
    case 'completed':
      return FamaColors.secondary;
    case 'referred':
      return FamaColors.tertiary;
    default:
      return FamaColors.outline;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _MyRequestsTab extends StatefulWidget {
  const _MyRequestsTab();

  @override
  State<_MyRequestsTab> createState() => _MyRequestsTabState();
}

class _MyRequestsTabState extends State<_MyRequestsTab> {
  final _service = ServiceRequestApiService();
  late Future<List<ServiceRequestItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchMine();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() => _future = _service.fetchMine()),
      child: FutureBuilder<List<ServiceRequestItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load your requests: ${snapshot.error}'));
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text("You haven't requested any services yet.\nFind a provider to get started.", textAlign: TextAlign.center)),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final r = requests[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FamaColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FamaColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            r.extensionWorkerName ?? 'Extension Worker',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        _StatusBadge(status: r.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(r.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                    if (r.responseMessage != null && r.responseMessage!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FamaColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Response: ${r.responseMessage}', style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _IncomingRequestsTab extends StatefulWidget {
  const _IncomingRequestsTab();

  @override
  State<_IncomingRequestsTab> createState() => _IncomingRequestsTabState();
}

class _IncomingRequestsTabState extends State<_IncomingRequestsTab> {
  final _service = ServiceRequestApiService();
  late Future<List<ServiceRequestItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchIncoming();
  }

  void _reload() => setState(() => _future = _service.fetchIncoming());

  Future<void> _act(ServiceRequestItem request, String action) async {
    try {
      if (action == 'refer') {
        final referredToId = await _pickReferralTarget();
        if (referredToId == null) return; // cancelled
        await _service.respond(requestId: request.id, action: 'refer', referredToId: referredToId);
      } else {
        await _service.respond(requestId: request.id, action: action);
      }
      _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update this request: $e')),
        );
      }
    }
  }

  Future<int?> _pickReferralTarget() async {
    final providers = await ProviderService().fetchProviders();
    if (!mounted) return null;
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: FamaColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Refer to another provider', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            ...providers.map((ProviderItem p) => ListTile(
                  title: Text(p.name),
                  subtitle: Text(p.extensionService ?? ''),
                  onTap: () => Navigator.of(context).pop(p.userId),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: FutureBuilder<List<ServiceRequestItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load incoming requests: ${snapshot.error}'));
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No incoming requests yet.', textAlign: TextAlign.center)),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final r = requests[index];
              final isPending = r.status == 'pending';
              final isAccepted = r.status == 'accepted';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FamaColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FamaColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(r.farmerName ?? 'Farmer', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        _StatusBadge(status: r.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(r.description),
                    if (isPending || isAccepted) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (isPending) ...[
                            FilledButton(
                              style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
                              onPressed: () => _act(r, 'accept'),
                              child: const Text('Accept'),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                              onPressed: () => _act(r, 'decline'),
                              child: const Text('Decline'),
                            ),
                          ],
                          if (isAccepted)
                            FilledButton(
                              style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
                              onPressed: () => _act(r, 'complete'),
                              child: const Text('Mark Complete'),
                            ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                            onPressed: () => _act(r, 'refer'),
                            child: const Text('Refer'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

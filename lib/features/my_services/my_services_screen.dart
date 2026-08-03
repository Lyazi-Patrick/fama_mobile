import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/network/asset_url.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/service.dart';
import '../../services/service_api_service.dart';
import 'add_edit_service_screen.dart';
import 'my_worker_profile_screen.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  final _service = ServiceApiService();
  late Future<List<ServiceItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchMyServices();
  }

  void _reload() => setState(() => _future = _service.fetchMyServices());

  Future<void> _confirmDelete(ServiceItem service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this service?'),
        content: Text('"${service.name}" will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: FamaColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteService(service.id);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Services & Profile')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddEditServiceScreen()),
          );
          if (added == true) _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Card(
              elevation: 0,
              color: FamaColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: FamaColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('My Provider Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Bio, specializations, WhatsApp, photo'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyWorkerProfileScreen()),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('My Services', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            FutureBuilder<List<ServiceItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text('Could not load your services: ${snapshot.error}')),
                  );
                }
                final services = snapshot.data ?? [];
                if (services.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text("You haven't listed any services yet.")),
                  );
                }
                return Column(
                  children: services.map((s) => _ServiceManagementRow(service: s, onChanged: _reload, onDelete: () => _confirmDelete(s))).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceManagementRow extends StatelessWidget {
  const _ServiceManagementRow({required this.service, required this.onChanged, required this.onDelete});

  final ServiceItem service;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final imageUrl = storageUrl(service.imagePath);
    final statusColor = service.status == 'approved'
        ? FamaColors.primary
        : (service.status == 'rejected' ? FamaColors.error : FamaColors.outline);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FamaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FamaColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: imageUrl != null
                  ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                  : Container(color: FamaColors.surfaceContainer, child: const Icon(Icons.grass_outlined, size: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                  child: Text(service.status, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => AddEditServiceScreen(service: service)),
              );
              if (updated == true) onChanged();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: FamaColors.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

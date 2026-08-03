import 'package:flutter/material.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/service.dart';
import '../../services/service_api_service.dart';
import '../marketplace/featured_banner.dart';
import '../providers/providers_screen.dart';
import '../shared/notification_bell.dart';

/// Matches the Stitch "services_list" screen: search bar, a promoted
/// banner, then a curated single-column list of services (icon, title,
/// description, tag badges) rather than a raw dump of every DB row --
/// only approved services show, each rendered through the same visual
/// treatment Stitch designed regardless of what real data backs it.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _service = ServiceApiService();
  final _searchController = TextEditingController();
  late Future<List<ServiceItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchServices();
  }

  void _search() {
    setState(() => _future = _service.fetchServices(search: _searchController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        actions: const [NotificationBellAction()],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _future = _service.fetchServices()),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search services (e.g. Soil, Pests)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: FamaColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: FamaColors.outlineVariant),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const FeaturedBanner(),
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
                    child: Center(child: Text('Could not load services: ${snapshot.error}')),
                  );
                }
                final services = snapshot.data ?? [];
                if (services.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No services available yet.')),
                  );
                }
                return Column(
                  children: services.map((s) => _ServiceRow(service: s)).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            _NeedCustomPlanCard(
              onRequest: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProvidersScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Picks a reasonable icon/color from the service's own tags/name rather
/// than a fixed lookup table, since we don't control what workers actually
/// name their services.
({IconData icon, Color background, Color foreground}) _iconFor(ServiceItem service) {
  final haystack = ('${service.name} ${service.tags.join(' ')}').toLowerCase();

  if (haystack.contains('soil') || haystack.contains('lab')) {
    return (icon: Icons.science_outlined, background: FamaColors.tertiary, foreground: Colors.white);
  }
  if (haystack.contains('weather') || haystack.contains('climate')) {
    return (icon: Icons.wb_sunny_outlined, background: FamaColors.secondaryContainer, foreground: FamaColors.onSecondaryContainer);
  }
  if (haystack.contains('finance') || haystack.contains('loan') || haystack.contains('credit')) {
    return (icon: Icons.account_balance_outlined, background: FamaColors.surfaceContainer, foreground: FamaColors.onBackground);
  }
  if (haystack.contains('irrigation') || haystack.contains('water')) {
    return (icon: Icons.water_drop_outlined, background: FamaColors.primaryContainer, foreground: Colors.white);
  }
  if (haystack.contains('livestock') || haystack.contains('vet') || haystack.contains('poultry')) {
    return (icon: Icons.pets_outlined, background: FamaColors.tertiary, foreground: Colors.white);
  }
  return (icon: Icons.grass_outlined, background: FamaColors.primaryContainer, foreground: Colors.white);
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    final style = _iconFor(service);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FamaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FamaColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: style.background, borderRadius: BorderRadius.circular(12)),
            child: Icon(style.icon, color: style.foreground, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: FamaColors.outline),
                  ],
                ),
                if (service.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: FamaColors.onBackground.withOpacity(0.65), fontSize: 13),
                  ),
                ],
                if (service.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: service.tags.take(2).map((tag) {
                      return Text(
                        tag,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FamaColors.primary),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeedCustomPlanCard extends StatelessWidget {
  const _NeedCustomPlanCard({required this.onRequest});

  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FamaColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FamaColors.primary.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.psychology_outlined, color: FamaColors.primary, size: 36),
          const SizedBox(height: 12),
          Text('Need a custom plan?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Speak to a specialist for a tailor-made farm strategy.',
            textAlign: TextAlign.center,
            style: TextStyle(color: FamaColors.onBackground.withOpacity(0.65)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRequest,
            child: const Text('Find a Specialist'),
          ),
        ],
      ),
    );
  }
}

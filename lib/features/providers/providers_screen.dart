import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/network/asset_url.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/marketplace.dart';
import '../../models/provider.dart';
import '../../services/marketplace_service.dart';
import '../../services/provider_service.dart';
import '../marketplace/outlet_detail_screen.dart';
import '../shared/notification_bell.dart';
import 'provider_profile_screen.dart';

/// SafeBoda-style combined discovery: providers AND outlets on one map/list,
/// reusing the map/list toggle and distance-calc infrastructure originally
/// built for Stitch's "find_a_provider" screen, now widened to cover both
/// entity types a farmer wants to find nearby -- trusted outlets to buy
/// from, and specialists to ask for help.
enum _EntityFilter { all, providers, outlets }

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final _providerService = ProviderService();
  final _marketplaceService = MarketplaceService();
  final _searchController = TextEditingController();

  late Future<List<ProviderItem>> _providersFuture;
  late Future<List<Outlet>> _outletsFuture;
  Future<List<String>>? _specializationsFuture;

  _EntityFilter _entityFilter = _EntityFilter.all;
  String _selectedSpecialization = 'All';
  bool _showMap = false;
  Position? _myPosition;

  @override
  void initState() {
    super.initState();
    _specializationsFuture = _providerService.fetchExtensionServiceNames();
    _providersFuture = _loadProviders();
    _outletsFuture = _loadOutlets();
    _resolveLocation();
  }

  Future<void> _resolveLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return; // Silently skip distance display -- not a blocking requirement.
      }
      final position = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _myPosition = position);
    } catch (_) {
      // Location unavailable (emulator without mock location, permissions
      // off, etc.) -- the screen works fine without distances.
    }
  }

  Future<List<ProviderItem>> _loadProviders({String? search, String? specialization}) {
    return _providerService.fetchProviders(
      search: search,
      extensionService: (specialization != null && specialization != 'All') ? specialization : null,
    );
  }

  Future<List<Outlet>> _loadOutlets({String? search}) {
    // OutletController@index doesn't take a search param today -- filtering
    // outlets by name client-side keeps this screen simple for now.
    return _marketplaceService.fetchOutlets(lat: _myPosition?.latitude, lng: _myPosition?.longitude);
  }

  void _search() {
    setState(() {
      _providersFuture = _loadProviders(search: _searchController.text.trim(), specialization: _selectedSpecialization);
      _outletsFuture = _loadOutlets();
    });
  }

  void _selectSpecialization(String value) {
    setState(() {
      _selectedSpecialization = value;
      _providersFuture = _loadProviders(search: _searchController.text.trim(), specialization: value);
    });
  }

  double? _distanceKm(double? lat, double? lng) {
    if (_myPosition == null || lat == null || lng == null) return null;
    final meters = Geolocator.distanceBetween(_myPosition!.latitude, _myPosition!.longitude, lat, lng);
    return meters / 1000;
  }

  @override
  Widget build(BuildContext context) {
    final showProviders = _entityFilter != _EntityFilter.outlets;
    final showOutlets = _entityFilter != _EntityFilter.providers;
    final searchHint = _entityFilter == _EntityFilter.outlets
        ? 'Search for outlets...'
        : _entityFilter == _EntityFilter.providers
            ? 'Search for specialists...'
            : 'Search providers or outlets...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map_outlined),
            tooltip: _showMap ? 'List view' : 'Map view',
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
          const NotificationBellAction(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: FamaColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Entity-type toggle: which pins/cards actually show.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<_EntityFilter>(
              segments: const [
                ButtonSegment(value: _EntityFilter.all, label: Text('All')),
                ButtonSegment(value: _EntityFilter.providers, label: Text('Providers')),
                ButtonSegment(value: _EntityFilter.outlets, label: Text('Outlets')),
              ],
              selected: {_entityFilter},
              onSelectionChanged: (selection) => setState(() => _entityFilter = selection.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: FamaColors.primary,
                selectedForegroundColor: Colors.white,
              ),
            ),
          ),
          // Specialization chips only make sense when providers are showing.
          if (showProviders) ...[
            const SizedBox(height: 10),
            FutureBuilder<List<String>>(
              future: _specializationsFuture,
              builder: (context, snapshot) {
                final specializations = ['All', ...(snapshot.data ?? [])];
                return SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: specializations.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final value = specializations[index];
                      final selected = value == _selectedSpecialization;
                      return ChoiceChip(
                        label: Text(value),
                        selected: selected,
                        onSelected: (_) => _selectSpecialization(value),
                        selectedColor: FamaColors.primary,
                        backgroundColor: FamaColors.surfaceContainer,
                        labelStyle: TextStyle(color: selected ? Colors.white : FamaColors.onBackground, fontSize: 13),
                        side: BorderSide.none,
                      );
                    },
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<ProviderItem>>(
              future: _providersFuture,
              builder: (context, providerSnapshot) {
                return FutureBuilder<List<Outlet>>(
                  future: _outletsFuture,
                  builder: (context, outletSnapshot) {
                    final loading = providerSnapshot.connectionState == ConnectionState.waiting ||
                        outletSnapshot.connectionState == ConnectionState.waiting;
                    if (loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (providerSnapshot.hasError || outletSnapshot.hasError) {
                      return Center(child: Text('Could not load nearby results: ${providerSnapshot.error ?? outletSnapshot.error}'));
                    }
                    final providers = showProviders ? (providerSnapshot.data ?? []) : <ProviderItem>[];
                    final outlets = showOutlets ? (outletSnapshot.data ?? []) : <Outlet>[];

                    if (providers.isEmpty && outlets.isEmpty) {
                      return const Center(child: Text('Nothing found nearby yet.'));
                    }

                    return _showMap
                        ? _NearbyMap(providers: providers, outlets: outlets)
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              ...providers.map((p) => _ProviderCard(
                                    provider: p,
                                    distanceKm: _distanceKm(p.latitude, p.longitude),
                                  )),
                              ...outlets.map((o) => _OutletCard(
                                    outlet: o,
                                    distanceKm: _distanceKm(o.latitude, o.longitude),
                                  )),
                            ],
                          );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyMap extends StatelessWidget {
  const _NearbyMap({required this.providers, required this.outlets});

  final List<ProviderItem> providers;
  final List<Outlet> outlets;

  @override
  Widget build(BuildContext context) {
    final locatedProviders = providers.where((p) => p.latitude != null && p.longitude != null).toList();
    final locatedOutlets = outlets; // Outlet lat/lng is non-nullable already.

    if (locatedProviders.isEmpty && locatedOutlets.isEmpty) {
      return const Center(child: Text('No nearby results with a known location yet.'));
    }

    final centerLat = locatedProviders.isNotEmpty ? locatedProviders.first.latitude! : locatedOutlets.first.latitude;
    final centerLng = locatedProviders.isNotEmpty ? locatedProviders.first.longitude! : locatedOutlets.first.longitude;

    // Requires a Google Maps API key configured natively (see README.md) --
    // without it this renders a blank/grey map area but won't crash.
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: LatLng(centerLat, centerLng), zoom: 12),
      markers: {
        ...locatedProviders.map((p) => Marker(
              markerId: MarkerId('provider-${p.id}'),
              position: LatLng(p.latitude!, p.longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(title: p.name, snippet: p.extensionService ?? 'Provider'),
            )),
        ...locatedOutlets.map((o) => Marker(
              markerId: MarkerId('outlet-${o.id}'),
              position: LatLng(o.latitude, o.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(title: o.name, snippet: 'Outlet'),
            )),
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider, this.distanceKm});

  final ProviderItem provider;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final imageUrl = storageUrl(provider.imagePath);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProviderProfileScreen(providerId: provider.id)),
      ),
      child: Container(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: FamaColors.surfaceContainer,
                          child: const Icon(Icons.person_outline),
                        ),
                      )
                    : Container(
                        color: FamaColors.surfaceContainer,
                        child: const Icon(Icons.person_outline, color: FamaColors.primary),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _EntityBadge(label: 'Provider', color: FamaColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(provider.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  if (provider.extensionService != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        [provider.extensionService, if (distanceKm != null) '${distanceKm!.toStringAsFixed(1)} km away'].join(' • '),
                        style: TextStyle(color: FamaColors.onBackground.withOpacity(0.6), fontSize: 13),
                      ),
                    ),
                  if (provider.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: provider.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: FamaColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                            child: Text(tag, style: const TextStyle(fontSize: 11)),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutletCard extends StatelessWidget {
  const _OutletCard({required this.outlet, this.distanceKm});

  final Outlet outlet;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OutletDetailScreen(outletId: outlet.id)),
      ),
      child: Container(
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: FamaColors.secondaryContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.storefront, color: FamaColors.secondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _EntityBadge(label: 'Outlet', color: FamaColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(outlet.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      distanceKm != null ? '${distanceKm!.toStringAsFixed(1)} km away' : (outlet.description ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: FamaColors.onBackground.withOpacity(0.6), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntityBadge extends StatelessWidget {
  const _EntityBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

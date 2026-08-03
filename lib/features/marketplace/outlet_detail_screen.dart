import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/network/asset_url.dart';
import '../../core/network/launcher.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/marketplace.dart';
import '../../services/marketplace_service.dart';
import 'product_detail_screen.dart';

/// Matches the Stitch "outlet_detail" screen: hero, name/location,
/// description, a "Find Us" map + Get Directions, and "Available
/// Products" with category chips. FAMA's Outlet model has no image or
/// open/closed-hours field, so the "Open Now" badge and hero photo from
/// the mock are omitted rather than fabricated -- a plain icon hero is
/// used instead.
class OutletDetailScreen extends StatefulWidget {
  const OutletDetailScreen({super.key, required this.outletId});

  final int outletId;

  @override
  State<OutletDetailScreen> createState() => _OutletDetailScreenState();
}

class _OutletDetailScreenState extends State<OutletDetailScreen> {
  final _service = MarketplaceService();
  late Future<Outlet> _future;
  String _selectedTag = 'All';

  @override
  void initState() {
    super.initState();
    _future = _service.fetchOutlet(widget.outletId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: FamaColors.background, elevation: 0),
      body: FutureBuilder<Outlet>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Could not load this outlet: ${snapshot.error}'));
          }
          final outlet = snapshot.data!;
          final tagSet = <String>{};
          for (final p in outlet.products) {
            tagSet.addAll(p.tags);
          }
          final chips = ['All', ...tagSet.toList()..sort()];
          final visibleProducts = _selectedTag == 'All'
              ? outlet.products
              : outlet.products.where((p) => p.tags.contains(_selectedTag)).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: FamaColors.primaryContainer.withOpacity(0.2),
                    child: const Icon(Icons.storefront, size: 56, color: FamaColors.primary),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(outlet.name, style: Theme.of(context).textTheme.headlineLarge),
                    if (outlet.contact != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.call_outlined, size: 16, color: FamaColors.primary),
                          const SizedBox(width: 6),
                          Text(outlet.contact!, style: const TextStyle(color: FamaColors.primary)),
                        ],
                      ),
                    ],
                    if (outlet.description != null) ...[
                      const SizedBox(height: 12),
                      Text(outlet.description!, style: const TextStyle(height: 1.5)),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Find Us', style: Theme.of(context).textTheme.headlineMedium),
                        TextButton.icon(
                          onPressed: () => launchDirections(outlet.latitude, outlet.longitude),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Get Directions'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 180,
                        child: IgnorePointer(
                          // Static preview -- tapping "Get Directions" above
                          // opens the full interactive maps app instead.
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(outlet.latitude, outlet.longitude),
                              zoom: 14,
                            ),
                            markers: {
                              Marker(markerId: const MarkerId('outlet'), position: LatLng(outlet.latitude, outlet.longitude)),
                            },
                            zoomControlsEnabled: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Available Products', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: chips.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final tag = chips[index];
                          final selected = tag == _selectedTag;
                          return ChoiceChip(
                            label: Text(tag),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedTag = tag),
                            selectedColor: FamaColors.primary,
                            backgroundColor: FamaColors.surfaceContainer,
                            labelStyle: TextStyle(color: selected ? Colors.white : FamaColors.onBackground),
                            side: BorderSide.none,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (visibleProducts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('No products in this category yet.')),
                      )
                    else
                      ...visibleProducts.map((p) => _OutletProductRow(product: p)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OutletProductRow extends StatelessWidget {
  const _OutletProductRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = storageUrl(product.imagePath);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
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
                width: 52,
                height: 52,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: FamaColors.surfaceContainer,
                          child: const Icon(Icons.eco_outlined, size: 18, color: FamaColors.primary),
                        ),
                      )
                    : Container(
                        color: FamaColors.surfaceContainer,
                        child: const Icon(Icons.eco_outlined, size: 18, color: FamaColors.primary),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    'UGX ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: FamaColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline, color: FamaColors.secondaryContainer),
          ],
        ),
      ),
    );
  }
}

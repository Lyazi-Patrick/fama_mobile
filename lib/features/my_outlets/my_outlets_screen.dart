import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/network/asset_url.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/marketplace.dart';
import '../../services/marketplace_service.dart';
import 'add_edit_outlet_screen.dart';
import 'add_edit_product_screen.dart';

class MyOutletsScreen extends StatefulWidget {
  const MyOutletsScreen({super.key});

  @override
  State<MyOutletsScreen> createState() => _MyOutletsScreenState();
}

class _MyOutletsScreenState extends State<MyOutletsScreen> {
  final _service = MarketplaceService();
  late Future<List<Outlet>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchMyOutlets();
  }

  void _reload() => setState(() => _future = _service.fetchMyOutlets());

  Future<void> _addOutlet() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditOutletScreen()),
    );
    if (created == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Outlets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addOutlet,
        icon: const Icon(Icons.add),
        label: const Text('Add Outlet'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Outlet>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Could not load your outlets: ${snapshot.error}'));
            }
            final outlets = snapshot.data ?? [];
            if (outlets.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text("You haven't added an outlet yet.\nTap 'Add Outlet' to get started.", textAlign: TextAlign.center)),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: outlets.length,
              itemBuilder: (context, index) => _OutletManagementCard(
                outlet: outlets[index],
                onChanged: _reload,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OutletManagementCard extends StatelessWidget {
  const _OutletManagementCard({required this.outlet, required this.onChanged});

  final Outlet outlet;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: FamaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FamaColors.outlineVariant.withOpacity(0.4)),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(outlet.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${outlet.products.length} product${outlet.products.length == 1 ? '' : 's'}'),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: FamaColors.primaryContainer.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.storefront, color: FamaColors.primary),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => AddEditOutletScreen(outlet: outlet)),
                    );
                    if (updated == true) onChanged();
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Outlet'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final added = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => AddEditProductScreen(outletId: outlet.id)),
                    );
                    if (added == true) onChanged();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Product'),
                ),
              ],
            ),
          ),
          if (outlet.products.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('No products in this outlet yet.'),
            )
          else
            ...outlet.products.map((p) => _ProductManagementRow(
                  outlet: outlet,
                  product: p,
                  onChanged: onChanged,
                )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ProductManagementRow extends StatelessWidget {
  const _ProductManagementRow({required this.outlet, required this.product, required this.onChanged});

  final Outlet outlet;
  final Product product;
  final VoidCallback onChanged;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this product?'),
        content: Text('"${product.name}" will be removed from your outlet permanently.'),
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
      await MarketplaceService().deleteProduct(product.id);
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = storageUrl(product.imagePath);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: imageUrl != null
                  ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                  : Container(color: FamaColors.surfaceContainer, child: const Icon(Icons.eco_outlined, size: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Text('UGX ${product.price.toStringAsFixed(0)}', style: const TextStyle(color: FamaColors.primary, fontSize: 13)),
                    const SizedBox(width: 8),
                    _StatusChip(status: product.status),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => AddEditProductScreen(outletId: outlet.id, product: product)),
              );
              if (updated == true) onChanged();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: FamaColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status == 'approved' ? FamaColors.primary : (status == 'rejected' ? FamaColors.error : FamaColors.outline);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

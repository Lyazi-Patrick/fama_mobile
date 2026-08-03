import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/network/asset_url.dart';
import '../../core/network/launcher.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/marketplace.dart';
import '../../services/marketplace_service.dart';
import 'outlet_detail_screen.dart';

/// Matches the Stitch "product_detail" screen. A few fields Stitch's mock
/// shows (stock qty, harvest date, delivery estimate, star rating) don't
/// exist in FAMA's real Product model or have no review system backing
/// them -- rather than invent numbers, this screen simply omits those
/// specs blocks instead of showing fabricated data.
///
/// Primary action is "Contact Provider" (matches Stitch's own button
/// label) rather than a cart/checkout flow, since whether marketplace
/// needs real in-app ordering is still an open product decision.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _service = MarketplaceService();
  late Future<Product> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Product>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Could not load this product: ${snapshot.error}'));
          }
          final product = snapshot.data!;
          final imageUrl = storageUrl(product.imagePath);
          final outlet = product.outlet;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: FamaColors.background,
                    expandedHeight: 280,
                    flexibleSpace: FlexibleSpaceBar(
                      background: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(color: FamaColors.surfaceContainer),
                            )
                          : Container(
                              color: FamaColors.surfaceContainer,
                              child: const Icon(Icons.eco_outlined, size: 64, color: FamaColors.primary),
                            ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.tags.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: FamaColors.primaryContainer.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                product.tags.first,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: FamaColors.primary),
                              ),
                            ),
                          Text(product.name, style: Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: 8),
                          Text(
                            'UGX ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: FamaColors.primary),
                          ),
                          const SizedBox(height: 20),
                          if (product.description != null) ...[
                            Text('Product Description', style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text(product.description!, style: const TextStyle(height: 1.5)),
                            const SizedBox(height: 20),
                          ],
                          if (outlet != null) _OutletCard(outlet: outlet),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomActionBar(outlet: outlet),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OutletCard extends StatelessWidget {
  const _OutletCard({required this.outlet});

  final Outlet outlet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FamaColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: FamaColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.storefront, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outlet.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                if (outlet.description != null)
                  Text(
                    outlet.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: FamaColors.onBackground.withOpacity(0.6), fontSize: 13),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => OutletDetailScreen(outletId: outlet.id)),
            ),
            child: const Text('View Outlet'),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.outlet});

  final Outlet? outlet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: FamaColors.background.withOpacity(0.96),
        border: const Border(top: BorderSide(color: FamaColors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: (outlet?.contact != null && outlet!.contact!.isNotEmpty)
                    ? () => launchPhoneCall(outlet!.contact!)
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('This outlet has no contact number on file.')),
                        ),
                icon: const Icon(Icons.chat, size: 20),
                label: const Text('Contact Provider'),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: FamaColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                // Whether "buy" means real in-app ordering or just contacting
                // the outlet is still an open product decision -- this button
                // is honest about not doing anything yet rather than faking
                // a cart that doesn't lead anywhere.
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('In-app ordering is coming soon -- use Contact Provider for now.')),
                ),
                icon: const Icon(Icons.shopping_cart_outlined, color: FamaColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

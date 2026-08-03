import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/asset_url.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/marketplace.dart';
import '../../services/marketplace_service.dart';
import '../auth/auth_provider.dart';
import '../my_outlets/my_outlets_screen.dart';
import '../shared/notification_bell.dart';
import 'featured_banner.dart';
import 'product_detail_screen.dart';

/// Matches the Stitch "marketplace_list" screen: search bar with a filter
/// icon, horizontally-scrolling category chips (derived from real product
/// tags, not hardcoded), a promoted-ad banner, and a 2-column product grid.
/// Deliberately shows PRODUCTS ONLY (GET /api/products) -- outlets and
/// services have their own screens, this one doesn't mix them in.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _service = MarketplaceService();
  final _searchController = TextEditingController();
  late Future<List<Product>> _future;
  String _selectedTag = 'All';
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Product>> _load({String? search, String? tag}) async {
    final products = await _service.fetchProducts(
      search: search,
      tag: (tag != null && tag != 'All') ? tag : null,
    );
    // Derive filter chips from whatever tags are actually present on real
    // products, rather than guessing category names that may not match
    // what's really in the database.
    if (tag == null || tag == 'All') {
      final tagSet = <String>{};
      for (final p in products) {
        tagSet.addAll(p.tags);
      }
      _availableTags = tagSet.toList()..sort();
    }
    return products;
  }

  void _search() {
    setState(() => _future = _load(search: _searchController.text.trim(), tag: _selectedTag));
  }

  void _selectTag(String tag) {
    setState(() {
      _selectedTag = tag;
      _future = _load(search: _searchController.text.trim(), tag: tag);
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: FamaColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter products', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', ..._availableTags].map((tag) {
                final selected = tag == _selectedTag;
                return ChoiceChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (_) {
                    Navigator.pop(context);
                    _selectTag(tag);
                  },
                  selectedColor: FamaColors.primary,
                  labelStyle: TextStyle(color: selected ? Colors.white : FamaColors.onBackground),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDealer = context.watch<AuthProvider>().user?.isDealer ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: const [NotificationBellAction()],
      ),
      // Only dealers can list products, and doing so requires picking (or
      // creating) an outlet first -- that flow lives in My Outlets, so this
      // FAB routes there rather than trying to ask "which outlet?" inline.
      floatingActionButton: isDealer
          ? FloatingActionButton(
              backgroundColor: FamaColors.secondaryContainer,
              foregroundColor: FamaColors.onSecondaryContainer,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyOutletsScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _future = _load(tag: _selectedTag)),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _search(),
                        decoration: InputDecoration(
                          hintText: 'Search seeds, tools, or fertilizers...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: FamaColors.surfaceContainer,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _showFilterSheet,
                      icon: const Icon(Icons.tune),
                      style: IconButton.styleFrom(
                        backgroundColor: FamaColors.surfaceContainer,
                        foregroundColor: FamaColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<Product>>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox(height: 44);
                  final chips = ['All', ..._availableTags];
                  return SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: chips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final tag = chips[index];
                        final selected = tag == _selectedTag;
                        return ChoiceChip(
                          label: Text(tag),
                          selected: selected,
                          onSelected: (_) => _selectTag(tag),
                          selectedColor: FamaColors.primary,
                          backgroundColor: FamaColors.surfaceContainer,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : FamaColors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: FeaturedBanner(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              sliver: FutureBuilder<List<Product>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(child: Text('Could not load products: ${snapshot.error}')),
                      ),
                    );
                  }
                  final products = snapshot.data ?? [];
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No products found.')),
                      ),
                    );
                  }
                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 268, // fixed height -- see _ProductCard for why this fits
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ProductCard(product: products[index]),
                      childCount: products.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = storageUrl(product.imagePath);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: FamaColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FamaColors.outlineVariant.withOpacity(0.4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: FamaColors.surfaceContainer,
                            child: const Icon(Icons.eco_outlined, color: FamaColors.primary),
                          ),
                        )
                      : Container(
                          color: FamaColors.surfaceContainer,
                          child: const Icon(Icons.eco_outlined, size: 32, color: FamaColors.primary),
                        ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.tags.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: FamaColors.primaryContainer.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.tags.first,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: FamaColors.primary),
                            ),
                          ),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'UGX ${product.price.toStringAsFixed(0)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: FamaColors.primary),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: FamaColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_cart_outlined, size: 15, color: FamaColors.onSecondaryContainer),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

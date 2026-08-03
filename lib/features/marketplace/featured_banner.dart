import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/network/asset_url.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/ad.dart';
import '../../services/ad_service.dart';

/// Matches the "Featured Service Banner" pattern from the Stitch
/// services_list screen (full-bleed image, dark gradient, PROMOTED pill,
/// title + subtitle) -- reused here for ads (GET /api/ads) so both the
/// Marketplace and Services screens share one consistent promoted-content
/// slot instead of the tall auto-scrolling carousel from before.
class FeaturedBanner extends StatefulWidget {
  const FeaturedBanner({super.key});

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  final _service = AdService();
  late Future<List<AdItem>> _future;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchAds();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdItem>>(
      future: _future,
      builder: (context, snapshot) {
        // Ads are promotional, not core -- never show a loading spinner or
        // error for this; just collapse to nothing until there's real data.
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final ads = snapshot.data ?? [];
        if (ads.isEmpty) return const SizedBox.shrink();

        final ad = ads[_index % ads.length];
        final imageUrl = storageUrl(ad.imagePath);

        return GestureDetector(
          onTap: ads.length > 1 ? () => setState(() => _index++) : null,
          child: Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: FamaColors.primaryContainer),
                  )
                else
                  Container(color: FamaColors.primaryContainer),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                      stops: [0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: FamaColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'PROMOTED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: FamaColors.onSecondaryContainer,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ad.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (ads.length > 1)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Row(
                      children: List.generate(
                        ads.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _index % ads.length
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

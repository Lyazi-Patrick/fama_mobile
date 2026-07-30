import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/network/asset_url.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/ad.dart';
import '../../services/ad_service.dart';

/// Auto-scrolling ad carousel shown at the top of the marketplace.
/// Mirrors AdCarousel.php / Carousel.php on the web (GET /api/ads).
class AdCarousel extends StatefulWidget {
  const AdCarousel({super.key});

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  final _service = AdService();
  late Future<List<AdItem>> _future;
  final _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    _future = _service.fetchAds();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdItem>>(
      future: _future,
      builder: (context, snapshot) {
        // Fail silently -- an ad carousel is decoration, not core function,
        // so don't block or clutter the marketplace screen if this errors.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 140);
        }
        final ads = snapshot.data ?? [];
        if (ads.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (storageUrl(ad.imagePath) != null)
                        CachedNetworkImage(
                          imageUrl: storageUrl(ad.imagePath)!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(color: FamaColors.surfaceContainer),
                        )
                      else
                        Container(color: FamaColors.surfaceContainer),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                          child: Text(
                            ad.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

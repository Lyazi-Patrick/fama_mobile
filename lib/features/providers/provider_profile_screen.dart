import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/network/asset_url.dart';
import '../../core/network/launcher.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/provider.dart';
import '../../services/provider_service.dart';
import '../service_requests/service_request_form_screen.dart';
import '../shared/notification_bell.dart';

/// Matches the Stitch "provider_profile" screen. Fields the mock shows but
/// FAMA has no real data for -- star rating/review count, years of
/// experience, jobs-done count, a precise district/region address -- are
/// omitted rather than invented. "Verified Provider" is shown for real,
/// though: every provider returned by GET /api/providers already has
/// status=approved, so that badge reflects an actual admin approval, not
/// a fabricated stat. There's also no "Call" button since WorkerProfile
/// only stores a WhatsApp number, not a plain phone number.
class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key, required this.providerId});

  final int providerId;

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _service = ProviderService();
  late Future<ProviderItem> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchProvider(widget.providerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FamaColors.background,
        elevation: 0,
        actions: const [NotificationBellAction()],
      ),
      body: FutureBuilder<ProviderItem>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Could not load this provider: ${snapshot.error}'));
          }
          final provider = snapshot.data!;
          final imageUrl = storageUrl(provider.imagePath);
          final aboutText = provider.bio ?? provider.briefProfile;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: FamaColors.surfaceContainer,
                                child: const Icon(Icons.person, size: 64, color: FamaColors.primary),
                              ),
                            )
                          : Container(
                              color: FamaColors.surfaceContainer,
                              child: const Icon(Icons.person, size: 64, color: FamaColors.primary),
                            ),
                    ),
                  ),
                  if (provider.status == 'approved')
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: FamaColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Verified Provider', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(provider.name, style: Theme.of(context).textTheme.headlineLarge),
              if (provider.extensionService != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.agriculture_outlined, size: 16, color: FamaColors.primary),
                    const SizedBox(width: 6),
                    Text(provider.extensionService!, style: const TextStyle(color: FamaColors.primary)),
                  ],
                ),
              ],
              if (provider.tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('SPECIALIZATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: FamaColors.onBackground.withOpacity(0.6), letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: FamaColors.primaryContainer.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(tag, style: const TextStyle(color: FamaColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    );
                  }).toList(),
                ),
              ],
              if (aboutText != null && aboutText.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('ABOUT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: FamaColors.onBackground.withOpacity(0.6), letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FamaColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(aboutText, style: const TextStyle(height: 1.5)),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                icon: const Icon(Icons.send_outlined, size: 20),
                label: const Text('Request Service'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ServiceRequestFormScreen(
                      providerUserId: provider.userId,
                      providerName: provider.name,
                    ),
                  ),
                ),
              ),
              if (provider.whatsappNumber != null && provider.whatsappNumber!.isNotEmpty) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: Text('WhatsApp ${provider.name.split(' ').first}'),
                  onPressed: () => launchWhatsApp(provider.whatsappNumber!),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

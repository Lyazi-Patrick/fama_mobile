import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/fama_theme.dart';
import '../auth/auth_provider.dart';
import 'role_upgrade_form_screen.dart';

/// Landing step for role upgrades: pick which role to apply for, since
/// the two paths need different fields (mirrors DealerUpgradeRequestForm.php
/// and WorkerUpgradeRequestForm.php being separate forms on the web).
/// Only shows paths the user hasn't already achieved.
class RoleUpgradeScreen extends StatelessWidget {
  const RoleUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDealer = user?.isDealer ?? false;
    final isExtensionWorker = user?.isExtensionWorker ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Your Role')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose the role you want to apply for',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (!isDealer)
            _RoleCard(
              icon: Icons.storefront_outlined,
              title: 'Become a Dealer',
              description: 'List and sell seeds, tools, fertilizers, and other products through your own outlet.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoleUpgradeFormScreen(role: 'dealer')),
              ),
            ),
          if (!isDealer && !isExtensionWorker) const SizedBox(height: 12),
          if (!isExtensionWorker)
            _RoleCard(
              icon: Icons.eco_outlined,
              title: 'Become an Extension Worker',
              description: 'Offer advisory services and get discovered by farmers looking for specialists nearby.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoleUpgradeFormScreen(role: 'extension_worker')),
              ),
            ),
          if (isDealer && isExtensionWorker)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline, color: FamaColors.primary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "You've already got every available role.",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: FamaColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: FamaColors.outlineVariant.withOpacity(0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: FamaColors.primaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: FamaColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(color: FamaColors.onBackground.withOpacity(0.65))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: FamaColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/fama_theme.dart';
import '../auth/auth_provider.dart';
import '../role_upgrade/role_upgrade_screen.dart';
import '../subscriptions/subscriptions_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: FamaColors.primaryContainer.withOpacity(0.2),
                child: Text(
                  (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                  style: textTheme.headlineMedium?.copyWith(color: FamaColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '', style: textTheme.headlineMedium),
                    Text(user?.email ?? '', style: textTheme.bodyMedium),
                    if (user?.roles.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 6,
                          children: user!.roles
                              .map((r) => Chip(
                                    label: Text(r, style: const TextStyle(fontSize: 12)),
                                    backgroundColor: FamaColors.primaryContainer.withOpacity(0.15),
                                    side: BorderSide.none,
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Account', style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          _ProfileTile(
            icon: Icons.trending_up,
            title: 'Upgrade your role',
            subtitle: 'Become a dealer or extension worker',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RoleUpgradeScreen()),
            ),
          ),
          _ProfileTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Subscription plans',
            subtitle: 'Manage your FAMA subscription',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
            ),
          ),
          _ProfileTile(
            icon: Icons.storefront_outlined,
            title: 'My outlets & products',
            subtitle: 'Manage what you sell',
            onTap: () {
              // TODO: wire to a "My Outlets" screen (GET /api/my-outlets).
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('My Outlets screen coming soon')),
              );
            },
          ),
          _ProfileTile(
            icon: Icons.campaign_outlined,
            title: 'Submit an ad',
            subtitle: 'Advertise on the FAMA home screen',
            onTap: () {
              // TODO: wire to an "Ad Request" form (POST /api/ads).
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ad submission screen coming soon')),
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(color: FamaColors.outlineVariant),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => auth.logout(),
            style: OutlinedButton.styleFrom(
              foregroundColor: FamaColors.error,
              side: const BorderSide(color: FamaColors.error),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: FamaColors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: FamaColors.primaryContainer.withOpacity(0.15),
          child: Icon(icon, color: FamaColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

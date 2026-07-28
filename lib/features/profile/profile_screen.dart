import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(user?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(user?.email ?? ''),
          if (user?.roles.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Role: ${user!.roles.join(", ")}'),
            ),
          const SizedBox(height: 24),
          const Divider(),
          const Text('TODO: link to Role Upgrade, My Outlets/Services, Ad requests'),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => auth.logout(),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

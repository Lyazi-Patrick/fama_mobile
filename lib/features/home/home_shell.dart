import 'package:flutter/material.dart';
import '../marketplace/product_list_screen.dart';
import '../providers/providers_screen.dart';
import '../service_requests/service_requests_screen.dart';
import '../services/services_screen.dart';
import '../profile/profile_screen.dart';

/// Bottom-nav shell shown once the user is logged in. Mirrors the FAMA
/// website's main sections: marketplace, extension services, find a
/// provider (map), service requests, profile.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    ProductListScreen(),
    ServicesScreen(),
    ProvidersScreen(),
    ServiceRequestsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.agriculture), label: 'Services'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Providers'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

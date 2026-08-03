import 'package:flutter/material.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/plan.dart';
import '../../services/subscription_service.dart';
import 'checkout_screen.dart';

/// Real plans (GET /api/plans) + your current subscription status
/// (GET /api/subscriptions/mine). Tapping "Subscribe" opens CheckoutScreen
/// for the mobile money flow.
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final _service = SubscriptionService();
  late Future<List<Plan>> _plansFuture;
  late Future<List<SubscriptionItem>> _mySubsFuture;

  @override
  void initState() {
    super.initState();
    _plansFuture = _service.fetchPlans();
    _mySubsFuture = _service.fetchMySubscriptions();
  }

  void _refresh() {
    setState(() {
      _plansFuture = _service.fetchPlans();
      _mySubsFuture = _service.fetchMySubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<List<SubscriptionItem>>(
              future: _mySubsFuture,
              builder: (context, snapshot) {
                final subs = snapshot.data ?? [];
                final active = subs.where((s) => s.status == 'active').toList();
                if (active.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FamaColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: FamaColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You have an active ${active.first.role} subscription.',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            FutureBuilder<List<Plan>>(
              future: _plansFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text('Could not load plans: ${snapshot.error}')),
                  );
                }
                final plans = snapshot.data ?? [];
                if (plans.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No subscription plans are available yet.')),
                  );
                }
                return Column(
                  children: plans.map((plan) => _PlanCard(plan: plan)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FamaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FamaColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: FamaColors.secondaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  plan.targetRole,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: FamaColors.secondary),
                ),
              ),
            ],
          ),
          if (plan.description != null) ...[
            const SizedBox(height: 8),
            Text(plan.description!, style: TextStyle(color: FamaColors.onBackground.withOpacity(0.65))),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UGX ${plan.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: FamaColors.primary),
                  ),
                  if (plan.duration != null)
                    Text('per ${plan.duration}', style: TextStyle(color: FamaColors.onBackground.withOpacity(0.6), fontSize: 12)),
                ],
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CheckoutScreen(plan: plan)),
                ),
                child: const Text('Subscribe'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/plan.dart';
import '../../services/subscription_service.dart';

/// Mobile money checkout for a subscription plan. Note: the backend's
/// POST /api/subscriptions currently just creates a 'pending' record --
/// the actual mobile money charge (Airtel/MTN) still needs to be wired
/// into SubscriptionController@store on the Laravel side (flagged there
/// as a TODO). This screen is built to work the moment that's connected;
/// right now it will show "pending" rather than actually charge anyone.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.plan});

  final Plan plan;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _service = SubscriptionService();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _submitted = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await _service.subscribe(planId: widget.plan.id, phoneNumber: _phoneController.text.trim());
      setState(() => _submitted = true);
    } catch (e) {
      setState(() => _errorMessage = 'Could not start the payment. Please check your number and try again.');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_top, color: FamaColors.primary, size: 56),
                const SizedBox(height: 16),
                Text('Payment initiated', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text(
                  "Check your phone to approve the mobile money prompt. Your subscription will activate once payment is confirmed.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to Profile'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FamaColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.plan.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        'UGX ${widget.plan.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: FamaColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile money number',
                    hintText: '07XXXXXXXX',
                    prefixIcon: Icon(Icons.phone_android_outlined),
                  ),
                  validator: (v) => (v == null || v.length < 9) ? 'Enter a valid phone number' : null,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FamaColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_errorMessage!, style: const TextStyle(color: FamaColors.error)),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Pay UGX ${widget.plan.amount.toStringAsFixed(0)}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/fama_theme.dart';
import '../../services/service_request_api_service.dart';

/// Mirrors ServiceRequestForm.php: a farmer sends a request to a specific
/// extension worker (identified by their User id, not their WorkerProfile
/// id -- see ServiceRequestController@store on the backend).
class ServiceRequestFormScreen extends StatefulWidget {
  const ServiceRequestFormScreen({
    super.key,
    required this.providerUserId,
    required this.providerName,
  });

  final int providerUserId;
  final String providerName;

  @override
  State<ServiceRequestFormScreen> createState() => _ServiceRequestFormScreenState();
}

class _ServiceRequestFormScreenState extends State<ServiceRequestFormScreen> {
  final _service = ServiceRequestApiService();
  final _descriptionController = TextEditingController();
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
      await _service.create(
        extensionWorkerId: widget.providerUserId,
        description: _descriptionController.text.trim(),
      );
      setState(() => _submitted = true);
    } catch (e) {
      setState(() => _errorMessage = 'Could not send your request. Please try again.');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request Sent')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: FamaColors.primary, size: 56),
                const SizedBox(height: 16),
                Text('Request sent to ${widget.providerName}', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text(
                  "You'll be notified once they respond. You can track this under Requests.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Request Service from ${widget.providerName}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Describe what you need help with',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Be specific -- crop type, symptoms, timing -- so ${widget.providerName} can respond well.',
                  style: TextStyle(color: FamaColors.onBackground.withOpacity(0.6)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'e.g. My tomato plants have yellowing leaves and I\'m not sure if it\'s a nutrient deficiency or disease...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Please add a bit more detail' : null,
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
                      : const Text('Send Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

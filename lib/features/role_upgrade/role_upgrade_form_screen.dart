import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/fama_theme.dart';
import '../../services/role_upgrade_service.dart';

/// One form, two shapes: 'dealer' and 'extension_worker' need different
/// fields, but both submit to the same POST /api/role-upgrade-requests
/// endpoint with `requested_role` set accordingly (mirrors
/// DealerUpgradeRequestForm.php / WorkerUpgradeRequestForm.php on the web).
class RoleUpgradeFormScreen extends StatefulWidget {
  const RoleUpgradeFormScreen({super.key, required this.role});

  /// 'dealer' or 'extension_worker'
  final String role;

  @override
  State<RoleUpgradeFormScreen> createState() => _RoleUpgradeFormScreenState();
}

class _RoleUpgradeFormScreenState extends State<RoleUpgradeFormScreen> {
  final _service = RoleUpgradeService();
  final _formKey = GlobalKey<FormState>();
  final _ninController = TextEditingController();
  final _extensionServiceController = TextEditingController();
  final _briefProfileController = TextEditingController();

  File? _license;
  File? _identityCard;
  File? _profilePhoto;
  File? _supportingDocuments;

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _submitted = false;

  bool get _isDealer => widget.role == 'dealer';

  Future<void> _pickFile(void Function(File) onPicked) async {
    final picker = ImagePicker();
    // image_picker only handles photos -- fine for a photographed ID/license
    // in the field, but a real file_picker package would be needed if you
    // want native PDF uploads from the phone's Files app.
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) onPicked(File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await _service.submit(
        requestedRole: widget.role,
        nin: _ninController.text.trim(),
        extensionService: _isDealer ? null : _extensionServiceController.text.trim(),
        briefProfile: _isDealer ? null : _briefProfileController.text.trim(),
        license: _license,
        identityCard: _identityCard,
        profilePhoto: _profilePhoto,
        supportingDocuments: _supportingDocuments,
      );
      setState(() => _submitted = true);
    } catch (e) {
      setState(() => _errorMessage = 'Could not submit your request. Please check your details and try again.');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: Text(_isDealer ? 'Dealer Application' : 'Extension Worker Application')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: FamaColors.primary, size: 56),
                const SizedBox(height: 16),
                Text('Application submitted', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text(
                  "We'll review your application and notify you once it's approved.",
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
      appBar: AppBar(title: Text(_isDealer ? 'Dealer Application' : 'Extension Worker Application')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isDealer
                      ? 'Tell us about your business so we can verify and approve your dealer account.'
                      : 'Tell us about your expertise so farmers can find and trust you.',
                  style: TextStyle(color: FamaColors.onBackground.withOpacity(0.7)),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _ninController,
                  decoration: const InputDecoration(
                    labelText: 'National ID Number (NIN)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required for verification' : null,
                ),
                if (!_isDealer) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _extensionServiceController,
                    decoration: const InputDecoration(
                      labelText: 'Area of specialization (e.g. Agronomy, Veterinary)',
                      prefixIcon: Icon(Icons.agriculture_outlined),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _briefProfileController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Brief profile',
                      hintText: 'Describe your experience and how you can help farmers...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ],
                const SizedBox(height: 24),
                Text('Documents', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Clear photos of each document. These are reviewed by our team before approval.',
                  style: TextStyle(color: FamaColors.onBackground.withOpacity(0.6), fontSize: 13),
                ),
                const SizedBox(height: 12),
                _FilePickerTile(
                  label: 'National ID / Identity Card',
                  file: _identityCard,
                  onPick: () => _pickFile((f) => setState(() => _identityCard = f)),
                ),
                _FilePickerTile(
                  label: _isDealer ? 'Business License' : 'Professional License / Certificate',
                  file: _license,
                  onPick: () => _pickFile((f) => setState(() => _license = f)),
                ),
                _FilePickerTile(
                  label: 'Profile Photo',
                  file: _profilePhoto,
                  onPick: () => _pickFile((f) => setState(() => _profilePhoto = f)),
                ),
                _FilePickerTile(
                  label: 'Supporting Documents (optional)',
                  file: _supportingDocuments,
                  onPick: () => _pickFile((f) => setState(() => _supportingDocuments = f)),
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
                      : const Text('Submit Application'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilePickerTile extends StatelessWidget {
  const _FilePickerTile({required this.label, required this.file, required this.onPick});

  final String label;
  final File? file;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FamaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FamaColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            file != null ? Icons.check_circle : Icons.upload_file_outlined,
            color: file != null ? FamaColors.primary : FamaColors.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              file != null ? '$label — selected' : label,
              style: TextStyle(color: file != null ? FamaColors.primary : FamaColors.onBackground),
            ),
          ),
          TextButton(onPressed: onPick, child: Text(file != null ? 'Change' : 'Upload')),
        ],
      ),
    );
  }
}

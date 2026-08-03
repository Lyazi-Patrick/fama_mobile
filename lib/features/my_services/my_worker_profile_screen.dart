import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/network/asset_url.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/provider.dart';
import '../../services/provider_service.dart';
import '../shared/tag_multi_select.dart';

/// Mirrors WorkerServiceForm.php's profile section / the "my profile"
/// half of a worker's account -- bio, specialization, WhatsApp, photo,
/// and the tags shown on their public Provider Profile.
class MyWorkerProfileScreen extends StatefulWidget {
  const MyWorkerProfileScreen({super.key});

  @override
  State<MyWorkerProfileScreen> createState() => _MyWorkerProfileScreenState();
}

class _MyWorkerProfileScreenState extends State<MyWorkerProfileScreen> {
  final _service = ProviderService();
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _briefProfileController = TextEditingController();
  final _extensionServiceController = TextEditingController();
  final _whatsappController = TextEditingController();

  File? _pickedImage;
  String? _existingImagePath;
  Set<int> _selectedTagIds = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _service.fetchMyProfile();
      if (profile != null) {
        _bioController.text = profile.bio ?? '';
        _briefProfileController.text = profile.briefProfile ?? '';
        _extensionServiceController.text = profile.extensionService ?? '';
        _whatsappController.text = profile.whatsappNumber ?? '';
        _existingImagePath = profile.imagePath;
        // Note: tags come back as names from this endpoint, not ids, so we
        // can't pre-check them in the id-based picker without an extra
        // name->id lookup. Good enough for now -- re-picking tags on edit
        // simply starts fresh rather than showing prior selections checked.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load your profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await _service.updateMyProfile(
        bio: _bioController.text.trim(),
        briefProfile: _briefProfileController.text.trim(),
        extensionService: _extensionServiceController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        image: _pickedImage,
        tagIds: _selectedTagIds.isEmpty ? null : _selectedTagIds.toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not save your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final existingImageUrl = storageUrl(_existingImagePath);

    return Scaffold(
      appBar: AppBar(title: const Text('My Provider Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: ClipOval(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : existingImageUrl != null
                                ? CachedNetworkImage(imageUrl: existingImageUrl, fit: BoxFit.cover)
                                : Container(
                                    color: FamaColors.surfaceContainer,
                                    child: const Icon(Icons.add_a_photo_outlined, color: FamaColors.primary),
                                  ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(onPressed: _pickImage, child: const Text('Change photo')),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _extensionServiceController,
                  decoration: const InputDecoration(labelText: 'Area of specialization', prefixIcon: Icon(Icons.agriculture_outlined)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'WhatsApp number', prefixIcon: Icon(Icons.chat_bubble_outline)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _briefProfileController,
                  decoration: const InputDecoration(labelText: 'Short tagline'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'About you', alignLabelWithHint: true),
                ),
                const SizedBox(height: 20),
                Text('Specializations', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                TagMultiSelect(
                  selectedIds: _selectedTagIds,
                  onChanged: (ids) => setState(() => _selectedTagIds = ids),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(color: FamaColors.error)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

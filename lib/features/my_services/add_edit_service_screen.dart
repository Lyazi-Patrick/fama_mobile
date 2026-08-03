import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/service.dart';
import '../../services/service_api_service.dart';
import '../shared/tag_multi_select.dart';

class AddEditServiceScreen extends StatefulWidget {
  const AddEditServiceScreen({super.key, this.service});

  /// Pass an existing service to edit it; leave null to create a new one.
  final ServiceItem? service;

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _service = ServiceApiService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  File? _pickedImage;
  Set<int> _selectedTagIds = {};
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name);
    _descriptionController = TextEditingController(text: widget.service?.description);
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
      if (_isEditing) {
        await _service.updateService(
          widget.service!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          image: _pickedImage,
          tagIds: _selectedTagIds.isEmpty ? null : _selectedTagIds.toList(),
        );
      } else {
        await _service.createService(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          image: _pickedImage,
          tagIds: _selectedTagIds.toList(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _errorMessage = 'Could not save this service. Please check your details and try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Service' : 'Add Service')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: FamaColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FamaColors.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedImage != null
                        ? Image.file(_pickedImage!, fit: BoxFit.cover, width: double.infinity)
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 32, color: FamaColors.primary),
                                SizedBox(height: 8),
                                Text('Tap to add a photo'),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Service name'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),
                Text('Tags', style: Theme.of(context).textTheme.headlineMedium),
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
                      : Text(_isEditing ? 'Save Changes' : 'Add Service'),
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 8),
                  Text(
                    'New services are reviewed before they appear publicly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: FamaColors.onBackground.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

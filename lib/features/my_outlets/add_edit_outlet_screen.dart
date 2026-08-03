import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/marketplace.dart';
import '../../services/marketplace_service.dart';

class AddEditOutletScreen extends StatefulWidget {
  const AddEditOutletScreen({super.key, this.outlet});

  /// Pass an existing outlet to edit it; leave null to create a new one.
  final Outlet? outlet;

  @override
  State<AddEditOutletScreen> createState() => _AddEditOutletScreenState();
}

class _AddEditOutletScreenState extends State<AddEditOutletScreen> {
  final _service = MarketplaceService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;

  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;
  bool _isLocating = false;
  String? _errorMessage;

  bool get _isEditing => widget.outlet != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.outlet?.name);
    _descriptionController = TextEditingController(text: widget.outlet?.description);
    _contactController = TextEditingController(text: widget.outlet?.contact);
    _emailController = TextEditingController(text: widget.outlet?.email);
    _latitude = widget.outlet?.latitude;
    _longitude = widget.outlet?.longitude;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is needed to set your outlet\'s position.')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get your location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      setState(() => _errorMessage = 'Set your outlet\'s location before saving.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      if (_isEditing) {
        await _service.updateOutlet(
          widget.outlet!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          contact: _contactController.text.trim(),
          email: _emailController.text.trim(),
        );
      } else {
        await _service.createOutlet(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          latitude: _latitude!,
          longitude: _longitude!,
          contact: _contactController.text.trim(),
          email: _emailController.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _errorMessage = 'Could not save this outlet. Please check your details and try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Outlet' : 'Add Outlet')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Outlet name'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact phone number'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email (optional)'),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FamaColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: FamaColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _latitude != null
                              ? '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
                              : 'No location set yet',
                          style: TextStyle(color: _latitude != null ? FamaColors.onBackground : FamaColors.outline),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLocating ? null : _useCurrentLocation,
                        child: _isLocating
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Use Current'),
                      ),
                    ],
                  ),
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
                      : Text(_isEditing ? 'Save Changes' : 'Create Outlet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

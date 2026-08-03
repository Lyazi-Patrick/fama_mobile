import 'package:flutter/material.dart';
import '../../core/theme/fama_theme.dart';
import '../../models/tag.dart';
import '../services/tag_service.dart';

/// Reusable tag picker for any create/edit form (products, services,
/// worker profile). Tracks selected tag IDs -- not names -- since the
/// backend's tags()->sync() call needs primary keys.
class TagMultiSelect extends StatefulWidget {
  const TagMultiSelect({super.key, required this.selectedIds, required this.onChanged});

  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onChanged;

  @override
  State<TagMultiSelect> createState() => _TagMultiSelectState();
}

class _TagMultiSelectState extends State<TagMultiSelect> {
  late Future<List<Tag>> _future;

  @override
  void initState() {
    super.initState();
    _future = TagService().fetchTags();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Tag>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final tags = snapshot.data ?? [];
        if (tags.isEmpty) {
          return const Text('No tags available yet.');
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            final selected = widget.selectedIds.contains(tag.id);
            return FilterChip(
              label: Text(tag.name),
              selected: selected,
              onSelected: (isSelected) {
                final updated = Set<int>.from(widget.selectedIds);
                if (isSelected) {
                  updated.add(tag.id);
                } else {
                  updated.remove(tag.id);
                }
                widget.onChanged(updated);
              },
              selectedColor: FamaColors.primaryContainer.withOpacity(0.3),
              checkmarkColor: FamaColors.primary,
              side: BorderSide(color: selected ? FamaColors.primary : FamaColors.outlineVariant),
            );
          }).toList(),
        );
      },
    );
  }
}

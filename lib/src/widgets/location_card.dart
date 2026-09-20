import 'package:flutter/material.dart';
import '../model/world_location.dart';
import 'world_appearance_preview.dart';
import '../localization/world_strings.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    required this.location,
    required this.onEnter,
    required this.onProfile,
    required this.onFavorite,
    this.onEdit,
    super.key,
  });
  final WorldLocation location;
  final VoidCallback onEnter, onProfile, onFavorite;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) {
    final strings = WorldLocalization.of(context);
    return AlertDialog(
      title: Text(location.name),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 180,
                child: WorldAppearancePreview(appearance: location.appearance),
              ),
              Text(location.description),
              Text('Status: ${location.operationalState.name}'),
              const SizedBox(height: 12),
              Text('${location.district.label} district'),
              if (location.address.isNotEmpty) Text(location.address),
              if (location.isDemo)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Demo venue · this is not a real club.'),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onFavorite,
                icon: Icon(
                  location.isFavorite ? Icons.star : Icons.star_border,
                ),
                label: Text(
                  location.isFavorite ? 'Remove favorite' : 'Save to favorites',
                ),
              ),
              if (onEdit != null)
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Customize appearance'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.get('close')),
        ),
        TextButton(onPressed: onProfile, child: Text(strings.get('profile'))),
        FilledButton(onPressed: onEnter, child: Text(strings.get('enter'))),
      ],
    );
  }
}

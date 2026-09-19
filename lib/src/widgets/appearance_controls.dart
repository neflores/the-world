import 'package:flutter/material.dart';
import '../model/world_appearance.dart';
import 'world_appearance_preview.dart';

class AppearanceControls extends StatelessWidget {
  const AppearanceControls({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final WorldAppearance value;
  final ValueChanged<WorldAppearance>? onChanged;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(height: 170, child: WorldAppearancePreview(appearance: value)),
      DropdownButtonFormField<WorldBuilding>(
        initialValue: value.building,
        decoration: const InputDecoration(labelText: 'Building'),
        items: [
          for (final building in WorldBuilding.values)
            DropdownMenuItem(
              value: building,
              child: Text(switch (building) {
                WorldBuilding.tavern => 'Tavern',
                WorldBuilding.tower => 'Tower',
                WorldBuilding.guildHall => 'Guild hall',
                WorldBuilding.cottage => 'Workshop',
              }),
            ),
        ],
        onChanged: onChanged == null
            ? null
            : (v) {
                if (v != null) onChanged!(value.copyWith(building: v));
              },
      ),
      Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('Banner'),
            selected: value.banner,
            onSelected: onChanged == null
                ? null
                : (v) => onChanged!(value.copyWith(banner: v)),
          ),
          FilterChip(
            label: const Text('Plants'),
            selected: value.plants,
            onSelected: onChanged == null
                ? null
                : (v) => onChanged!(value.copyWith(plants: v)),
          ),
          FilterChip(
            label: const Text('Festival'),
            selected: value.festival,
            onSelected: onChanged == null
                ? null
                : (v) => onChanged!(value.copyWith(festival: v)),
          ),
        ],
      ),
    ],
  );
}

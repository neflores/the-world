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
      DropdownButtonFormField<WorldTheme>(
        initialValue: value.theme,
        decoration: const InputDecoration(labelText: 'Theme'),
        items: [
          for (final theme in WorldTheme.values)
            DropdownMenuItem(value: theme, child: Text(theme.name)),
        ],
        onChanged: onChanged == null
            ? null
            : (v) => onChanged!(value.copyWith(theme: v)),
      ),
      DropdownButtonFormField<WorldTier>(
        initialValue: value.tier,
        decoration: const InputDecoration(labelText: 'Visual tier'),
        items: [
          for (final tier in WorldTier.values)
            DropdownMenuItem(value: tier, child: Text(tier.name)),
        ],
        onChanged: onChanged == null
            ? null
            : (v) => onChanged!(value.copyWith(tier: v)),
      ),
      Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('Lantern'),
            selected: value.slots.lighting,
            onSelected: onChanged == null
                ? null
                : (v) => onChanged!(
                    value.copyWith(slots: value.slots.copyWith(lighting: v)),
                  ),
          ),
          FilterChip(
            label: const Text('Trophy'),
            selected: value.slots.trophy,
            onSelected: onChanged == null
                ? null
                : (v) => onChanged!(
                    value.copyWith(slots: value.slots.copyWith(trophy: v)),
                  ),
          ),
          FilterChip(
            label: const Text('Dragon mascot'),
            selected: value.slots.mascot,
            onSelected: onChanged == null
                ? null
                : (v) => onChanged!(
                    value.copyWith(slots: value.slots.copyWith(mascot: v)),
                  ),
          ),
          FilterChip(
            label: const Text('Notice board'),
            selected: value.slots.wall,
            onSelected: onChanged == null
                ? null
                : (v) => onChanged!(
                    value.copyWith(slots: value.slots.copyWith(wall: v)),
                  ),
          ),
          FilterChip(
            label: const Text('Patio table'),
            selected: value.slots.floor,
            onSelected: onChanged == null
                ? null
                : (v) => onChanged!(
                    value.copyWith(slots: value.slots.copyWith(floor: v)),
                  ),
          ),
        ],
      ),
    ],
  );
}

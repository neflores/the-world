import 'package:flutter/material.dart';
import '../interaction/world_intent.dart';
import '../model/city_district.dart';
import '../model/club_draft.dart';
import '../model/world_appearance.dart';
import '../model/world_city.dart';
import 'appearance_controls.dart';

class ClubForm extends StatefulWidget {
  const ClubForm({
    required this.cities,
    required this.onIntent,
    this.initialCityId,
    super.key,
  });
  final List<WorldCity> cities;
  final String? initialCityId;
  final WorldIntentHandler onIntent;
  @override
  State<ClubForm> createState() => _ClubFormState();
}

class _ClubFormState extends State<ClubForm> {
  final _name = TextEditingController(),
      _address = TextEditingController(),
      _description = TextEditingController();
  late String _city = widget.initialCityId ?? widget.cities.first.id;
  CityDistrict _district = CityDistrict.center;
  WorldAppearance _appearance = const WorldAppearance();
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final draft = ClubDraft(
      cityId: _city,
      name: _name.text,
      address: _address.text,
      description: _description.text,
      district: _district,
      appearance: _appearance,
    );
    if (draft.validationError != null) {
      setState(() => _error = draft.validationError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onIntent(CreateWorldClub(draft));
      if (mounted) Navigator.pop(context, _city);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save the club. Please retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: const Text('Add a club'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose its real city and address. The city scene uses only the direction you select.',
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('club-name'),
                controller: _name,
                enabled: !_saving,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Club name'),
              ),
              DropdownButtonFormField<String>(
                initialValue: _city,
                decoration: const InputDecoration(labelText: 'City'),
                items: [
                  for (final c in widget.cities)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: _saving ? null : (v) => setState(() => _city = v!),
              ),
              TextField(
                key: const ValueKey('club-address'),
                controller: _address,
                enabled: !_saving,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Full street address',
                ),
              ),
              DropdownButtonFormField<CityDistrict>(
                key: const ValueKey('club-direction'),
                initialValue: _district,
                decoration: const InputDecoration(
                  labelText: 'Part of the city',
                ),
                items: [
                  for (final d in CityDistrict.values)
                    DropdownMenuItem(value: d, child: Text(d.label)),
                ],
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _district = v!),
              ),
              TextField(
                controller: _description,
                enabled: !_saving,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Short description',
                ),
              ),
              AppearanceControls(
                value: _appearance,
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _appearance = v),
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('save-club'),
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving…' : 'Save club'),
        ),
      ],
    ),
  );
}

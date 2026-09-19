import 'package:flutter/material.dart';
import '../interaction/world_intent.dart';
import '../model/world_appearance.dart';
import 'appearance_controls.dart';

/// Host opens this only after checking editing permissions.
class WorldAppearanceEditor extends StatefulWidget {
  const WorldAppearanceEditor({
    required this.locationId,
    required this.initialAppearance,
    required this.onIntent,
    super.key,
  });
  final String locationId;
  final WorldAppearance initialAppearance;
  final WorldIntentHandler onIntent;
  @override
  State<WorldAppearanceEditor> createState() => _WorldAppearanceEditorState();
}

class _WorldAppearanceEditorState extends State<WorldAppearanceEditor> {
  late WorldAppearance _value = widget.initialAppearance;
  bool _saving = false;
  String? _error;
  Future<void> _apply() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onIntent(ApplyWorldAppearance(widget.locationId, _value));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Unable to apply appearance. Please retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: const Text('Customize appearance'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppearanceControls(
                value: _value,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _value = value),
              ),
              if (_error != null) Text(_error!),
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
          onPressed: _saving ? null : _apply,
          child: Text(_saving ? 'Applying…' : 'Apply'),
        ),
      ],
    ),
  );
}

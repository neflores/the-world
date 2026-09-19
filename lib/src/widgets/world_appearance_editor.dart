import 'package:flutter/material.dart';
import '../interaction/world_intent.dart';
import '../model/world_appearance.dart';
import '../model/world_appearance_option.dart';
import 'appearance_controls.dart';

/// Host opens this only after checking editing permissions.
class WorldAppearanceEditor extends StatefulWidget {
  const WorldAppearanceEditor({
    required this.locationId,
    required this.initialAppearance,
    required this.onIntent,
    this.options = const [],
    super.key,
  });
  final String locationId;
  final WorldAppearance initialAppearance;
  final WorldIntentHandler onIntent;
  final List<WorldAppearanceOption> options;
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
              for (final option in widget.options)
                ListTile(
                  title: Text(option.label),
                  leading: Icon(
                    option.available
                        ? Icons.check_circle_outline
                        : Icons.lock_outline,
                  ),
                  subtitle: Text(
                    option.available ? 'Available' : 'Locked · request in host',
                  ),
                  onTap: _saving
                      ? null
                      : () async {
                          if (option.available) {
                            setState(() => _value = option.appearance);
                          } else {
                            try {
                              await widget.onIntent(
                                RequestWorldAppearanceUnlock(
                                  widget.locationId,
                                  option.id,
                                ),
                              );
                            } catch (_) {
                              if (mounted) {
                                setState(
                                  () => _error =
                                      'Unlock request unavailable. Please retry in the host.',
                                );
                              }
                            }
                          }
                        },
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

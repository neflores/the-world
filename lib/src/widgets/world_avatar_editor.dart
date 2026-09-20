import 'package:flutter/material.dart';
import '../interaction/world_intent.dart';
import '../model/world_avatar.dart';

class WorldAvatarEditor extends StatefulWidget {
  const WorldAvatarEditor({
    required this.initial,
    required this.onIntent,
    super.key,
  });

  final WorldAvatar initial;
  final WorldIntentHandler onIntent;

  @override
  State<WorldAvatarEditor> createState() => _WorldAvatarEditorState();
}

class _WorldAvatarEditorState extends State<WorldAvatarEditor> {
  late WorldAvatar _value = widget.initial;
  bool _saving = false;
  String? _error;

  static const _hair = [0xFF5B3825, 0xFFB36C35, 0xFFE0C37B, 0xFF2F313B];
  static const _eyes = [0xFF5C948E, 0xFF6C8C54, 0xFF74513C, 0xFF687DB5];
  static const _clothes = [0xFF537EA1, 0xFF8B535D, 0xFF63836B, 0xFF8A6B3E];

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onIntent(ApplyWorldAvatar(_value));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Unable to save the avatar. Please retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: const Text('Your World avatar'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _AvatarSample(value: _value)),
              SegmentedButton<WorldHairstyle>(
                segments: const [
                  ButtonSegment(
                    value: WorldHairstyle.short,
                    label: Text('Short hair'),
                  ),
                  ButtonSegment(
                    value: WorldHairstyle.long,
                    label: Text('Long hair'),
                  ),
                ],
                selected: {_value.hairstyle},
                onSelectionChanged: _saving
                    ? null
                    : (v) => setState(
                        () => _value = _value.copyWith(hairstyle: v.single),
                      ),
              ),
              _colors(
                'Hair',
                _hair,
                _value.hairColor,
                (v) => _value.copyWith(hairColor: v),
              ),
              _colors(
                'Eyes',
                _eyes,
                _value.eyeColor,
                (v) => _value.copyWith(eyeColor: v),
              ),
              _colors(
                'Clothes',
                _clothes,
                _value.clothingColor,
                (v) => _value.copyWith(clothingColor: v),
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
          key: const ValueKey('save-avatar'),
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving…' : 'Save'),
        ),
      ],
    ),
  );

  Widget _colors(
    String label,
    List<int> colors,
    int selected,
    WorldAvatar Function(int) update,
  ) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Wrap(
          spacing: 10,
          children: [
            for (final color in colors)
              ChoiceChip(
                label: const SizedBox(width: 18, height: 18),
                avatar: CircleAvatar(backgroundColor: Color(color)),
                selected: selected == color,
                onSelected: _saving
                    ? null
                    : (_) => setState(() => _value = update(color)),
              ),
          ],
        ),
      ],
    ),
  );
}

class _AvatarSample extends StatelessWidget {
  const _AvatarSample({required this.value});
  final WorldAvatar value;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Avatar preview',
    child: SizedBox(
      width: 96,
      height: 116,
      child: CustomPaint(painter: _AvatarSamplePainter(value)),
    ),
  );
}

class _AvatarSamplePainter extends CustomPainter {
  const _AvatarSamplePainter(this.value);
  final WorldAvatar value;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      const Rect.fromLTWH(19, 100, 58, 12),
      Paint()..color = const Color(0x33352A20),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(25, 49, 46, 57),
        const Radius.circular(16),
      ),
      Paint()..color = Color(value.clothingColor),
    );
    canvas.drawCircle(
      const Offset(48, 37),
      25,
      Paint()..color = const Color(0xFFFFD5AD),
    );
    final hair = Paint()..color = Color(value.hairColor);
    canvas.drawArc(const Rect.fromLTWH(22, 10, 52, 50), 3.1, 3.15, true, hair);
    if (value.hairstyle == WorldHairstyle.long) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 33, 15, 48),
          const Radius.circular(8),
        ),
        hair,
      );
    }
    final eye = Paint()..color = Color(value.eyeColor);
    canvas.drawCircle(const Offset(39, 39), 3, eye);
    canvas.drawCircle(const Offset(57, 39), 3, eye);
  }

  @override
  bool shouldRepaint(_AvatarSamplePainter old) => old.value != value;
}

import 'package:flutter/material.dart';
import '../model/world_recruitment.dart';
import '../model/world_presence.dart';

class RecruitmentTable extends StatelessWidget {
  const RecruitmentTable({
    required this.game,
    required this.onTap,
    this.people = const [],
    super.key,
  });
  final WorldRecruitment game;
  final List<WorldPresence> people;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${game.title}, ${game.openSeats} open seats',
    child: SizedBox(
      width: 210,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < game.capacity; i++)
                Padding(padding: const EdgeInsets.all(2), child: _seat(i)),
            ],
          ),
          Material(
            color: const Color(0xF2B4824A),
            borderRadius: BorderRadius.circular(22),
            elevation: 5,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      game.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(game.system, style: const TextStyle(fontSize: 12)),
                    Text(
                      'GM ${game.master} · ${game.language}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      _date(game.startsAt),
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(game.priceLabel, style: const TextStyle(fontSize: 11)),
                    Text(
                      '${game.openSeats} open seats',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (game.phrase.isNotEmpty)
                      Text(
                        '“${game.phrase}”',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (game.requirements.isNotEmpty)
                      Text(
                        game.requirements.join(' · '),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _seat(int index) {
    if (index >= game.participantIds.length) {
      return const Icon(
        Icons.chair_alt_outlined,
        size: 23,
        color: Color(0xFFFFD686),
      );
    }
    final id = game.participantIds[index];
    final matches = people.where((p) => p.id == id);
    final person = matches.isEmpty ? null : matches.first;
    return Tooltip(
      message: person?.name ?? 'Party member',
      child: CircleAvatar(
        radius: 11.5,
        backgroundColor: Color(person?.avatar.clothingColor ?? 0xFF80958C),
        child: Text(
          person?.name.characters.first.toUpperCase() ?? '•',
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }

  String _date(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)} · ${two(value.hour)}:${two(value.minute)}';
  }
}

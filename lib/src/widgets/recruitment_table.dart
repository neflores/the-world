import 'package:flutter/material.dart';
import '../model/world_recruitment.dart';

class RecruitmentTable extends StatelessWidget {
  const RecruitmentTable({required this.game, required this.onTap, super.key});
  final WorldRecruitment game;
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
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    i < game.participantIds.length
                        ? Icons.person
                        : Icons.chair_alt_outlined,
                    size: 23,
                    color: i < game.participantIds.length
                        ? const Color(0xAAC6D8CD)
                        : const Color(0xFFFFD686),
                  ),
                ),
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
                      '${game.openSeats} open seats',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
}

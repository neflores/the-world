enum SocialStatus {
  lookingForGame('Looking for a game'),
  openToMeet('Open to meeting people'),
  waitingForParty('Waiting for my party'),
  browsing('Browsing'),
  newSystem('Trying a new system'),
  online('Available for online'),
  doNotDisturb('Do not disturb'),
  hidden('Hidden');

  const SocialStatus(this.label);
  final String label;
}

/// App-context presence, never the person's physical position.
class WorldPresence {
  const WorldPresence({
    required this.id,
    required this.name,
    required this.contextId,
    this.status = SocialStatus.browsing,
    this.leftAt,
    this.canMessage = false,
    this.canInvite = false,
  });
  final String id, name, contextId;
  final SocialStatus status;
  final DateTime? leftAt;
  final bool canMessage, canInvite;
  double opacityAt(DateTime now) {
    if (status == SocialStatus.hidden) return 0;
    if (leftAt == null) return 1;
    return (1 -
            now.difference(leftAt!).inMilliseconds /
                const Duration(minutes: 15).inMilliseconds)
        .clamp(0, 1);
  }
}

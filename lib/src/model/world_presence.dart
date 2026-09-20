import 'world_avatar.dart';

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
    this.avatar = const WorldAvatar(),
    this.publicHeadline = '',
    this.isFollowed = false,
  });
  final String id, name, contextId;
  final SocialStatus status;
  final DateTime? leftAt;
  final bool canMessage, canInvite;
  final WorldAvatar avatar;
  final String publicHeadline;
  final bool isFollowed;
  WorldPresence copyWith({
    String? contextId,
    SocialStatus? status,
    WorldAvatar? avatar,
    DateTime? leftAt,
    bool? isFollowed,
  }) => WorldPresence(
    id: id,
    name: name,
    contextId: contextId ?? this.contextId,
    status: status ?? this.status,
    avatar: avatar ?? this.avatar,
    leftAt: leftAt ?? this.leftAt,
    publicHeadline: publicHeadline,
    isFollowed: isFollowed ?? this.isFollowed,
    canMessage: canMessage,
    canInvite: canInvite,
  );
  double opacityAt(DateTime now) {
    if (status == SocialStatus.hidden) return 0;
    if (leftAt == null) return 1;
    return (1 -
            now.difference(leftAt!).inMilliseconds /
                const Duration(minutes: 15).inMilliseconds)
        .clamp(0, 1);
  }
}

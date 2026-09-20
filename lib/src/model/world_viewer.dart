import 'world_avatar.dart';

/// Private-to-viewer settings. Hidden viewers are not included in public people.
class WorldViewer {
  const WorldViewer({
    required this.id,
    required this.name,
    this.contextId = 'region',
    this.avatar = const WorldAvatar(),
  });
  final String id, name, contextId;
  final WorldAvatar avatar;
  WorldViewer copyWith({String? contextId, WorldAvatar? avatar}) => WorldViewer(
    id: id,
    name: name,
    contextId: contextId ?? this.contextId,
    avatar: avatar ?? this.avatar,
  );
}

import '../model/club_draft.dart';
import '../model/world_appearance.dart';
import '../model/world_presence.dart';
import '../model/world_avatar.dart';

part 'presence_intent.dart';

sealed class WorldIntent {
  const WorldIntent();
}

enum WorldDestination {
  profile,
  recruitment,
  communityBoard,
  online,
  favorites,
  craft,
  message,
  invite,
  game,
  rooms,
}

class OpenWorldDestination extends WorldIntent {
  const OpenWorldDestination(this.destination, this.entityId);
  final WorldDestination destination;
  final String entityId;
}

class CreateWorldClub extends WorldIntent {
  const CreateWorldClub(this.draft);
  final ClubDraft draft;
}

class ApplyWorldAppearance extends WorldIntent {
  const ApplyWorldAppearance(this.locationId, this.appearance);
  final String locationId;
  final WorldAppearance appearance;
}

class RequestWorldAppearanceUnlock extends WorldIntent {
  const RequestWorldAppearanceUnlock(this.locationId, this.optionId);
  final String locationId, optionId;
}

class SetWorldStatus extends WorldIntent {
  const SetWorldStatus(this.status);
  final SocialStatus status;
}

class SetWorldFavorite extends WorldIntent {
  const SetWorldFavorite(this.locationId, this.favorite);
  final String locationId;
  final bool favorite;
}

typedef WorldIntentHandler = Future<void> Function(WorldIntent intent);

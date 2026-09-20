import '../interaction/world_intent.dart';

/// Frontend availability hints. The host must authorize every backend command.
class WorldHostCapabilities {
  const WorldHostCapabilities({
    this.canView = true,
    this.canNavigate = true,
    this.canOpenProfiles = true,
    this.canOpenMessages = false,
    this.canInvite = false,
    this.canFollow = false,
    this.canCreateOrganization = false,
    this.canEditAppearance = false,
    this.canUsePresence = false,
    this.canUseOnlineWorld = true,
    this.canUseRecruitment = true,
    this.canUseSocialActions = false,
  });
  const WorldHostCapabilities.playground()
    : canView = true,
      canNavigate = true,
      canOpenProfiles = true,
      canOpenMessages = true,
      canInvite = true,
      canFollow = true,
      canCreateOrganization = true,
      canEditAppearance = true,
      canUsePresence = true,
      canUseOnlineWorld = true,
      canUseRecruitment = true,
      canUseSocialActions = true;
  final bool canView,
      canNavigate,
      canOpenProfiles,
      canOpenMessages,
      canInvite,
      canFollow,
      canCreateOrganization,
      canEditAppearance,
      canUsePresence,
      canUseOnlineWorld,
      canUseRecruitment,
      canUseSocialActions;

  bool allows(WorldIntent intent) {
    if (!canView) return false;
    return switch (intent) {
      CreateWorldClub() => canCreateOrganization,
      ApplyWorldAppearance() => canEditAppearance,
      RequestWorldAppearanceUnlock() => canEditAppearance,
      SetWorldStatus() => canUsePresence,
      SetWorldContext() || ApplyWorldAvatar() => canUsePresence,
      SetWorldFavorite() => true,
      OpenWorldDestination(:final destination) =>
        canNavigate &&
            switch (destination) {
              WorldDestination.profile => canOpenProfiles,
              WorldDestination.message => canOpenMessages,
              WorldDestination.invite => canInvite,
              WorldDestination.online => canUseOnlineWorld,
              WorldDestination.recruitment ||
              WorldDestination.game => canUseRecruitment,
              _ => true,
            },
    };
  }
}

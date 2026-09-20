class WorldRecruitment {
  WorldRecruitment({
    required this.id,
    required this.locationId,
    required this.title,
    required this.master,
    required this.system,
    required this.startsAt,
    required this.capacity,
    List<String> participantIds = const [],
    this.language = 'English',
    this.priceLabel = 'Free',
    this.phrase = '',
    this.isOnline = false,
    this.closed = false,
    List<String> requirements = const [],
  }) : participantIds = List.unmodifiable(participantIds),
       requirements = List.unmodifiable(requirements);
  final String id,
      locationId,
      title,
      master,
      system,
      language,
      priceLabel,
      phrase;
  final DateTime startsAt;
  final int capacity;

  /// Seat projections are independent of wandering presence.
  final List<String> participantIds;
  final List<String> requirements;
  final bool isOnline, closed;
  int get openSeats => (capacity - participantIds.length).clamp(0, capacity);
  bool isPublicAt(DateTime now) =>
      !closed && openSeats > 0 && startsAt.isAfter(now);
}

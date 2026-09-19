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
  }) : participantIds = List.unmodifiable(participantIds);
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
  final bool isOnline, closed;
  int get openSeats => (capacity - participantIds.length).clamp(0, capacity);
  bool isPublicAt(DateTime now) =>
      !closed && openSeats > 0 && startsAt.isAfter(now);
}

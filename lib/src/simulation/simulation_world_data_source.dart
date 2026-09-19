import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../data/world_data_source.dart';
import '../interaction/world_intent.dart';
import '../model/world_location.dart';
import '../model/world_presence.dart';
import '../model/world_snapshot.dart';
import 'demo_catalog.dart';

/// Fixture provider. Production never falls back to this source implicitly.
class SimulationWorldDataSource implements WorldDataSource {
  SimulationWorldDataSource({String? savedState, this.persist, DateTime? now})
    : _snapshot = createDemoSnapshot(now: now) {
    if (savedState != null) {
      final json = jsonDecode(savedState) as Map<String, dynamic>;
      if (json['version'] != 1) {
        throw const FormatException('Unsupported World save version');
      }
      _snapshot = _snapshot.copyWith(
        locations: (json['locations'] as List)
            .map((v) => WorldLocation.fromJson(v as Map<String, dynamic>))
            .toList(),
        status: SocialStatus.values.byName(json['status'] as String),
      );
    }
  }
  final Future<void> Function(String state)? persist;
  final _changes = StreamController<WorldSnapshot>.broadcast(sync: true);
  WorldSnapshot _snapshot;
  Future<void> _pending = Future<void>.value();
  WorldSnapshot get snapshot => _snapshot;
  String encode(WorldSnapshot value) => jsonEncode({
    'version': 1,
    'locations': value.locations.map((l) => l.toJson()).toList(),
    'status': value.status.name,
  });

  @override
  Stream<WorldSnapshot> watch() => Stream<WorldSnapshot>.multi((sink) {
    sink.add(_snapshot);
    final subscription = _changes.stream.listen(
      sink.add,
      onError: sink.addError,
      onDone: sink.close,
    );
    sink.onCancel = subscription.cancel;
  });

  Future<void> handle(WorldIntent intent) {
    final operation = _pending.then((_) async {
      var next = _snapshot;
      switch (intent) {
        case CreateWorldClub(:final draft):
          if (draft.validationError != null) {
            throw ArgumentError(draft.validationError);
          }
          if (!next.cities.any((c) => c.id == draft.cityId)) {
            throw ArgumentError('Unknown city');
          }
          final plots = next
              .inCity(draft.cityId)
              .where((l) => l.district == draft.district)
              .map((l) => l.plot);
          final plot = plots.fold(-1, max) + 1;
          final location = WorldLocation(
            id: 'local-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
            cityId: draft.cityId,
            name: draft.name.trim(),
            address: draft.address.trim(),
            description: draft.description.trim(),
            district: draft.district,
            plot: plot,
            appearance: draft.appearance,
          );
          next = next.copyWith(locations: [...next.locations, location]);
        case ApplyWorldAppearance(:final locationId, :final appearance):
          _requireLocation(locationId);
          next = next.copyWith(
            locations: [
              for (final l in next.locations)
                l.id == locationId ? l.copyWith(appearance: appearance) : l,
            ],
          );
        case SetWorldFavorite(:final locationId, :final favorite):
          _requireLocation(locationId);
          next = next.copyWith(
            locations: [
              for (final l in next.locations)
                l.id == locationId ? l.copyWith(isFavorite: favorite) : l,
            ],
          );
        case SetWorldStatus(:final status):
          next = next.copyWith(status: status);
        case OpenWorldDestination():
          return;
      }
      // Commit only after durable save succeeds; a failure keeps the form open.
      await persist?.call(encode(next));
      _snapshot = next;
      _changes.add(next);
    });
    _pending = operation.then((_) {}, onError: (Object _, StackTrace _) {});
    return operation;
  }

  void _requireLocation(String id) {
    if (!_snapshot.locations.any((l) => l.id == id)) {
      throw ArgumentError('Unknown location');
    }
  }

  Future<void> dispose() async {
    await _pending;
    await _changes.close();
  }
}

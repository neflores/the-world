import 'package:flutter/material.dart';
import '../data/world_data_source.dart';
import '../interaction/world_intent.dart';
import '../model/world_city.dart';
import '../model/world_location.dart';
import '../model/world_presence.dart';
import '../model/world_snapshot.dart';
import '../renderer/atlas_assets.dart';
import '../renderer/atlas_scene.dart';
import '../renderer/city_scene.dart';
import '../renderer/region_scene.dart';
import '../renderer/scene_pin.dart';
import '../runtime/world_controller.dart';
import '../module/world_diagnostic.dart';
import '../module/world_host_capabilities.dart';
import 'atlas_canvas.dart';
import 'club_form.dart';
import 'location_card.dart';
import 'person_card.dart';
import 'tavern_hall.dart';
import 'world_appearance_editor.dart';
import 'world_journal.dart';
import 'world_map_pane.dart';
import 'world_toolbar.dart';
import 'world_dialog.dart';

/// Embeddable World tab. The host provides data, permissions and action handling.
class WorldView extends StatefulWidget {
  const WorldView({
    required this.source,
    required this.onIntent,
    this.canCreateClub = false,
    this.canEditAppearance,
    this.onDiagnostic,
    this.capabilities = const WorldHostCapabilities.playground(),
    super.key,
  });
  final WorldDataSource source;
  final WorldIntentHandler onIntent;
  final bool canCreateClub;
  final bool Function(WorldLocation location)? canEditAppearance;
  final void Function(WorldDiagnostic)? onDiagnostic;
  final WorldHostCapabilities capabilities;
  @override
  State<WorldView> createState() => _WorldViewState();
}

class _WorldViewState extends State<WorldView> {
  late WorldController _controller;
  late final Future<AtlasAssets> _loading;
  AtlasAssets? _assets;
  AtlasScene? _scene;
  WorldSnapshot? _renderedSnapshot;
  final _mapKey = GlobalKey<AtlasCanvasState>();
  String? _cityId, _selected;
  String _search = '';
  int _neighborhood = 0;
  bool _quiet = false, _listOnly = false, _favoritesOnly = false;
  @override
  void initState() {
    super.initState();
    _controller = _newController();
    _loading = AtlasAssets.load();
    _loading.then(
      (value) {
        if (mounted) {
          _assets = value;
        } else {
          value.dispose();
        }
      },
      onError: (Object error) {
        if (mounted) {
          widget.onDiagnostic?.call(
            WorldDiagnostic(WorldDiagnosticCode.assets, cause: error),
          );
        }
      },
    );
  }

  WorldController _newController() => WorldController(
    widget.source,
    onDiagnostic: (event) => widget.onDiagnostic?.call(event),
  );
  Future<void> _intent(WorldIntent intent) => widget.onIntent(intent);

  @override
  void didUpdateWidget(WorldView old) {
    super.didUpdateWidget(old);
    if (old.source != widget.source) {
      _controller.dispose();
      _controller = _newController();
      _cityId = null;
      _selected = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scene?.dispose();
    _assets?.dispose();
    super.dispose();
  }

  void _selectCity(WorldCity? city) => setState(() {
    _cityId = city?.id;
    _selected = null;
    _search = '';
    _favoritesOnly = false;
    _neighborhood = 0;
  });
  Future<void> _dispatch(WorldIntent intent) async {
    try {
      await widget.onIntent(intent);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to complete this action. Please retry.'),
          ),
        );
      }
    }
  }

  Future<void> _addClub() async {
    final cityId = await showWorldDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ClubForm(
        cities: _controller.snapshot!.cities,
        initialCityId: _cityId,
        onIntent: _intent,
      ),
    );
    if (mounted && cityId != null) {
      _selectCity(
        _controller.snapshot!.cities.firstWhere((c) => c.id == cityId),
      );
    }
  }

  void _person(WorldPresence person) => showWorldDialog<void>(
    context: context,
    builder: (dialogContext) => PersonCard(
      person: person,
      capabilities: widget.capabilities,
      onAction: (action) {
        Navigator.pop(dialogContext);
        _dispatch(OpenWorldDestination(action, person.id));
      },
    ),
  );
  void _location(WorldLocation location) {
    setState(() {
      _selected = location.id;
      _neighborhood = location.neighborhood;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mapKey.currentState?.focusPin(location.id);
    });
    showWorldDialog<void>(
      context: context,
      builder: (dialogContext) => ListenableBuilder(
        listenable: _controller,
        builder: (_, _) {
          final matches = _controller.snapshot!.locations.where(
            (l) => l.id == location.id,
          );
          if (matches.isEmpty) {
            return const AlertDialog(
              content: Text('This place is no longer available.'),
            );
          }
          final current = matches.first;
          return LocationCard(
            location: current,
            onFavorite: () =>
                _dispatch(SetWorldFavorite(current.id, !current.isFavorite)),
            onProfile: () {
              Navigator.pop(dialogContext);
              _dispatch(
                OpenWorldDestination(WorldDestination.profile, current.id),
              );
            },
            onEnter: () {
              Navigator.pop(dialogContext);
              _hall(current);
            },
            onEdit: widget.canEditAppearance?.call(current) == true
                ? () {
                    Navigator.pop(dialogContext);
                    showWorldDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => WorldAppearanceEditor(
                        locationId: current.id,
                        initialAppearance: current.appearance,
                        onIntent: _intent,
                      ),
                    );
                  }
                : null,
          );
        },
      ),
    );
  }

  void _hall(WorldLocation location) => showWorldDialog<void>(
    context: context,
    builder: (dialogContext) => ListenableBuilder(
      listenable: _controller,
      builder: (_, _) => TavernHall(
        location: location,
        snapshot: _controller.snapshot!,
        onAction: (intent) {
          Navigator.pop(dialogContext);
          _dispatch(intent);
        },
      ),
    ),
  );
  void _landmark(String id) {
    switch (id) {
      case 'favorites-square':
        setState(() {
          _favoritesOnly = true;
          _search = '';
        });
      case 'online-portal':
        _dispatch(OpenWorldDestination(WorldDestination.online, _cityId!));
      case 'craft-district':
        _dispatch(OpenWorldDestination(WorldDestination.craft, _cityId!));
      case 'central-square':
        _dispatch(OpenWorldDestination(WorldDestination.recruitment, _cityId!));
    }
  }

  void _pin(ScenePin pin) {
    final snapshot = _controller.snapshot!;
    switch (pin.kind) {
      case ScenePinKind.city:
        _selectCity(snapshot.cities.firstWhere((c) => c.id == pin.id));
      case ScenePinKind.location:
        _location(snapshot.locations.firstWhere((l) => l.id == pin.id));
      case ScenePinKind.square ||
          ScenePinKind.favorites ||
          ScenePinKind.portal ||
          ScenePinKind.craft:
        _landmark(pin.id);
    }
  }

  AtlasScene _getScene(
    AtlasAssets assets,
    WorldSnapshot snapshot,
    WorldCity? city,
  ) {
    final key = city == null ? 'israel' : '${city.id}/$_neighborhood';
    if (_scene?.key != key || _renderedSnapshot != snapshot) {
      final old = _scene;
      _scene = city == null
          ? buildRegionScene(assets, snapshot)
          : buildCityScene(assets, snapshot, city, _neighborhood);
      _renderedSnapshot = snapshot;
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
    return _scene!;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      if (_controller.error != null && _controller.snapshot == null) {
        return const Center(
          child: Text('Unable to load World. Reconnect and try again.'),
        );
      }
      final snapshot = _controller.snapshot;
      if (snapshot == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return FutureBuilder<AtlasAssets>(
        future: _loading,
        builder: (context, art) {
          if (art.hasError) {
            return const Center(
              child: Text('Unable to load the atlas artwork.'),
            );
          }
          if (!art.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final city = snapshot.cities
              .where((c) => c.id == _cityId)
              .firstOrNull;
          final scene = _getScene(art.requireData, snapshot, city);
          return ColoredBox(
            color: const Color(0xFF252C27),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final compact = box.maxWidth < 850;
                    final listOnly = _listOnly || box.maxHeight < 430;
                    final journal = WorldJournal(
                      snapshot: snapshot,
                      city: city,
                      search: _search,
                      onSearch: (v) => setState(() => _search = v),
                      favoritesOnly: _favoritesOnly,
                      onFavorites: (v) => setState(() => _favoritesOnly = v),
                      onCity: _selectCity,
                      onLocation: _location,
                      onPerson: _person,
                      onLandmark: _landmark,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WorldToolbar(
                          simulation: snapshot.isSimulation,
                          status: snapshot.status,
                          onStatus: widget.capabilities.canUsePresence
                              ? (s) => _dispatch(SetWorldStatus(s))
                              : null,
                          quiet: _quiet,
                          onQuiet: () => setState(() => _quiet = !_quiet),
                          listOnly: listOnly,
                          onListOnly: () =>
                              setState(() => _listOnly = !_listOnly),
                          onAdd:
                              widget.canCreateClub && snapshot.cities.isNotEmpty
                              ? _addClub
                              : null,
                        ),
                        if (_controller.error != null)
                          const Text(
                            'Connection interrupted. Showing the last received state.',
                            style: TextStyle(color: Colors.amber),
                          ),
                        const SizedBox(height: 12),
                        if (city != null)
                          Row(
                            children: [
                              TextButton.icon(
                                key: const ValueKey('map-back'),
                                onPressed: () => _selectCity(null),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('All Israel'),
                              ),
                              Expanded(
                                child: Text(
                                  city.name,
                                  style: const TextStyle(
                                    color: Color(0xFFE8D6AC),
                                  ),
                                ),
                              ),
                              if (!listOnly) ...[
                                IconButton(
                                  tooltip: 'Previous neighborhood',
                                  onPressed: _neighborhood > 0
                                      ? () => setState(() => _neighborhood--)
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                Text(
                                  '${_neighborhood + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  tooltip: 'Next neighborhood',
                                  onPressed:
                                      snapshot
                                          .inCity(city.id)
                                          .any(
                                            (l) =>
                                                l.neighborhood > _neighborhood,
                                          )
                                      ? () => setState(() => _neighborhood++)
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ],
                            ],
                          ),
                        Expanded(
                          child: listOnly
                              ? journal
                              : compact
                              ? Column(
                                  children: [
                                    Expanded(
                                      child: _map(scene, snapshot, city),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(height: 230, child: journal),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _map(scene, snapshot, city),
                                    ),
                                    const SizedBox(width: 14),
                                    SizedBox(width: 320, child: journal),
                                  ],
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    },
  );
  Widget _map(AtlasScene scene, WorldSnapshot snapshot, WorldCity? city) =>
      WorldMapPane(
        mapKey: _mapKey,
        scene: scene,
        city: city,
        snapshot: snapshot,
        selected: _selected,
        quiet: _quiet,
        onPin: _pin,
        onPerson: _person,
      );
}

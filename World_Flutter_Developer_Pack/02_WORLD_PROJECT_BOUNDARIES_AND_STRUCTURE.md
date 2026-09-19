# World Project — границы, структура и совместимость

## Зачем этот файл

Это не инструкция уровня «создай класс X и положи его в папку Y». Исполнитель умеет проектировать сам.

Файл нужен, чтобы зафиксировать:

- что именно разрабатывается отдельно;
- что должно остаться reusable после интеграции;
- где проходят product/technical boundaries;
- какие решения можно принимать свободно;
- какие зависимости нельзя случайно встроить внутрь renderer;
- как одна разработка должна работать в Player App, MasterHub и ClubManager.

---

# 1. Жёсткое технологическое решение

## Делать на Flutter / Dart

Это обязательное ограничение.

Целевые приложения экосистемы используют общий Flutter/Dart client foundation и должны работать на:

- Android;
- iOS;
- Windows;
- Linux;
- macOS.

World не должен быть:

- отдельным Godot-приложением;
- Unity module;
- Qt/QML-проектом;
- web game в WebView;
- отдельным executable, который потом придётся «приклеивать» к Player App.

Он должен подключаться как **обычная Flutter/Dart часть приложения**.

## Flame — рекомендуемый, но не обязательный внутренний runtime

Flame подходит для живого 2D-слоя, потому что работает поверх Flutter и даёт:

- game/update loop;
- component model;
- sprite animation;
- camera;
- effects;
- input/hit testing;
- spatial scene composition.

`GameWidget` — обычный Flutter widget, поэтому его можно встроить внутрь Player App, а поверх него держать обычные Flutter cards, overlays, dialogs и editor UI.

Но **Flame не должен стать внешним контрактом экосистемы**.

Плохо:

```text
Player App / MasterHub / ClubManager
        ↓
должны знать PositionComponent, Vector2, SpriteComponent...
```

Хорошо:

```text
Host App
  ↓
WorldSnapshot / WorldUpdate / AppearanceConfig / WorldIntent
  ↓
Shared World Flutter package
  ↓
Flame или другой внутренний 2D renderer
```

Если для части задач проще использовать обычный Flutter/CustomPainter — это допустимо. Жёсткое требование — **Flutter/Dart и нормальная встраиваемость**, а не культ конкретного renderer.

---

# 2. Что разрабатывается отдельно

Не весь Player App.

Не backend.

Не MasterHub.

Не ClubManager.

Не Fluxer client.

Отдельный проект должен быть примерно таким по смыслу:

> **Shared World Flutter package + самостоятельный Playground/Demo app.**

Он должен уметь:

1. получить нормализованное состояние World;
2. показать его как живую scene;
3. симулировать это состояние без сервера;
4. отдавать наружу typed user intents;
5. показывать те же сущности в preview/edit context для MasterHub и ClubManager.

---

# 3. Главная граница ответственности

## World package владеет

### Scene/runtime

- загрузка/смена scenes;
- City/tavern/stall/guild visual scenes;
- camera;
- controlled zoom;
- transitions;
- spatial zones;
- anchors/points of interest;
- hit testing;
- highlight/focus.

### Avatars

- rendering;
- appearance;
- animation state;
- autonomous ambient behavior;
- movement inside allowed zones;
- idle actions;
- visual presence/recent/fade;
- table projections;
- visual status.

### World objects

- buildings;
- taverns;
- stalls/workshops;
- tables;
- boards;
- portal;
- signs;
- service NPC;
- event objects;
- decoration slots.

### Visual life

- ambient animation;
- time-of-day visual state;
- reactions;
- temporary bubbles;
- density/readability management;
- local effects;
- reduced/quiet modes.

### Appearance rendering

- tavern/stall/guild/workshop themes;
- tiers;
- slots;
- decorations;
- representatives;
- temporary event layers;
- preview/edit-preview.

### World interaction UX

- compact contextual cards;
- focus/selection;
- typed intents наружу.

### Simulation

- fake City population;
- fake presence;
- fake recruitment;
- table filling;
- master stalls;
- event states;
- day/night;
- reactions;
- deterministic scenarios.

---

# 4. Чем World package не владеет

Это не менее важно, чем список выше.

World не должен постепенно превратиться во вторую копию всей экосистемы.

Не его зона:

- auth/login;
- Fluxer token/session;
- реальный network transport;
- server DB;
- social graph storage;
- messages;
- Room backend;
- настоящий matchmaking/application flow;
- payments;
- wallet/currency accounting;
- purchase transaction logic;
- unlock rules;
- achievement calculations;
- rating calculations;
- moderation backend;
- City clustering;
- real route/travel calculation;
- MasterHub game operations;
- ClubManager venue operations;
- Altar gameplay state;
- character sheet logic;
- authoritative persistence.

Для demo можно симулировать **результат** этих систем, но нельзя по-тихому начать реализовывать их настоящую бизнес-логику внутри World.

---

# 5. Три host-приложения

## Player App

Главный runtime consumer.

Он использует полный World:

- City;
- avatars/presence;
- taverns;
- guild/community locations;
- master stalls;
- recruitment;
- events;
- reactions;
- portal;
- regional travel.

Player App получает public/safe projections от shared backend/Fluxer-related infrastructure и адаптирует их к World package.

## MasterHub

Использует общий renderer в режиме **preview/editor** для professional master entity.

Нужно поддержать:

- stall/workshop preview;
- theme;
- tier;
- representative;
- sign;
- props;
- decorations;
- recruitment presentation;
- temporary/event layers;
- preview изменений до apply.

MasterHub решает:

- что разблокировано;
- что куплено;
- сколько стоит;
- есть ли permission;
- можно ли применить change;
- как отправить его на server.

World только показывает и возвращает intent.

## ClubManager

Использует тот же renderer для **tavern/venue/community preview/editor**.

Нужно поддержать:

- theme;
- tier;
- sign;
- table skin;
- wall/floor decorations;
- trophy area;
- mascot/representative;
- seasonal/event state;
- operational visual state;
- preview City placement там, где это уместно.

ClubManager владеет ownership, operations, unlock, economy и publication.

---

# 6. Один renderer, не три похожих

Одна из главных целей проекта:

> **Одинаковая AppearanceConfig должна давать одинаковый visual result в Player App, MasterHub preview и ClubManager preview.**

Поэтому нельзя в итоге получить:

```text
player_app/tavern_renderer.dart
master_hub/tavern_preview.dart
club_manager/tavern_editor_preview.dart
```

с тремя похожими реализациями.

Нужен общий package.

---

# 7. Практическая форма отдельного repo

Ориентир:

```text
world/
├─ pubspec.yaml
├─ lib/
│  ├─ world.dart
│  └─ src/
│     ├─ model/
│     ├─ runtime/
│     ├─ renderer/
│     ├─ interaction/
│     ├─ appearance/
│     ├─ simulation/
│     └─ widgets/
├─ assets/
│  ├─ environments/
│  ├─ avatars/
│  ├─ buildings/
│  ├─ decorations/
│  ├─ fx/
│  └─ ui/
├─ example/
│  └─ World Playground app
└─ test/
```

Названия не обязательны.

Смысл:

- `lib` — reusable package;
- `example` — полноценная самостоятельная песочница;
- assets принадлежат World package/asset pipeline;
- simulation — отдельный нормальный слой, а не `if (demo)` в пятидесяти местах.

---

# 8. Не надо сразу дробить на десяток packages

Есть соблазн заранее сделать:

```text
world_models
world_runtime
world_renderer
world_editor
world_sim
world_protocol
...
```

На старте это скорее шум.

Лучше один чистый package с хорошими внутренними границами.

Позже, если реальная интеграция покажет пользу, common model/contracts можно вынести отдельно.

Главное сейчас не количество packages, а отсутствие неправильной зависимости вроде:

```text
Renderer -> concrete backend client
```

---

# 9. Внешний контракт: направление, не догма

Примерно:

```dart
class WorldSnapshot {
  final CityView city;
  final List<WorldLocationView> locations;
  final List<AvatarView> avatars;
  final List<RecruitmentView> recruitments;
  final List<WorldEventView> events;
  final List<ReactionView> reactions;
}
```

Не обязательно реально складывать всё в один гигантский объект на каждый frame.

Смысл в другом: renderer получает **view-safe state**, а не сам лезет в MasterHub/ClubManager/Fluxer/server.

---

# 10. Stable Entity ID обязателен

Любая значимая сущность должна иметь стабильный ID:

- user/avatar projection;
- master entity;
- club/community;
- tavern/location;
- stall/workshop;
- recruitment/game;
- event;
- City;
- decoration;
- board item.

Нельзя строить identity на том, что это «третий SpriteComponent в children».

World должен спокойно понять update вроде:

```text
recruitment_831 seats: 3 -> 4
```

и обновить нужный визуальный объект.

---

# 11. Сервер не синхронизирует координаты аватаров

Это один из ключевых архитектурных принципов.

Внешняя система передаёт смысл:

```text
user_12
presence = active
worldContext = tavern_7
status = browsing
```

Runtime решает:

- где avatar появится;
- куда пойдёт;
- где постоит;
- какую idle animation выберет;
- когда повернётся к board.

Не нужен MMO-style coordinate stream.

Если в будущем появится редкое действие, которое действительно требует синхронизированной spatial event, его можно добавить отдельно, не превращая весь presence в networking physics.

---

# 12. Full snapshot + lightweight updates

Для реального подключения стоит предусмотреть две формы состояния.

## Full snapshot

Нужен при:

- входе в World;
- смене City;
- reconnect;
- resume после долгого background;
- восстановлении после рассинхронизации.

## Updates/deltas

Например:

- avatar entered/left;
- presence changed;
- status changed;
- recruitment added/removed;
- seat changed;
- appearance changed;
- event activated;
- reaction added.

World не должен зависеть от конкретного WebSocket/Fluxer protocol.

Host app превращает transport events в понятные `WorldUpdate`.

---

# 13. World intents наружу

World не должен сам знать routing приложения.

Направление:

```dart
sealed class WorldIntent {}

class OpenEntity extends WorldIntent {
  final String entityId;
}

class EnterLocation extends WorldIntent {
  final String locationId;
}

class OpenRecruitment extends WorldIntent {
  final String recruitmentId;
}

class ReactToTarget extends WorldIntent {
  final String targetId;
  final String reactionId;
}

class RequestAppearanceApply extends WorldIntent {
  final AppearanceConfig config;
}
```

Host решает:

- какой route открыть;
- нужен ли login;
- разрешено ли Message/Invite/Join;
- какой API вызвать;
- что делать с payment;
- как показать error.

---

# 14. Contextual cards

Компактная World-card может жить в shared package, потому что это часть World UX.

Но она работает только на переданных данных.

Например:

```text
[Silver Dragon Tavern]
4 recruiting games tonight
12 active/recent people

[Open profile] [Enter]
```

или:

```text
[Nimble: Ruins of Var]
Today 19:00
3 / 5 seats

[Details]
```

`Details` возвращает наружу intent.

World package не реализует весь strict game details screen.

---

# 15. AppearanceConfig — важнейший общий seam

Примерное направление:

```dart
class LocationAppearance {
  final String themeId;
  final int tier;
  final String? mainSignId;
  final String? representativeId;
  final Map<String, String> decorationSlots;
  final List<String> temporaryLayers;
  final Map<String, double> visualState;
}
```

Точные поля будут уточняться.

Главная идея:

- config описывает **что выбрано**;
- renderer знает **как это показать**;
- host/backend знает **почему это разрешено и кому принадлежит**.

---

# 16. Slot-based customization

Для первой нормальной версии разумнее logical slots, чем полный freeform placement.

Например:

```text
sign.main
wall.left.1
wall.left.2
wall.right.1
bar.top
floor.center
floor.corner
entrance
trophy.1
mascot
lighting
tables.skin
seasonal.main
event.main
```

У разных themes эти slots могут находиться в разных координатах и даже иметь разный art treatment, но логический смысл остаётся общим.

Это позволяет:

- делать разные темы;
- не ломать hitboxes;
- безопасно добавлять decor;
- показывать один config одинаково в трёх host apps.

---

# 17. Runtime, Preview и Edit Preview

Renderer должен иметь минимум три контекста.

## Runtime

Игрок смотрит живой World.

## Preview

MasterHub/ClubManager показывают конкретную сущность отдельно от всего города.

## Edit Preview

Можно временно:

- выбрать slot;
- подсветить editable slots;
- подставить candidate decoration;
- сменить theme/tier;
- включить event layer;
- compare/revert;
- apply через intent.

Inventory/store/price UI остаётся у host app.

---

# 18. DataSource abstraction

До подключения реального сервера главный источник — simulation.

Направление:

```dart
abstract interface class WorldDataSource {
  Future<WorldSnapshot> loadInitial();
  Stream<WorldUpdate> updates();
}

class SimulationWorldDataSource implements WorldDataSource {
  ...
}
```

Позже в Player App появляется адаптер:

```dart
class PlayerAppWorldDataSource implements WorldDataSource {
  ...
}
```

Он может внутри пользоваться shared backend/Fluxer-related services, но сам World package об этом не знает.

---

# 19. Почему не нужно сейчас подключать Fluxer внутрь World

Fluxer — инфраструктура identity, presence, messaging, notifications, invitations, action routing, streaming и social transport.

Но World repo делается отдельно от основного Git.

Если renderer прямо сейчас начнёт владеть Fluxer session/client:

- package станет трудно запускать standalone;
- MasterHub preview будет тащить ненужный transport;
- ClubManager preview тоже;
- tests и simulation усложнятся;
- UI станет зависеть от server details, которые ещё могут меняться.

Правильнее:

```text
Fluxer/shared backend
        ↓
Host app adapters
        ↓
WorldDataSource + WorldIntent bridge
        ↓
Shared World package
```

Fluxer — engine/infrastructure, а Player App/World — experience.

---

# 20. Не привязывать package к app-wide state manager

Пока основной Player App repo не является источником конкретного решения, не нужно вшивать shared World наружным API намертво в Riverpod/Bloc/Provider/etc.

Лучше:

- получать понятные immutable models/snapshots/updates;
- возвращать intents/callbacks/streams;
- адаптер к app state management сделать в host app.

Внутри playground/runtime можно использовать удобный подход.

---

# 21. Не привязывать package к конкретному router

То же самое.

World не знает route names.

Он сообщает:

```text
OpenProfile(user_18)
OpenGame(game_5)
OpenClub(club_2)
OpenRoom(room_9)
```

Host app решает, как именно это открыть.

---

# 22. Assets: logical ID вместо file path

Плохо:

```text
theme = assets/taverns/red/tavern_final_v7.png
```

Лучше:

```text
themeId = tavern.cozy.red
```

А asset registry знает конкретные sprites/atlases/files.

Это позволит позже:

- менять art без миграции данных;
- делать resolution variants;
- паковать theme sets;
- кэшировать;
- иметь platform-specific optimization.

---

# 23. Pixel art, viewport и resolution

World logic не должна быть пришита к одному физическому resolution.

Нужны:

- логическая scene coordinate system;
- viewport/camera;
- scale policy;
- pixel snapping там, где он нужен;
- responsive safe areas.

Проверять:

- high DPI desktop;
- Android density;
- iOS density;
- resize window;
- phone/tablet proportions.

Desktop и mobile могут иметь разную раскладку surrounding UI, но один и тот же World state.

---

# 24. Что рисовать realtime renderer'ом, а что Flutter widgets

Хорошая базовая граница.

## Flame / realtime scene

- environment;
- avatars;
- autonomous movement;
- buildings/props;
- world FX;
- reactions;
- camera;
- hit regions;
- spatial animation.

## Flutter widgets

- contextual cards;
- bottom sheets;
- menus;
- editor controls;
- selection panels;
- list/text alternative;
- forms;
- settings;
- strict information.

`GameWidget` позволяет держать Flutter overlays поверх scene, поэтому нет причины искусственно превращать обычный UI в canvas.

---

# 25. Input: touch + mouse с самого начала

World должен естественно жить и на телефоне, и на desktop.

Mobile:

- tap;
- drag/pan;
- controlled scale/zoom, если нужен;
- long press только там, где он реально полезен.

Desktop:

- click;
- hover;
- drag/pan;
- wheel/controlled zoom;
- keyboard focus в Flutter accessibility/UI layer.

Нельзя делать важное действие доступным только через hover.

---

# 26. Performance strategy

Не надо сначала рисовать 500 живых аватаров, а потом устраивать войну за миллисекунды.

Архитектура должна позволять:

- curated visible avatar count;
- offscreen culling;
- sprite atlases/shared assets;
- pooling только там, где он реально полезен;
- lower update rate для дальних ambient actors;
- reduced FX;
- reaction aggregation;
- pause/throttle, когда World hidden;
- lifecycle-aware rendering;
- simplified backgrounds.

Точные лимиты определяются profiling, а не догмой.

---

# 27. App lifecycle

Поскольку это Flutter mobile/desktop module:

- background не должен продолжать full-speed loop;
- при resume можно применить fresh snapshot;
- устаревшие ambient actions можно сбросить;
- last World context желательно восстановить;
- edit-preview draft не должен случайно commit'иться из-за lifecycle event.

Host app сообщает runtime о lifecycle/context.

---

# 28. Accessibility seam

World data models не должны существовать только в координатах и sprites.

Если state знает:

```text
Silver Dragon Tavern
3 recruiting games
Festival tonight
```

из него можно построить и scene, и обычный list view.

Это ещё одна причина держать view/domain models отдельно от Flame components.

---

# 29. Debug/Developer mode

Для такой визуальной системы он очень полезен.

Переключатели:

- show hitboxes;
- show walk zones;
- show anchors;
- show entity IDs;
- show behavior state;
- FPS/update stats;
- spawn/despawn avatar;
- fill table;
- trigger event;
- toggle presence fade;
- day/night;
- quiet mode;
- reduced motion;
- load deterministic scenario.

Это не украшение. Оно сильно ускорит разработку автономного поведения и scene composition.

---

# 30. Deterministic simulation scenarios

Полезные presets:

### Empty City

Почти нет людей, только upcoming games и service NPC.

### Normal Evening

Средняя плотность, несколько столов, мастера, reactions.

### Busy Festival

Высокая активность, event decorations, crowd pressure.

### Tavern Recruitment

Фокус на table fill/projections.

### Appearance Editor

Tavern/workshop с разными slot states.

### Performance Stress

Много объектов и effects для profiling.

При фиксированном seed сценарий должен воспроизводиться одинаково для screenshots/tests.

---

# 31. Test philosophy

Не нужно тестировать, что avatar на кадре 183 ровно в `x=417.3`.

Полезнее проверять инварианты:

- avatar не выходит из allowed zone;
- не занимает forbidden anchor;
- full recruitment исчезает из hall;
- hidden user не появляется в public scene;
- AppearanceConfig стабильно маппится на slots/assets;
- одинаковый config даёт одинаковый visual composition;
- WorldIntent содержит правильный entity ID;
- full snapshot/reconnect корректно rehydrate scene;
- edit preview не мутирует committed config;
- reduced/quiet modes не убирают важные действия.

Плюс golden/screenshot tests там, где visual contract действительно важен.

---

# 32. Где разработчик свободен

Можно самостоятельно выбирать:

- структуру component tree;
- animation state machine;
- wander/path algorithm;
- tween/easing;
- asset loading/caching;
- state management внутри package;
- camera easing;
- sprite sheet/atlas format;
- object pooling;
- test helpers;
- внутренние имена классов и папок.

Если решение не меняет product behavior и не ломает integration seam — это нормальная инженерная свобода.

---

# 33. Что лучше не фиксировать без основного repo

Не цементировать заранее:

- app-wide state manager;
- main router;
- auth API;
- actual Fluxer protocol;
- final shared-server DTOs;
- persistence stack Player App;
- analytics;
- telemetry;
- global dependency injection framework.

World должен оставить понятные adapters/seams.

---

# 34. Разумный минимальный public surface

Не обязательный финальный API, а sanity check:

```text
WorldView
WorldPreview
WorldAppearanceEditorPreview

WorldSnapshot
WorldUpdate
WorldIntent

CityView
WorldLocationView
AvatarView
RecruitmentView
WorldEventView
ReactionView

LocationAppearance
AvatarAppearance

WorldDataSource
SimulationWorldDataSource
```

Если наружу начинают торчать десятки внутренних runtime classes — стоит остановиться и проверить границу.

---

# 35. Главная проверка интеграции

В любой момент должно быть возможно заменить:

```text
SimulationWorldDataSource
          ↓
       WorldView
```

на:

```text
PlayerAppDataAdapter
          ↓
       WorldView
```

без переписывания renderer.

И:

```text
LocationAppearance
        ↓
Player App runtime
```

должен визуально совпадать с:

```text
LocationAppearance
        ↓
ClubManager/MasterHub preview
```

---

# 36. Что считается хорошим результатом отдельной разработки

Не просто «получилась красивая демка».

Хороший результат:

- package реально reusable;
- example app показывает все основные механики;
- simulation отделена от renderer;
- public models не завязаны на Flame internals;
- scene не знает backend;
- user actions выходят typed intents;
- appearance renderer общий;
- preview/edit mode существует;
- touch + desktop учтены;
- mobile/desktop lifecycle учтён;
- performance degradation предусмотрена;
- тесты защищают инварианты.

---

# 37. Что передавать при слиянии

Handoff должен содержать:

- reusable Flutter package;
- example/playground app;
- assets и asset registry;
- короткий integration guide;
- public models/intents;
- platform assumptions;
- known limitations;
- performance notes;
- deterministic demo scenarios;
- tests;
- короткий changelog по milestones.

Тогда интеграция — это adapters и polish, а не археология.

---

# 38. Совместимость с Flutter ecosystem

Проверенная на текущий момент рамка нормальная:

- Flutter официально компилируется для Android, iOS и desktop;
- desktop stable включает Windows, macOS и Linux;
- Flame наследует Flutter cross-platform reach и поддерживает mobile/desktop;
- `GameWidget` можно разместить в любом месте Flutter widget tree;
- поверх него доступны обычные Flutter overlays;
- один package может использоваться в разных host applications.

Из этого следует, что выбранный подход не требует отдельного engine process и хорошо соответствует общей цели экосистемы: **максимум общего Flutter/Dart кода + platform adapters только там, где они реально нужны**.

---

# 39. Итоговая архитектурная мысль

World — общий визуальный язык экосистемы.

Player App использует его как живой социальный мир.

MasterHub использует его, чтобы мастер видел и настраивал своё professional World presence.

ClubManager использует его, чтобы клуб/сообщество видел и настраивал свою tavern/venue representation.

Shared backend и Fluxer-related infrastructure рассказывают **что происходит**.

World решает **как это живёт на экране**.

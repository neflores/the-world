# World — ориентировочный roadmap

## Как читать этот файл

Это не контракт по срокам и не требование публично выпускать версии с такими номерами.

Номера — удобные **ступени зрелости**, чтобы разработка не расползлась сразу в avatars, festivals, editor, online-world, три города и двадцать видов ламп.

У каждой ступени есть законченная мысль:

> После этой версии можно открыть Playground и сразу понять, какой новый кусок World стал настоящим.

Лучше законченная простая механика, чем десять систем на 30%.

---

# 0.0 — Foundation / Playground

## Цель

Создать правильный отдельный Flutter-проект, который можно долго развивать без основного Git, а затем встроить без тотальной переделки.

## Сделать

- Flutter/Dart reusable package;
- отдельный `example` / World Playground app;
- базовый asset registry;
- базовые `WorldSnapshot`, `WorldUpdate`, `WorldIntent`;
- `WorldDataSource`;
- `SimulationWorldDataSource`;
- lifecycle hooks;
- responsive viewport;
- mouse + touch input;
- developer/debug overlay.

Если используется Flame:

- `GameWidget` находится внутри нормального Flutter tree;
- Flutter overlays работают поверх scene;
- Flame classes не становятся public API экосистемы.

## Demo

Пока достаточно тестовой площади:

- background;
- 2–3 props;
- camera;
- один clickable object;
- одна Flutter contextual card;
- один typed intent наружу.

## Готово, когда

Один и тот же package запускается как standalone Playground, World object реагирует на click/tap, а host получает нормальный intent.

Никакой сервер не нужен.

---

# 0.1 — Living World Core

## Главная мысль

Появляется **живой кусок настоящего World**, а не статический mockup.

## City scene

- компактная central square;
- несколько фоновых buildings;
- 1 настоящая clickable tavern;
- 1 master stall;
- 1 board;
- portal placeholder;
- декоративные props;
- понятные hit regions.

## Tavern scene

Первый главный зал:

- bar/sign;
- official board;
- community board placeholder;
- 3–4 recruitment tables как objects;
- entrance/exit;
- несколько seat/idle anchors;
- club representative placeholder.

## Camera

- pan/drag;
- overview;
- normal;
- close;
- короткие transitions.

## Avatars

Примерно 8–15 simulated avatars:

- walk;
- idle;
- turn/look;
- pause;
- sit;
- wave;
- leave.

Один помечен как LocalPlayer.

## Spatial model

- walk zones;
- forbidden zones;
- points of interest;
- entrances;
- seat anchors;
- table anchors.

## Interaction

- tap/click;
- hover where available;
- highlight;
- contextual card;
- enter/leave tavern.

## Simulation

Люди автоматически:

- появляются;
- гуляют;
- останавливаются;
- интересуются объектами;
- уходят.

## Пока не делать

- реальную сеть;
- purchases/economy;
- полноценные reactions;
- drawing;
- online archipelago;
- multiple Cities.

## После 0.1

Уже видно, **зачем World существует**. Он ощущается как место, а не как меню с фоном.

---

# 0.2 — Presence + Recruitment

## Главная мысль

World начинает показывать реальную настольную активность, а не просто гуляющих чубриков.

## Presence

Состояния вроде:

- ACTIVE;
- RECENT;
- FADING;
- HIDDEN.

В simulation минуты можно ускорять до секунд.

## Social status

Минимальный набор:

- looking for game;
- browsing;
- waiting for party;
- online play;
- do not disturb.

Status визуально отделён от speech bubble.

## Recruitment model

Стол знает:

- recruitment/game ID;
- master;
- system;
- title;
- start time;
- seats current/max;
- short phrase;
- optional tags.

## Seat projections

- joined player получает seated/ghost projection;
- ambient avatar при этом может продолжать гулять;
- projection визуально отличается от presence-avatar;
- стол постепенно заполняется.

## Full table

- заполнение получает readable effect;
- стол уходит из recruitment hall;
- следующий relevant recruitment может занять его место.

## Master recruitment

- recruiting master заметнее на square;
- stall показывает active state;
- sign/marker;
- recruitment phrase.

## Demo scenarios

- slow fill;
- last seat opened;
- full party;
- master starts recruiting;
- master stops recruiting.

## После 0.2

Город явно связан с реальными настольными играми, а не выглядит декоративной social pixel scene.

---

# 0.3 — Shared Appearance System

## Главная мысль

Закладывается renderer, который реально можно использовать сразу в Player App, MasterHub и ClubManager.

Это одна из важнейших архитектурных ступеней.

## Appearance config

Появляется устойчивая модель:

- theme;
- building tier;
- main sign;
- representative;
- decoration slots;
- temporary/event layers;
- visual state.

## Tavern themes

Минимум 2–3, даже если art пока простой:

- cozy fantasy;
- modern board-game café;
- sci-fi/cyber/space style.

Цель — доказать смену visual language одним renderer, а не сразу рисовать огромный art catalog.

## Slots

Например:

- main sign;
- wall;
- floor;
- entrance;
- trophy;
- mascot;
- lighting;
- tables;
- seasonal.

## Master stall/workshop appearance

- tier;
- sign;
- props;
- representative;
- decoration slots.

## Same-config demo

Одна `AppearanceConfig` показывается:

- внутри runtime City;
- отдельно в preview.

Они должны совпадать.

## После 0.3

World перестаёт быть «одним нарисованным уровнем» и становится общей визуальной системой.

---

# 0.4 — MasterHub / ClubManager Preview & Edit

## Главная мысль

Shared renderer уже можно отдавать другим приложениям для настройки их World presence.

Backend покупки всё ещё может быть полностью fake.

## Preview Mode

Изолированно показывать:

- tavern;
- master stall/workshop;
- community/guild building.

## Edit Preview

- выбрать logical slot;
- подсветить editable slots;
- подставить decoration;
- сменить theme;
- сменить tier preview;
- toggle event/season layer;
- revert candidate;
- apply intent.

## MasterHub demo panel

- stall/workshop;
- representative;
- sign;
- props;
- recruitment appearance.

## ClubManager demo panel

- tavern theme;
- sign;
- table skin;
- wall/floor decor;
- trophy;
- mascot;
- seasonal layer.

## Граница экономики

Даже если demo имеет кнопку `Buy`, она только генерирует intent вроде:

```text
RequestPurchase(decorationId)
```

World не ведёт wallet и не решает entitlement.

## После 0.4

Можно реально подключить package к будущему MasterHub/ClubManager editor без второго renderer.

---

# 0.5 — Social Life

## Главная мысль

World получает лёгкие человеческие следы и перестаёт быть только системой presence/recruitment.

## Avatar contextual actions

- View Profile intent;
- Message intent;
- Invite intent при разрешённом context;
- React;
- Follow/Friend placeholder по необходимости.

## Speech bubbles

- короткий text;
- finite lifetime;
- отдельный visual style от status.

## Drawing bubble

Простой Flutter drawing widget:

- 1 brush;
- несколько colors;
- eraser;
- mouse/touch/stylus.

После submit рисунок показывается temporary bubble.

## Reactions

- positive/neutral palette;
- float;
- drift;
- fade;
- expire;
- target: avatar/table/building/drawing/etc.

## Aggregation

При большом количестве:

- individual reactions;
- small clusters;
- simplified flock/cloud.

Никаких 500 одновременно живущих emoji components.

## Community board v1

- short notes;
- drawings;
- local traces;
- contextual card.

Moderation backend пока simulated.

## После 0.5

Можно просто постоять в World и увидеть, что люди оставляют друг другу краткие следы.

---

# 0.6 — Real City Structure

## Главная мысль

Из одной demo-площади получается маленький, но структурно настоящий City World.

## Central Square polish

- boards;
- master stalls;
- portal;
- service NPC;
- event slots;
- activity summary hooks.

## Favorites Square

Отдельная стабильная зона:

- favorite taverns;
- favorite masters;
- current campaigns placeholders;
- familiar players;
- external navigation intents.

## Somewhere New / Discovery

Место/route для незнакомого:

- clubs;
- masters;
- systems;
- guilds;
- events.

## Community/guild location

Минимум один отдельный тип.

## Craft District skeleton

- workshop/storefront visual presence;
- craft profile intents;
- без полноценного marketplace.

## City activity summary

Flutter overlay:

- recruiting games;
- festivals;
- familiar people;
- favorite tavern activity;
- new masters.

Клик переводит camera к соответствующему World object.

## Context memory

Запоминать разумно:

- last scene;
- last opened location;
- camera region;
- selected context при возврате.

## После 0.6

Город ощущается городом, а не тестовым уровнем вокруг одной таверны.

---

# 0.7 — Time, Events, Taverns v2

## Главная мысль

Мир меняется во времени и умеет показывать более богатую жизнь клуба.

## Time of day

- morning;
- day;
- evening;
- night.

Меняются lighting/ambient/background accents, но не доступность функций.

## Multiple halls/floors

Поддержать логические группы:

- Now/Soon;
- Tomorrow;
- Later;
- recurring;
- events.

Не обязательно буквально строить пятиэтажную башню; важнее runtime/data model.

## Time signs

- Tonight;
- Tomorrow;
- Weekend;
- Next Week.

## Event layers

- banners;
- props;
- lighting;
- stage;
- entrance;
- crowd accents.

## Coexisting events

Несколько temporary layers не должны уничтожать scene readability.

## Progression visuals

Renderer нормально показывает:

- building tier;
- unlocked visual areas;
- trophies;
- history accents;
- operational visual flags.

Бизнес-логика остаётся внешней.

## После 0.7

Один и тот же клуб может выглядеть заметно по-разному в обычный вечер, во время festival и после visual progression.

---

# 0.8 — Performance, Accessibility, Product Polish

## Главная мысль

World перестаёт быть красивой технологической игрушкой и становится жизнеспособной частью приложения.

## Performance modes

- Full;
- Reduced;
- Low Motion;
- Lower FPS;
- Simplified background.

## Quiet Mode

- меньше random avatars;
- меньше reactions;
- меньше ambient motion;
- больше emphasis на favorites/important objects.

## List/Text alternative

Эквивалент текущего City context:

- locations;
- recruitments;
- events;
- activity;
- favorites.

Без потери важных действий.

## Lifecycle

- pause/throttle in background;
- refresh/rehydrate on resume;
- no runaway loop;
- restore context.

## Density/performance

- culling;
- curated avatar count;
- distant actor throttling;
- reaction aggregation;
- no hitbox blocking;
- visual priority.

## Responsive checks

- small phone;
- large phone/tablet;
- desktop;
- resized window;
- high DPI.

## Input checks

- touch;
- mouse;
- hover;
- drag;
- wheel/zoom;
- keyboard focus для Flutter UI/accessibility.

## После 0.8

World можно держать открытым как реальную вкладку продукта, а не только показывать на мощном desktop в demo.

---

# 0.9 — Production Integration Seam

## Главная мысль

Перед подключением к основному Git убрать всё, где demo случайно стала архитектурой.

## Public API review

Оставить небольшой понятный surface:

- snapshots;
- updates;
- intents;
- appearance;
- data source;
- runtime view;
- preview/editor.

## Simulation isolation

Simulation — нормальный отдельный provider.

Никаких `if (demoMode)` по renderer.

## Updates

Поддержать нормальные changes:

- avatar add/remove;
- presence/status;
- recruitment add/remove;
- seat change;
- event change;
- appearance change;
- reaction add.

## Full rehydrate

Full snapshot должен безопасно перестраивать scene после reconnect/resume/context change.

## Error/empty states

- no City;
- low activity;
- asset failure;
- stale data;
- failed preview asset;
- no recruitment.

Без crash и без fake people, выдаваемых за реальных.

## Integration harness

Сделать три простых fake hosts:

```text
Fake Player App Shell
Fake MasterHub Shell
Fake ClubManager Shell
```

Все три используют один package только через public API.

## Documentation

Записать:

- entry points;
- models;
- intents;
- lifecycle;
- assets;
- known limitations.

## После 0.9

Можно начинать настоящее слияние без огромного refactor.

---

# 1.0 — Full Local World Module

## Главная мысль

Закончена первая полноценная версия общего World для local/physical tabletop слоя.

К этому моменту должны быть зрелыми:

## Player App runtime

- local City;
- central square;
- Favorites Square;
- taverns;
- guild/community locations;
- master stalls/workshops;
- craft presence;
- recruitment;
- avatars;
- presence;
- statuses;
- bubbles;
- reactions;
- boards;
- events;
- day/night;
- contextual cards;
- quiet/accessibility;
- performance modes.

## Shared appearance

- tavern;
- stall/workshop;
- community building;
- themes;
- tiers;
- slots;
- event layers;
- visual state;
- preview/edit-preview.

## Simulation

- low activity;
- normal evening;
- festival;
- recruitment;
- appearance editor;
- stress;
- deterministic seeds.

## Integration quality

- reusable package;
- backend-independent renderer;
- clean typed intents;
- Flutter-native shell integration;
- mobile/desktop tested;
- meaningful tests.

## Что может ещё не входить

Полный online archipelago и большой multi-City layer лучше делать после того, как local World действительно приятен и устойчив.

---

# 1.1 — Neighboring Cities / Regional Travel

## Главная мысль

World выходит за пределы Home City, не превращаясь в навигатор.

## Regional map

- fantasy-style node map;
- neighboring City nodes;
- favorite Cities;
- activity/event hints;
- approximate travel bands;
- short hub transition.

## Context switch

При входе в другой City переключаются:

- taverns;
- communities;
- recruitments;
- events;
- Favorites context;
- avatar public presence.

## List alternative

Полный эквивалент карты в обычном list view.

## Не делать

- train planner;
- turn-by-turn routing;
- literal street map;
- точные расписания транспорта.

## После 1.1

Можно «съездить посмотреть, что играет соседний город» примерно как выбрать город на RPG world map.

---

# 1.2 — Online Portal / Language Archipelagos

## Главная мысль

Pure online tabletop получает собственное живое пространство, а не просто `online=true` filter.

## Portal transition

Central portal открывает отдельный online World context.

## Game-language selection

- primary game language;
- additional languages;
- quick switch.

## Archipelago skeleton

Для языка:

- central island;
- guild islands;
- master platforms;
- recruitment boards;
- event spaces;
- craft presence.

## Presence

Используется тот же общий avatar/presence model, но другой spatial context.

## Recruitment

Pure online masters/games получают полноценное World-представление.

## После 1.2

Online становится самостоятельной живой частью мира, а не обычным списком за portal button.

---

# 1.3 — Rich Professional Presence

## Главная мысль

MasterHub и ClubManager используют shared renderer уже как полноценную visual management surface.

## MasterHub

- больше workshop tiers;
- richer representative;
- more slot families;
- recruitment visual variants;
- event appearance;
- preview в нескольких contexts.

## ClubManager

- multiple tavern themes;
- hall variants;
- trophies/history;
- mascot;
- seasonal sets;
- event sets;
- operational visual state preview.

## Community

- guild hall/pavilion/tower themes;
- local + online representations.

## Сохранить ограничение

Не переходить к arbitrary pixel-perfect freeform interior editor только потому, что «редактор уже есть». Он нужен только если реальный UX докажет пользу.

---

# 1.4+ — Expansion по реальной необходимости

После этого roadmap разумнее строить по прототипам, нагрузке и реальному использованию.

Возможные направления:

- more avatar species/cosmetics;
- more building families;
- convention districts;
- public stream viewing rooms;
- richer festivals;
- stronger City progression visuals;
- smarter crowd behavior;
- richer reaction flocking;
- content/theme packs;
- creator art pipeline;
- advanced editor tools.

Но это расширение.

Если Core не приятен, бессмысленно лечить его сотней видов шляп.

---

# Что сокращать, если scope внезапно слишком большой

Не выкидывать архитектурные seams.

## Сохранять обязательно

1. Flutter package + Playground.
2. `WorldDataSource` abstraction.
3. snapshots/updates.
4. typed `WorldIntent`.
5. shared `AppearanceConfig`.
6. runtime + preview.
7. City + tavern.
8. autonomous avatars.
9. recruitment tables/projections.
10. simulation.

## Сокращать первым

- количество art themes;
- количество decorations;
- drawing tool;
- reaction variety;
- festival variety;
- Craft District detail;
- multiple floors;
- regional map;
- online archipelago.

Так маленькая версия остаётся фундаментом настоящего продукта, а не одноразовым visual MVP.

---

# Очень короткая карта версий

```text
0.0  — правильно встраивается
0.1  — живёт
0.2  — показывает presence и реальные наборы
0.3  — умеет менять внешний вид общим renderer
0.4  — пригоден для MasterHub/ClubManager preview/edit
0.5  — люди оставляют социальные следы
0.6  — появляется настоящий City
0.7  — время, события, богатые taverns
0.8  — реально жизнеспособен на разных устройствах
0.9  — готов к интеграции
1.0  — полноценный local World
1.1  — соседние Cities
1.2  — online language archipelagos
1.3  — богатое professional appearance management
```

---

# Рекомендация разработчику

Не пытайся угадать финальный сервер и не строй вокруг предполагаемого API.

Сделай World настолько хорошо отделённым от источника данных, чтобы backend мог поменяться несколько раз и это осталось проблемой adapter'а, а не scene.

Не пытайся сделать «игру» ради игры.

Сделай **живой социальный renderer**, который превращает строгие реальные данные в уютное место и возвращает наружу понятные действия.

И не нужно согласовывать каждое внутреннее инженерное решение. Если оно не меняет product meaning и не ломает integration boundary — это нормальная зона самостоятельного выбора.

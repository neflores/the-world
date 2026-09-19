# World — полная картина

## Зачем этот документ

Это не формальное ТЗ и не список классов. Это передача общей модели World человеку, который сам умеет проектировать и писать код.

Конкретные тайминги, размеры, названия компонентов, устройство state machine и многие детали можно менять. Важнее сохранить смысл: **что такое World, зачем он существует и какие отношения между его частями нельзя случайно перевернуть**.

---

# 1. Короткая формула

**Player App — обычное мощное приложение для настольщиков, внутри которого есть одна большая живая вкладка World.**

World превращает настоящую настольную экосистему в условный уютный pixel-RPG город:

- реальные игроки становятся чиби-аватарами;
- физические клубы — тавернами и venue-зданиями;
- сообщества — guild halls, павильонами, башнями и другими общественными местами;
- мастера, которые сейчас набирают людей, получают лавки/стенды/мастерские;
- наборы в игры становятся столами, возле которых визуально собирается партия;
- реальные события и фестивали временно меняют город;
- ремесленники получают присутствие в Craft District;
- чисто online-игры находятся за отдельным порталом;
- соседние реальные города позже соединяются упрощённой fantasy-style региональной картой.

При этом World **не заменяет приложение игрой**.

Search, Rooms, Characters, Communication, Tools, Calendar, Profile, Settings и остальные практические разделы остаются обычными Flutter-интерфейсами. Пользователю никогда не нужно «дойти персонажем до здания», чтобы открыть нужную функцию.

World нужен, чтобы **видеть живую экосистему, замечать интересное и естественно переходить к реальным действиям**.

---

# 2. Какое ощущение он должен давать

Главная эмоция — **любопытство**.

Открыв World, человек должен видеть маленькие причины присмотреться:

- почему возле той таверны оживлённо;
- что за мастер стоит с табличкой;
- почему появился новый стол;
- почему у портала эффект;
- кто оставил рисунок на доске;
- кто эти люди;
- какое событие украшает площадь;
- почему знакомый клуб сегодня выглядит иначе.

Это не dashboard, замаскированный под RPG.

Сцена должна казаться живой даже в тот момент, когда пользователь ничего не делает.

Вторая эмоция — **приключение**. Строгая карточка игры всё равно содержит систему, время, язык, цену, места и ограничения. Но в World тот же набор может ощущаться как:

> Вон мастер собирает людей. За столом осталось два свободных места. Что они вообще затеяли?

Третья эмоция — **присутствие людей**. До открытия мессенджера уже видно, что вокруг кто-то есть. Социальность начинается с наблюдения и лёгкого контакта, а не с пустого списка чатов.

---

# 3. World — не MMORPG

Это жёсткий принцип.

## Пользователь не управляет аватаром

Нет:

- виртуального стика;
- WASD;
- клика по земле «иди сюда»;
- ручного pathfinding;
- необходимости физически идти до здания.

Аватары двигаются сами.

Пользователь управляет **вниманием и контекстом**:

- двигает камеру;
- выбирает объект;
- входит в локацию;
- смотрит contextual card;
- переходит в обычный интерфейс для серьёзного действия.

Свой аватар — визуальное отражение текущего World-контекста пользователя.

Если человек открыл таверну, его аватар коротко появляется внутри. Это может быть дверь, короткий fade/teleport, camera transition — что угодно быстрое и приятное. Долгих прогулок между UI-состояниями быть не должно.

---

# 4. Визуальный формат

Основной World — **абстрактный 2D изометрический или псевдоизометрический pixel/pixel-inspired мир**.

Это не:

- Google Maps;
- точные реальные улицы;
- симулятор географии;
- 3D open world.

По ощущению полезно думать о смеси:

- читаемой постановки сцен вроде Eastward;
- уютных RPG-городков;
- социальных игровых hub-локаций;
- дружелюбной «игрушечности» Nintendo-подобных интерфейсов.

Копировать внешний вид конкретной игры не надо. Важнее принцип: **компактная читаемая сцена, много мелкой жизни, но важные объекты видны сразу**.

---

# 5. Город — визуальная проекция реальной сети

World-город не должен быть статическим уровнем, который художник один раз нарисовал и больше не меняется.

Он собирается из настоящих данных:

- nearby clubs;
- communities;
- active masters;
- active recruitment;
- open seats;
- public events;
- subscriptions/favorites;
- online/recent presence;
- время суток;
- сезон и временная активность.

У города есть **стабильный скелет** и **динамическая жизнь**.

### Стабильные элементы

- физические таверны;
- центральная площадь;
- Favorites Square;
- центральный портал;
- Craft District;
- крупная инфраструктура.

### Динамические элементы

- recruitment stalls мастеров;
- временные community/guild активности;
- фестивали;
- event-входы;
- наборные столы;
- reactions;
- roaming avatars;
- seasonal props.

World не обязан буквально показывать всех online-пользователей и все сущности. Он показывает **разумную выборку**, чтобы сцена оставалась читаемой.

---

# 6. Центральная площадь

Центральная площадь — естественный вход в World.

На ней могут быть:

- выборка игроков;
- мастера с активным recruitment;
- official boards;
- free community board;
- online portal;
- service NPC;
- seasonal activity;
- event entrances;
- признаки того, что сейчас происходит в городе.

С первого экрана должно быть видно: **здесь кто-то живёт и что-то происходит**.

---

# 7. Favorites Square и открытие нового

World может адаптироваться под человека, но привычные места не должны постоянно перескакивать из-за алгоритмов.

**Favorites Square** — стабильный практический World-хаб:

- favorite taverns;
- favorite masters;
- subscriptions;
- current campaigns;
- nearby/current Rooms;
- familiar players;
- быстрые переходы к важному.

Дополнительно может существовать противоположный по смыслу путь — условный **Somewhere New**: незнакомые клубы, маленькие сообщества, новые системы, случайные события, новые мастера.

То есть World одновременно даёт **дом** и **исследование**.

---

# 8. Таверны и другие общественные здания

Таверна — не просто красивая иконка, ведущая в профиль клуба.

При входе пользователь получает **отдельную интерактивную сцену**.

Типичный главный зал:

- вывеска/знак над баром → обычный профиль клуба или сообщества;
- official game board → структурированные наборы;
- recruitment tables → самые актуальные игры, которым нужны люди;
- community board → рисунки, короткие сообщения и местные следы;
- лестница/указатели → другие залы;
- игроки;
- декоративный представитель клуба;
- локальные украшения, трофеи и event layers.

Каждый такой объект — **World-представление реальной функции**, а не замена этой функции.

Стол не заменяет game details.

Доска не заменяет Search.

Вывеска не заменяет Profile.

World ведёт туда легко и понятно.

---

# 9. Этажи и залы

У больших таверн позже может быть пространственная организация по времени:

- main hall — срочное/ближайшее;
- следующий зал — позже сегодня или завтра;
- верхние/дальние залы — следующие дни;
- recurring hall — кампании;
- event hall — мероприятия.

Это игровая метафора фильтра времени.

Пользователь не идёт аватаром по лестнице. Он нажимает на лестницу/табличку и получает короткий переход.

---

# 10. Recruitment Tables

Это одна из ключевых механик World.

Стол означает:

> Для этой реальной игры сейчас нужны игроки.

Он **не означает**, что физическая партия прямо сейчас сидит за этим столом и её можно наблюдать.

У стола можно визуально считывать:

- game/recruitment id;
- master;
- system;
- название/короткую тему;
- дату/время;
- занятые и свободные места;
- короткую recruitment phrase;
- важные tags/requirements.

Самые срочные или релевантные столы получают приоритет. Не нужно показывать бесконечное количество; ориентир порядка десятка на один видимый hall — дальше лучше дополнительная организация.

## Проекции игроков за столом

Когда игрок занимает место, у стола появляется его **проекция**.

При этом тот же человек может своим обычным ambient-avatar продолжать гулять по таверне.

Это намеренная условность:

- wandering avatar = текущая социальная presence-подача;
- seated/ghost projection = человек уже состоит в этой recruitment party.

Когда партия заполнена, recruitment table уходит из публичного recruitment hall, и на его место может попасть другой набор.

Физическая игра, которая уже идёт, не остаётся публичной «витриной».

---

# 11. Аватары

У обычного пользователя есть один узнаваемый Player App avatar.

Стартовый тип — простой human chibi с быстрой кастомизацией:

- hairstyle;
- hair color;
- eye color;
- clothing/main color;
- базовая подача образа.

Позже могут появляться более необычные формы и косметика.

## Автономное поведение

Аватары должны казаться слегка самостоятельными:

- пройтись;
- остановиться;
- посмотреть на board;
- присесть;
- повернуться к другому человеку;
- посмотреть на stall;
- помахать;
- образовать рыхлую группу;
- уйти через дверь;
- показать status icon;
- постепенно исчезнуть после ухода.

Это **атмосферная симуляция**, а не серверная правда о координатах.

Серверу не нужно знать, что Вася стоит в `(624, 318)` и смотрит влево. Достаточно примерно:

```text
user_12
presence = active
worldContext = tavern_7
status = browsing
```

Клиент сам решает, как из этого сделать живого Васю.

---

# 12. Зоны движения, а не хаос

Чубрики не должны случайно ломать композицию.

Сцена должна иметь смысловые зоны/anchors:

- walk zones;
- forbidden zones;
- idle points;
- board interest points;
- bar points;
- table seat anchors;
- entrance/exit;
- stall interest points;
- social/group spots.

Автономные персонажи не должны:

- блокировать двери;
- стоять поверх board;
- перекрывать hitbox;
- ходить сквозь столы;
- превращать плотную сцену в кашу.

При высокой активности renderer лучше выберет часть людей для показа, чем будет честно рисовать 700 голов.

---

# 13. Presence: что означает видимый человек

Видимый avatar означает примерно:

- пользователь сейчас online в relevant Player App context; или
- совсем недавно покинул этот context.

Это **никогда не должно означать точное физическое присутствие в реальном клубе**.

World не является real-time location tracker.

После ухода avatar может некоторое время оставаться как recent trace и постепенно fade. В концепции ориентир — порядка 10–15 минут; simulation может ускорять время.

Пользователь должен иметь invisible/hidden mode и пользоваться приложением без публичного появления в World.

---

# 14. Social status

Человек может явно показать лёгкий intent:

- looking for a game;
- open to meeting people;
- waiting for my party;
- browsing;
- want to try a new system;
- available for online;
- do not disturb;
- hidden.

Status виден рядом с avatar и визуально отличается от временного speech bubble.

Цель — не построить сложную presence-policy систему, а дать человеку простой ответ на вопрос «зачем я сейчас тут торчу».

---

# 15. Взаимодействие с другим человеком

Клик/тап по avatar сначала открывает **компактную contextual card**, а не огромный профиль.

Примерно:

- имя;
- короткий status;
- несколько public-safe фактов;
- View Profile;
- Message;
- Invite, если context/permissions позволяют;
- React;
- Follow/Friend, если такая функция включена.

Полный профиль открывается только по явному действию.

Социальный путь должен быть естественным:

`увидел → заметил status → ткнул → возможно написал`

а не `открыл messenger → ищи незнакомца по имени`.

---

# 16. Мастера в городе

Один реальный человек может быть и игроком, и мастером. Но профессиональное World-присутствие мастера — отдельная контекстуальная сущность.

Когда мастер активно набирает игру, он может получить:

- более заметную representative figure;
- sign;
- recruitment marker;
- thematic prop;
- stall/workshop.

Важно: развитая фигура возле workshop — это **представитель master entity**, а не обязательная версия личного player-avatar владельца.

Это позволяет отдельно развивать профессиональный образ.

---

# 17. Stall → Workshop

Профессиональная сущность мастера может визуально развиваться примерно так:

`simple stall → upgraded stall → shop → workshop → advanced professional space`

Точные tiers не священны.

World Renderer должен уметь получить внешний state:

- tier;
- theme;
- sign;
- representative;
- decoration slots;
- temporary event layers;
- recruitment visual state.

И показать его.

Renderer **не решает**, почему tier открыт, сколько он стоил и имеет ли пользователь право его менять.

---

# 18. Клубы, сообщества и здания

Физический клуб имеет устойчивое место в City World и свою tavern/venue representation.

Сообщество без физического помещения тоже может иметь символическое место:

- guild hall;
- pavilion;
- tower;
- community square;
- другое тематическое здание.

На старте нужна **template/slot-based customization**, а не полный Sims-like freeform editor.

Причины простые:

- композиция остаётся читаемой;
- интерактивные точки не исчезают за декором;
- art direction не разваливается;
- проще производительность;
- проще ассортимент украшений;
- проще общий renderer для трёх приложений.

---

# 19. Украшения и развитие

Здание можно мыслить как тему + tier + набор логических slots.

Например:

- main sign;
- bar style;
- table skin;
- wall decorations;
- floor decoration;
- lamps/lighting;
- plants;
- trophy area;
- mascot;
- entrance;
- banners;
- seasonal slots;
- event slots.

Каждая theme может физически размещать эти slots по-разному, но логический смысл остаётся общим.

Позже свободу можно расширять. Но сначала лучше **контролируемая композиция с заменяемыми частями**.

---

# 20. Один World Renderer для трёх приложений

Это фундаментальная архитектурная идея.

## Player App

Использует полный живой World:

- City;
- taverns;
- guild/community locations;
- master stalls;
- avatars;
- recruitment;
- events;
- reactions;
- portal;
- regional map.

## MasterHub

Использует тот же renderer для **preview/edit профессионального присутствия мастера**:

- stall/workshop;
- themes;
- tiers;
- representative;
- signage;
- props;
- decorations;
- recruitment presentation;
- event layers.

Мастер может покупать/разблокировать/ставить вещи через MasterHub, но правила покупки принадлежат MasterHub/backend. World только рендерит preview и возвращает intents.

## ClubManager

Использует тот же renderer для **preview/edit tavern/venue/community location**:

- theme;
- tier;
- sign;
- table skin;
- decorations;
- trophy area;
- mascot/representative;
- seasonal/event appearance;
- operational visual state.

**Одна и та же appearance configuration должна выглядеть одинаково в editor preview и в Player App.**

Не должно быть трёх похожих renderer'ов, которые со временем разъедутся.

---

# 21. Renderer не владеет экономикой

World может получить:

```text
theme = tavern.cozy.red
tier = 3
mainSign = moon_sign
wall.left.2 = dragon_banner
eventLayer = autumn_festival
```

и отрисовать это.

Но он не решает:

- доступен ли `dragon_banner`;
- сколько он стоит;
- хватает ли currency;
- кто владелец;
- разрешено ли поставить его сейчас;
- прошла ли транзакция;
- какие progression requirements выполнены.

World умеет:

- preview;
- показать `available/locked`, если host передал это состояние;
- сгенерировать intent `apply`, `request purchase`, `select slot`.

Решение принимает host app/backend.

---

# 22. Craft District

В городе есть место для ремесленных профессиональных сущностей:

- artists;
- miniature painters;
- sculptors;
- terrain builders;
- map makers;
- composers;
- accessory/dice makers;
- indie publishers;
- tabletop designers;
- prop/costume makers;
- другие релевантные craftspeople.

Они могут иметь workshop/storefront presence.

Player App при этом не должен превращаться в огромный внутренний marketplace. World здесь — способ **увидеть присутствие и перейти к профильному действию**.

---

# 23. Boards

Нужно различать как минимум два класса.

## Official board

Структурированные реальные наборы, опубликованные через MasterHub/ClubManager/approved community tools.

Ведут к normal game details/join flow.

## Community board

Свободная социальная поверхность:

- короткие notes;
- drawings;
- jokes;
- local questions;
- informal invitations;
- social traces.

Она должна визуально отличаться от official recruitment board.

---

# 24. Speech bubbles и рисунки

У пользователя может быть короткий временный bubble:

- text;
- быстрый drawing.

Рисовалка намеренно простая:

- одна мягкая толщина;
- несколько цветов;
- eraser;
- touch/mouse/stylus.

На создание рисунка таймера нет.

После публикации bubble существует короткое время и исчезает. Это не новый полноценный social feed, а краткоживущий человеческий след в пространстве.

---

# 25. Reactions

World-reactions — не вечный счётчик лайков под постом.

Они выглядят как плавающие эмоции над target:

- heart;
- sparkle;
- laughter;
- surprise;
- celebration;
- curiosity;
- greeting;
- excitement/fire.

Target может быть:

- avatar;
- tavern;
- stall;
- table;
- drawing;
- board post;
- festival object;
- craft storefront.

Reactions постепенно drift/fade и исчезают. При большом количестве client агрегирует их в clusters/flocks, а не создаёт сотни отдельных components.

Публичная reaction palette — positive/neutral. Негативные оценки, reports и moderation живут в других системах.

---

# 26. Время суток и атмосфера

World может иметь:

- morning;
- day;
- evening;
- night;
- seasons;
- festival/convention states.

Это меняет свет, background accents, props и ощущение.

**Время не блокирует функции.** Ночью Search всё равно работает; World не симулирует реальные часы работы как gameplay gate.

---

# 27. Фестивали и события

Festival/event — временный визуальный слой, связанный с настоящей scheduled activity:

- games;
- club/community event;
- themed online program;
- convention-like activity.

Он может добавлять:

- banners;
- props;
- lighting;
- stage;
- entrance;
- crowd accents;
- temporary signage.

Несколько событий могут сосуществовать, но scene readability важнее буквальной демонстрации всего.

World не считает funding/cooldown/economy — только получает готовое состояние и показывает его.

---

# 28. Operational visual state

Некоторые реальные состояния могут иметь визуальное отражение.

Например клуб с плохой недавней эксплуатацией может выглядеть менее ухоженно, даже если у него остались старые дорогие украшения.

Важно не смешивать в одну шкалу:

- rating;
- operational health;
- progression/tier;
- City contribution/Glory;
- purchased decorations;
- subscription state.

Renderer получает уже безопасные visual flags и отображает их. Он не вычисляет бизнес-логику.

---

# 29. Online Portal и language archipelagos

Pure online games, не привязанные к локальной tavern/community, находятся за центральным portal.

Поздняя полная концепция online-world — **floating language archipelagos**.

Главная организация — язык игры, а не язык интерфейса:

- central public island;
- guild islands;
- master platforms;
- recruitment boards;
- craft presence;
- event spaces.

Пользователь сам выбирает primary/additional game languages.

Это большой поздний слой. Начинать World с него не нужно.

---

# 30. Соседние реальные города

Physical World локальный, но пользователь не заперт в одном City.

Соседние/релевантные City clusters доступны через **упрощённую fantasy regional map**.

Это не навигатор.

Она может показывать:

- City nodes;
- approximate links/directions;
- nearby hubs;
- favorited Cities;
- notable festivals/events;
- человеческие travel bands: `Nearby`, `Around an hour`, `A few hours`, `Easy day trip`.

Переход — короткий transition между social hubs. Аватар не шагает пять часов по дороге.

Когда пользователь входит в другой City, туда переключаются:

- discovery;
- taverns;
- communities;
- public events;
- master recruitment;
- Favorites context;
- public avatar presence.

Точное clustering — задача shared service, не World renderer.

---

# 31. Камера

World — не бесконечная стратегия.

Нужны несколько понятных масштабов:

1. district/city overview;
2. normal interaction;
3. close object/person view.

Можно pan/drag сцену. Camera должна помогать замечать объекты, а не становиться отдельной механикой сложности.

City activity summary может по клику сам перевести camera к нужному объекту.

---

# 32. Интерактивность должна быть очевидной

Пользователь не должен гадать:

> Эта бочка — кнопка или просто бочка?

Интерактивные объекты:

- стоят в намеренно понятных местах;
- имеют нормальные hitboxes;
- реагируют на hover/touch/focus;
- при необходимости подсвечиваются;
- сначала открывают компактную contextual card.

Полный strict screen открывается только по следующему явному действию.

---

# 33. Обычный UI остаётся Flutter UI

Сама живая сцена может рендериться Flame/Canvas.

Но:

- cards;
- bottom sheets;
- dialogs;
- buttons;
- editor panels;
- accessibility UI;
- forms;
- strict game/profile details

лучше держать обычными Flutter widgets.

World не должен рисовать весь текст и меню в sprite sheet только потому, что он «игровой».

---

# 34. Accessibility и performance

World должен уметь деградировать без потери смысла:

- Full Animation;
- Reduced Animation;
- Lower FPS;
- Static/Low-motion avatars;
- Simplified background;
- Reduced Motion;
- Quiet Mode;
- обычный list/text view текущего City context.

Важная функция не существует только в пиксельной сцене.

На слабом устройстве World становится спокойнее, а не бесполезнее.

## Quiet Mode

Уменьшает:

- random avatars;
- reactions;
- ambient animation;
- визуальный шум.

И сильнее выделяет:

- favorites;
- subscriptions;
- important objects;
- familiar places.

---

# 35. Demo / Simulation — часть настоящего проекта

World должен уметь жить на simulated data **постоянно**, а не только до первого подключения сервера.

Simulation может:

- заселять City;
- заводить людей в tavern;
- выводить их;
- менять status;
- создавать recruitment;
- занимать seats;
- заполнять table;
- удалять закрытый table;
- активировать master stall;
- запускать event;
- добавлять reactions;
- менять time of day;
- имитировать low/high activity;
- воспроизводить deterministic scenario для screenshots/tests.

Потом реальный provider заменяет **источник событий**, а scene/runtime остаётся тем же.

---

# 36. Что World знает, а чего не знает

World хорошо знает:

- как выглядит scene;
- где interaction points;
- как двигаются avatars;
- как показать presence;
- как собрать tavern/stall по appearance config;
- как показать recruitment table;
- как наложить event layer;
- как сделать transition;
- как открыть contextual card;
- как вернуть наружу user intent.

World не обязан знать:

- как устроен login;
- как работает Fluxer token/session;
- как считается rating;
- как проводится payment;
- как MasterHub принимает заявку;
- как ClubManager управляет venue;
- кто имеет authority над Room;
- как устроена Altar gameplay session;
- где хранятся messages;
- как shared service решил City clustering.

---

# 37. Технологическая рамка

**Обязательная основа — Flutter + Dart.**

Не отдельный Godot/Unity/Qt-клиент и не web-game внутри WebView.

Цель экосистемы — общий Flutter/Dart client foundation для Android, iOS, Windows, macOS и Linux.

Для realtime 2D-сцены разумно использовать **Flame**, если он реально упрощает:

- update/render loop;
- components;
- sprite animation;
- camera;
- effects;
- hit testing/input;
- scene composition.

Flame работает поверх Flutter и его `GameWidget` встраивается в обычное Flutter widget tree. Поэтому scene может быть Flame, а cards/panels/editor UI — обычным Flutter.

Но наружные models/contracts желательно держать чистыми Dart/Flutter и не заставлять Player App, MasterHub или ClubManager знать о внутренних Flame classes.

Подробнее — в архитектурном документе.

---

# 38. Главный архитектурный образ

```text
        REAL ECOSYSTEM STATE
                 │
                 ▼
          safe projections
                 │
                 ▼
           WORLD STATE
                 │
         ┌───────┴────────┐
         │                │
         ▼                ▼
   scene/runtime      Flutter UI
         │                │
         └───────┬────────┘
                 ▼
        what the user sees
                 │
                 ▼
           World Intent
                 │
                 ▼
             HOST APP
```

World получает **проекцию реальности**, превращает её в живое пространство и возвращает наружу **намерения пользователя**.

Он не становится владельцем всей экосистемы.

---

# 39. Проверка правильности архитектуры

Если завтра вместо simulation provider подключить:

> real presence service: `user_548 entered tavern_12`

renderer не должен потребовать переписывания.

Если MasterHub показывает `WorkshopAppearance A` в editor preview, а Player App получает ту же конфигурацию, визуальный результат должен совпасть.

Если ClubManager меняет `wall.left.2` у tavern и backend публикует новую projection, Player App должен показать тот же decoration тем же renderer.

Если эти три условия выполняются — World построен в правильную сторону.

---

# 40. Конечная мысль

World должен быть местом, куда хочется заглянуть даже без конкретной задачи.

Но под каждым красивым объектом должна оставаться реальная полезная вещь:

- человек;
- игра;
- мастер;
- клуб;
- сообщество;
- событие;
- Room;
- действие.

Он не маскирует пустоту игровыми эффектами.

Он делает **реальную настольную жизнь видимой**.

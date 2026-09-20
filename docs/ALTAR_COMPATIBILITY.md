# Проверка совместимости с AltarAppsReborn

Проверен read-only снимок `EriArk/AltarAppsReborn`:
`7ab85c3997789661e9f0b9a13dafaedb2bfc89d1`.
Ничего в исходный репозиторий не записывалось и не отправлялось.
Временная копия и тестовый стенд находятся в исключённой из Git `.compatibility`.
Код/данные закрытого host-проекта в World не копируются для публикации.

## Что подтверждено

- Host использует Flutter/Dart workspace, отдельные Player App, MasterHub,
  ClubManager и общие пакеты. Dart constraint — `^3.12.2`, CI Flutter — `3.44.2`.
- World — встраиваемый Flutter package, публичные типы не зависят от Flame,
  Fluxer, собственного роутера или контейнера зависимостей.
- `WorldModule` принимает host context, capabilities, bridge и источник проекций.
- `PublicOrganizationProfile` содержит `organizationProfileId`, `kind`,
  `displayName`, `shortDescription`, `layout`. **Города, адреса, координат,
  размещения и World-оформления в этом DTO нет.**
- Адаптер в `tools/compatibility/organization_world_mapper.dart.template`
  скомпилирован и проверен тестом с настоящим сгенерированным transport-пакетом
  host. ID и вид организации сохраняются. Пространственные поля приходят
  отдельными явными аргументами; отсутствующие поля не выдумываются.
- Тот же контракт покрывает актуальный `PublicProfessionalProfile` с видами
  `master` и `creator`. Профессиональный representative ID не подменяет личный
  Player avatar ID.
- Все обычные формы наследуют Theme/Directionality/MediaQuery host;
  map art имеет собственную палитру. Готовый языковой пакет host не импортируется.

## Как воспроизвести

Имея доступ на чтение к host-репозиторию:

```powershell
git clone --depth 1 --filter=blob:none --no-checkout https://github.com/EriArk/AltarAppsReborn.git .compatibility/AltarAppsReborn
./tools/verify-altar-compatibility.ps1
```

Скрипт использует `git archive` фиксированного коммита, собирает отдельный стенд
и запускает контрактный тест. Он не делает checkout, commit или push в host.
Если shallow-копия уже не содержит указанный коммит, его нужно получить отдельно
или явно указать другой `-Revision` для новой проверки совместимости.

## Что должен предоставить host при интеграции

1. Безопасную World-проекцию организаций/мастеров, городов, направлений, постоянных
   мест, appearance, наборов и разрешённого присутствия.
2. `WorldDataSource.watch()`: первоначальное состояние и дальнейшие обновления
   без пропуска между загрузкой и подпиской. Можно сводить серверные delta-events
   к полным immutable snapshot внутри адаптера.
3. Обработку намерений: маршруты Profile/Search/Rooms/Messages, создание клуба,
   изменение оформления/избранного/статуса с проверкой permissions backend.
4. Host-время, reconnect/expiry policy и выборку людей. Presence означает
   online/recent app context; это не физическое нахождение в клубе.
5. Locale (`en`, `ru` или `he`) через host context; неизвестный locale использует
   английский fallback. География карты не зеркалится в RTL.

## Границы проверки

Контрактный тест выполнен на локальном Flutter **3.47.4** с реальными DTO host.
Это подтверждает совместимость типов и способа встраивания, но **не** завершённую
интеграцию с сервером, сессиями, Fluxer, навигацией и permissions AltarApps.
CI настроен на Windows/Linux quality checks, Windows release и Android release.
iOS/macOS требуют Apple runner и остаются отдельной будущей проверкой.
Неиспользуемые сетевые/картографические зависимости убраны для уменьшения
вероятности конфликтов. Полный host build не выполнялся и не изменялся.

Нельзя считать локально добавленный в Playground клуб опубликованной организацией
AltarApps. `canCreateClub`/`canEditAppearance` управляют доступностью UI;
окончательную авторизацию каждой записи обязан выполнять host/backend.

# Изображения и география

- `assets/art/environments.png`: созданный для проекта лист рисованных зданий
  и окружения с прозрачностью, используемый в карте и preview.
- `assets/art/adventurers.png`: созданный для проекта лист анимации персонажей
  (два персонажа, четыре кадра на каждого).
- `assets/art/terrain.png`: созданные для проекта текстуры травы, песка и воды.
- `assets/art/tavern_hall.png`: новый сгенерированный рисованный зал таверны
  с отдельными местами для вывески, досок и наборных столов, 19 сентября 2026.

Изображения созданы через встроенный imagegen. Присланные пользователем примеры
служили ориентиром стиля; изображения с чужими водяными знаками не включены
в ресурсы приложения. Во время работы приложения генеративная модель не нужна.
Изображения уже находятся в `assets`, а не только во временном каталоге генератора.

Граница региона взята из [Natural Earth 1:10m](https://www.naturalearthdata.com/about/terms-of-use/)
(public domain) и сохранена в `assets/geography/region.json`.
Это картографическая генерализация исходного набора, а не навигационная карта.
Координаты городов сохранены из предыдущего прототипа; они служат региональными
якорями, а рисунки и подписи могут быть вынесены в сторону с линией к якорю.

Реальные городские OSM-выгрузки предыдущего прототипа больше не читаются,
не входят в bundle и исключены из Git. Города строятся из собственного
`CityLayout` с вымышленными улицами и рисованными объектами.
# World props — 2026-09-19

`assets/art/world_props.png` was generated with the built-in image_gen tool,
then background extraction was requested with the same tool. Alpha checked:
background corners are fully transparent. No third-party reference art is shipped.

Prompt: hand-painted isometric fantasy sprite atlas, 1536×1024, 4×2 grid;
table, community board, master stall, cyan portal, lantern, trophy display,
empty chair and sleeping dragon mascot; warm wood, amber/burgundy/teal palette;
isolated sprites with alpha transparency, no text, brands or watermarks.
Follow-up: preserve the eight objects/grid and remove all background to true alpha.

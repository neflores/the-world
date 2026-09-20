import 'package:flutter/widgets.dart';
import '../model/world_presence.dart';

enum WorldLanguage { english, russian, hebrew }

class WorldStrings {
  const WorldStrings._(this.language);
  final WorldLanguage language;

  factory WorldStrings.forTag(String tag) {
    final normalized = tag.toLowerCase();
    return WorldStrings._(
      normalized.startsWith('he')
          ? WorldLanguage.hebrew
          : normalized.startsWith('ru')
          ? WorldLanguage.russian
          : WorldLanguage.english,
    );
  }

  TextDirection get direction =>
      language == WorldLanguage.hebrew ? TextDirection.rtl : TextDirection.ltr;

  String get(String key) =>
      (_values[key]?[language] ?? _values[key]?[WorldLanguage.english] ?? key);

  String status(SocialStatus status) => get('status.${status.name}');
  String places(int count) => switch (language) {
    WorldLanguage.russian => '$count мест для исследования',
    WorldLanguage.hebrew => '$count מקומות לגלות',
    WorldLanguage.english => '$count places to discover',
  };
  String openSeats(int count) => switch (language) {
    WorldLanguage.russian => 'Свободных мест: $count',
    WorldLanguage.hebrew => '$count מקומות פנויים',
    WorldLanguage.english => '$count open seats',
  };

  static const _values = <String, Map<WorldLanguage, String>>{
    'restricted': {
      WorldLanguage.english: 'World is not available in this context.',
      WorldLanguage.russian: 'World недоступен в этом контексте.',
      WorldLanguage.hebrew: 'World אינו זמין בהקשר הזה.',
    },
    'playground': {
      WorldLanguage.english: 'Playground · local data',
      WorldLanguage.russian: 'Playground · локальные данные',
      WorldLanguage.hebrew: 'Playground · נתונים מקומיים',
    },
    'socialStatus': {
      WorldLanguage.english: 'Social status',
      WorldLanguage.russian: 'Социальный статус',
      WorldLanguage.hebrew: 'מצב חברתי',
    },
    'quiet': {
      WorldLanguage.english: 'Quiet mode',
      WorldLanguage.russian: 'Тихий режим',
      WorldLanguage.hebrew: 'מצב שקט',
    },
    'animate': {
      WorldLanguage.english: 'Enable animation',
      WorldLanguage.russian: 'Включить анимацию',
      WorldLanguage.hebrew: 'הפעלת הנפשה',
    },
    'list': {
      WorldLanguage.english: 'List view',
      WorldLanguage.russian: 'Список',
      WorldLanguage.hebrew: 'תצוגת רשימה',
    },
    'map': {
      WorldLanguage.english: 'Show map',
      WorldLanguage.russian: 'Показать карту',
      WorldLanguage.hebrew: 'הצגת מפה',
    },
    'addClub': {
      WorldLanguage.english: 'Add club',
      WorldLanguage.russian: 'Добавить клуб',
      WorldLanguage.hebrew: 'הוספת מועדון',
    },
    'avatar': {
      WorldLanguage.english: 'Customize your avatar',
      WorldLanguage.russian: 'Настроить аватар',
      WorldLanguage.hebrew: 'התאמת הדמות שלך',
    },
    'atlas': {
      WorldLanguage.english: 'The atlas of Israel',
      WorldLanguage.russian: 'Атлас Израиля',
      WorldLanguage.hebrew: 'האטלס של ישראל',
    },
    'findCity': {
      WorldLanguage.english: 'Find a city',
      WorldLanguage.russian: 'Найти город',
      WorldLanguage.hebrew: 'חיפוש עיר',
    },
    'findPlace': {
      WorldLanguage.english: 'Find a place',
      WorldLanguage.russian: 'Найти место',
      WorldLanguage.hebrew: 'חיפוש מקום',
    },
    'favorites': {
      WorldLanguage.english: 'Favorites',
      WorldLanguage.russian: 'Избранное',
      WorldLanguage.hebrew: 'מועדפים',
    },
    'centralSquare': {
      WorldLanguage.english: 'Central Square',
      WorldLanguage.russian: 'Центральная площадь',
      WorldLanguage.hebrew: 'הכיכר המרכזית',
    },
    'onlinePortal': {
      WorldLanguage.english: 'Online Portal',
      WorldLanguage.russian: 'Онлайн-портал',
      WorldLanguage.hebrew: 'שער המשחקים המקוונים',
    },
    'creatorDistrict': {
      WorldLanguage.english: 'Creator District',
      WorldLanguage.russian: 'Квартал авторов',
      WorldLanguage.hebrew: 'רובע היוצרים',
    },
    'noCities': {
      WorldLanguage.english: 'No cities match your search.',
      WorldLanguage.russian: 'Города не найдены.',
      WorldLanguage.hebrew: 'לא נמצאו ערים.',
    },
    'noPlaces': {
      WorldLanguage.english: 'No places here yet.',
      WorldLanguage.russian: 'Здесь пока нет мест.',
      WorldLanguage.hebrew: 'עדיין אין כאן מקומות.',
    },
    'aroundSquare': {
      WorldLanguage.english: 'Around the square',
      WorldLanguage.russian: 'На площади',
      WorldLanguage.hebrew: 'מסביב לכיכר',
    },
    'presenceNotice': {
      WorldLanguage.english: 'App activity, not physical presence',
      WorldLanguage.russian:
          'Активность в приложении, а не физическое присутствие',
      WorldLanguage.hebrew: 'פעילות באפליקציה, לא נוכחות פיזית',
    },
    'allIsrael': {
      WorldLanguage.english: 'All Israel',
      WorldLanguage.russian: 'Весь Израиль',
      WorldLanguage.hebrew: 'כל ישראל',
    },
    'previousArea': {
      WorldLanguage.english: 'Previous neighborhood',
      WorldLanguage.russian: 'Предыдущий район',
      WorldLanguage.hebrew: 'השכונה הקודמת',
    },
    'nextArea': {
      WorldLanguage.english: 'Next neighborhood',
      WorldLanguage.russian: 'Следующий район',
      WorldLanguage.hebrew: 'השכונה הבאה',
    },
    'zoomIn': {
      WorldLanguage.english: 'Zoom in',
      WorldLanguage.russian: 'Приблизить',
      WorldLanguage.hebrew: 'התקרבות',
    },
    'zoomOut': {
      WorldLanguage.english: 'Zoom out',
      WorldLanguage.russian: 'Отдалить',
      WorldLanguage.hebrew: 'התרחקות',
    },
    'wholeMap': {
      WorldLanguage.english: 'Show whole map',
      WorldLanguage.russian: 'Показать всю карту',
      WorldLanguage.hebrew: 'הצגת המפה כולה',
    },
    'close': {
      WorldLanguage.english: 'Close',
      WorldLanguage.russian: 'Закрыть',
      WorldLanguage.hebrew: 'סגירה',
    },
    'profile': {
      WorldLanguage.english: 'View profile',
      WorldLanguage.russian: 'Открыть профиль',
      WorldLanguage.hebrew: 'הצגת פרופיל',
    },
    'message': {
      WorldLanguage.english: 'Message',
      WorldLanguage.russian: 'Сообщение',
      WorldLanguage.hebrew: 'הודעה',
    },
    'invite': {
      WorldLanguage.english: 'Invite',
      WorldLanguage.russian: 'Пригласить',
      WorldLanguage.hebrew: 'הזמנה',
    },
    'enter': {
      WorldLanguage.english: 'Enter',
      WorldLanguage.russian: 'Войти',
      WorldLanguage.hebrew: 'כניסה',
    },
    'retry': {
      WorldLanguage.english: 'Unable to complete this action. Please retry.',
      WorldLanguage.russian: 'Не удалось выполнить действие. Попробуйте снова.',
      WorldLanguage.hebrew: 'לא ניתן להשלים את הפעולה. נסו שוב.',
    },
    'loadError': {
      WorldLanguage.english: 'Unable to load World. Reconnect and try again.',
      WorldLanguage.russian:
          'Не удалось загрузить World. Подключитесь и попробуйте снова.',
      WorldLanguage.hebrew: 'לא ניתן לטעון את World. התחברו מחדש ונסו שוב.',
    },
    'artError': {
      WorldLanguage.english: 'Unable to load the atlas artwork.',
      WorldLanguage.russian: 'Не удалось загрузить рисунки атласа.',
      WorldLanguage.hebrew: 'לא ניתן לטעון את איורי האטלס.',
    },
    'stale': {
      WorldLanguage.english:
          'Connection interrupted. Showing the last received state.',
      WorldLanguage.russian:
          'Соединение прервано. Показано последнее полученное состояние.',
      WorldLanguage.hebrew: 'החיבור נותק. מוצג המצב האחרון שהתקבל.',
    },
    'status.lookingForGame': {
      WorldLanguage.english: 'Looking for a game',
      WorldLanguage.russian: 'Ищу игру',
      WorldLanguage.hebrew: 'מחפש משחק',
    },
    'status.openToMeet': {
      WorldLanguage.english: 'Open to meeting people',
      WorldLanguage.russian: 'Готов знакомиться',
      WorldLanguage.hebrew: 'פתוח להיכרות',
    },
    'status.waitingForParty': {
      WorldLanguage.english: 'Waiting for my party',
      WorldLanguage.russian: 'Жду свою группу',
      WorldLanguage.hebrew: 'מחכה לקבוצה שלי',
    },
    'status.browsing': {
      WorldLanguage.english: 'Browsing',
      WorldLanguage.russian: 'Осматриваюсь',
      WorldLanguage.hebrew: 'מסתובב',
    },
    'status.newSystem': {
      WorldLanguage.english: 'Trying a new system',
      WorldLanguage.russian: 'Пробую новую систему',
      WorldLanguage.hebrew: 'מנסה שיטה חדשה',
    },
    'status.online': {
      WorldLanguage.english: 'Available for online',
      WorldLanguage.russian: 'Готов играть онлайн',
      WorldLanguage.hebrew: 'זמין למשחק מקוון',
    },
    'status.doNotDisturb': {
      WorldLanguage.english: 'Do not disturb',
      WorldLanguage.russian: 'Не беспокоить',
      WorldLanguage.hebrew: 'נא לא להפריע',
    },
    'status.hidden': {
      WorldLanguage.english: 'Hidden',
      WorldLanguage.russian: 'Скрыт',
      WorldLanguage.hebrew: 'מוסתר',
    },
  };
}

class WorldLocalization extends InheritedWidget {
  const WorldLocalization({
    required this.strings,
    required super.child,
    super.key,
  });
  final WorldStrings strings;
  static WorldLocalization? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WorldLocalization>();
  static WorldStrings of(BuildContext context) =>
      maybeOf(context)?.strings ?? WorldStrings.forTag('en');
  @override
  bool updateShouldNotify(WorldLocalization oldWidget) =>
      oldWidget.strings.language != strings.language;
}

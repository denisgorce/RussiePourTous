import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ModuleInfo {
  final int id;
  final String iconEmoji;
  final List<Color>? gradient;
  final Map<String, String> titles;
  final Map<String, String> subtitles;
  final Map<String, String> descriptions;
  final List<LessonInfo> lessons;

  const ModuleInfo({
    required this.id,
    required this.iconEmoji,
    required this.titles,
    required this.subtitles,
    required this.descriptions,
    required this.lessons,
    this.gradient,
  });
}

class LessonInfo {
  final int moduleId;
  final int lessonId;
  final String iconEmoji;
  final Map<String, String> titles;
  final Map<String, String> subtitles;
  final int estimatedMinutes;

  const LessonInfo({
    required this.moduleId,
    required this.lessonId,
    required this.iconEmoji,
    required this.titles,
    required this.subtitles,
    required this.estimatedMinutes,
  });
}

class ContentService {
  final Map<String, Map<String, dynamic>> _lessonCache = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  // ── MODULE CATALOG — RUSSIE POUR TOUS ─────────────────────────
  static const List<ModuleInfo> modules = [
    ModuleInfo(
      id: 1, iconEmoji: '🏰',
      titles: {'fr': 'Les Racines de la Russie', 'ru': 'Корни России'},
      subtitles: {'fr': 'Histoire & Identité', 'ru': 'История и идентичность'},
      descriptions: {
        'fr': 'Des Varègues à Poutine — les grandes étapes qui ont forgé la Russie.',
        'ru': 'От варягов до Путина — ключевые этапы, создавшие Россию.'
      },
      lessons: [
        LessonInfo(moduleId:1, lessonId:1, iconEmoji:'🌱',
          titles:{'fr':'Naître Russe — l\'âme d\'un peuple','ru':'Стать русским — душа народа'},
          subtitles:{'fr':'Histoire, valeurs et codes fondateurs','ru':'История, ценности и основы'}, estimatedMinutes:15),
        LessonInfo(moduleId:1, lessonId:2, iconEmoji:'⚔️',
          titles:{'fr':'Des Varègues aux Tsars','ru':'От варягов до царей'},
          subtitles:{'fr':'Les origines et la Russie impériale','ru':'Истоки и имперская Россия'}, estimatedMinutes:12),
        LessonInfo(moduleId:1, lessonId:3, iconEmoji:'☭',
          titles:{'fr':'L\'URSS — l\'empire du socialisme','ru':'СССР — империя социализма'},
          subtitles:{'fr':'1917–1991, l\'expérience soviétique','ru':'1917–1991, советский опыт'}, estimatedMinutes:14),
        LessonInfo(moduleId:1, lessonId:4, iconEmoji:'🇷🇺',
          titles:{'fr':'La Russie post-soviétique','ru':'Постсоветская Россия'},
          subtitles:{'fr':'Des années 90 à l\'ère Poutine','ru':'От 90-х до эпохи Путина'}, estimatedMinutes:12),
        LessonInfo(moduleId:1, lessonId:5, iconEmoji:'🌍',
          titles:{'fr':'La Russie et le monde','ru':'Россия и мир'},
          subtitles:{'fr':'Grande puissance, voisins, diplomatie','ru':'Великая держава, соседи, дипломатия'}, estimatedMinutes:10),
      ],
    ),
    ModuleInfo(
      id: 2, iconEmoji: '🗺️',
      titles: {'fr': 'L\'Immensité Russe', 'ru': 'Бескрайняя Россия'},
      subtitles: {'fr': 'Géographie & Régions', 'ru': 'География и регионы'},
      descriptions: {
        'fr': 'De Kaliningrad à Vladivostok — 11 fuseaux horaires, des paysages infinis.',
        'ru': 'От Калининграда до Владивостока — 11 часовых поясов, бесконечные пейзажи.'
      },
      lessons: [
        LessonInfo(moduleId:2, lessonId:1, iconEmoji:'🏙️',
          titles:{'fr':'Moscou, la Troisième Rome','ru':'Москва, третий Рим'},
          subtitles:{'fr':'La capitale et son âme','ru':'Столица и её душа'}, estimatedMinutes:12),
        LessonInfo(moduleId:2, lessonId:2, iconEmoji:'🏙️',
          titles:{'fr':'Saint-Pétersbourg — la fenêtre sur l\'Europe','ru':'Санкт-Петербург — окно в Европу'},
          subtitles:{'fr':'Pierre le Grand et la ville tsariste','ru':'Пётр Великий и царский город'}, estimatedMinutes:12),
        LessonInfo(moduleId:2, lessonId:3, iconEmoji:'❄️',
          titles:{'fr':'La Sibérie — l\'immensité froide','ru':'Сибирь — холодная бесконечность'},
          subtitles:{'fr':'Géographie, ressources, peuples','ru':'География, ресурсы, народы'}, estimatedMinutes:10),
        LessonInfo(moduleId:2, lessonId:4, iconEmoji:'🏔️',
          titles:{'fr':'Le Caucase et les Ouraliens','ru':'Кавказ и Уральский регион'},
          subtitles:{'fr':'Montagnes, diversité et histoire','ru':'Горы, разнообразие и история'}, estimatedMinutes:10),
        LessonInfo(moduleId:2, lessonId:5, iconEmoji:'🌊',
          titles:{'fr':'L\'Extrême-Orient russe','ru':'Российский Дальний Восток'},
          subtitles:{'fr':'Vladivostok, le Pacifique et l\'Arctique','ru':'Владивосток, Тихий океан и Арктика'}, estimatedMinutes:10),
      ],
    ),
    ModuleInfo(
      id: 3, iconEmoji: '🏛️',
      titles: {'fr': 'L\'État Russe', 'ru': 'Российское государство'},
      subtitles: {'fr': 'Politique & Institutions', 'ru': 'Политика и институты'},
      descriptions: {
        'fr': 'Comment fonctionne réellement la Russie — Présidence, Douma, régions.',
        'ru': 'Как реально работает Россия — Президентство, Дума, регионы.'
      },
      lessons: [
        LessonInfo(moduleId:3, lessonId:1, iconEmoji:'📜',
          titles:{'fr':'La Constitution et le Système présidentiel','ru':'Конституция и президентская система'},
          subtitles:{'fr':'La verticale du pouvoir','ru':'Вертикаль власти'}, estimatedMinutes:12),
        LessonInfo(moduleId:3, lessonId:2, iconEmoji:'🗳️',
          titles:{'fr':'Élections et Partis en Russie','ru':'Выборы и партии в России'},
          subtitles:{'fr':'Démocratie et réalité politique','ru':'Демократия и политическая реальность'}, estimatedMinutes:10),
        LessonInfo(moduleId:3, lessonId:3, iconEmoji:'⚖️',
          titles:{'fr':'La Justice, la Police, l\'Armée','ru':'Правосудие, полиция, армия'},
          subtitles:{'fr':'Les forces de l\'État','ru':'Силовые структуры'}, estimatedMinutes:10),
        LessonInfo(moduleId:3, lessonId:4, iconEmoji:'🌐',
          titles:{'fr':'Fédéralisme et Minorités','ru':'Федерализм и меньшинства'},
          subtitles:{'fr':'85 sujets fédéraux, 190 peuples','ru':'85 субъектов федерации, 190 народов'}, estimatedMinutes:10),
        LessonInfo(moduleId:3, lessonId:5, iconEmoji:'📰',
          titles:{'fr':'Médias, Censure et Opinion publique','ru':'СМИ, цензура и общественное мнение'},
          subtitles:{'fr':'L\'information en Russie','ru':'Информация в России'}, estimatedMinutes:10),
      ],
    ),
    ModuleInfo(
      id: 4, iconEmoji: '🌙',
      titles: {'fr': 'L\'Âme Russe', 'ru': 'Русская душа'},
      subtitles: {'fr': 'Mentalité & Valeurs', 'ru': 'Менталитет и ценности'},
      descriptions: {
        'fr': 'Ce que les Français ne comprennent pas toujours — et pourquoi c\'est fascinant.',
        'ru': 'То, что французы не всегда понимают — и почему это так увлекательно.'
      },
      lessons: [
        LessonInfo(moduleId:4, lessonId:1, iconEmoji:'💭',
          titles:{'fr':'La Doushá — l\'âme comme concept','ru':'Душа как концепция'},
          subtitles:{'fr':'Intériorité, mélancolie et générosité','ru':'Душевность, меланхолия и щедрость'}, estimatedMinutes:12),
        LessonInfo(moduleId:4, lessonId:2, iconEmoji:'🤝',
          titles:{'fr':'Relations humaines et collectivisme','ru':'Человеческие отношения и коллективизм'},
          subtitles:{'fr':'Amitié, famille, cercle intime','ru':'Дружба, семья, ближний круг'}, estimatedMinutes:12),
        LessonInfo(moduleId:4, lessonId:3, iconEmoji:'😐',
          titles:{'fr':'Pourquoi les Russes ne sourient pas','ru':'Почему русские не улыбаются'},
          subtitles:{'fr':'La politesse russe décryptée','ru':'Расшифровка русской вежливости'}, estimatedMinutes:10),
        LessonInfo(moduleId:4, lessonId:4, iconEmoji:'🛐',
          titles:{'fr':'L\'Orthodoxie et la Spiritualité russe','ru':'Православие и русская духовность'},
          subtitles:{'fr':'Religion, identité, tradition','ru':'Религия, идентичность, традиция'}, estimatedMinutes:10),
        LessonInfo(moduleId:4, lessonId:5, iconEmoji:'🌿',
          titles:{'fr':'La Dacha — l\'art de vivre à la campagne','ru':'Дача — искусство жизни на природе'},
          subtitles:{'fr':'Nature, potager et ressourcement','ru':'Природа, огород и восстановление'}, estimatedMinutes:10),
      ],
    ),
    ModuleInfo(
      id: 5, iconEmoji: '🛢️',
      titles: {'fr': 'L\'Économie Russe', 'ru': 'Российская экономика'},
      subtitles: {'fr': 'Pétrole, Industrie & Vie économique', 'ru': 'Нефть, промышленность и экономика'},
      descriptions: {
        'fr': 'Pétrole, gaz, industrie militaire — les ressorts de la puissance économique russe.',
        'ru': 'Нефть, газ, военная промышленность — механизмы российской экономической мощи.'
      },
      lessons: [
        LessonInfo(moduleId:5, lessonId:1, iconEmoji:'⛽',
          titles:{'fr':'Pétrole et Gaz — la malédiction des ressources','ru':'Нефть и газ — ресурсное проклятие'},
          subtitles:{'fr':'Comment les hydrocarbures structurent l\'économie','ru':'Как углеводороды структурируют экономику'}, estimatedMinutes:12),
        LessonInfo(moduleId:5, lessonId:2, iconEmoji:'🏭',
          titles:{'fr':'L\'Industrie et le Complexe militaro-industriel','ru':'Промышленность и военно-промышленный комплекс'},
          subtitles:{'fr':'Aérospatiale, armement, nucléaire','ru':'Аэрокосмос, вооружение, ядерная отрасль'}, estimatedMinutes:12),
        LessonInfo(moduleId:5, lessonId:3, iconEmoji:'🪙',
          titles:{'fr':'Le Rouble, les Banques et les Oligarques','ru':'Рубль, банки и олигархи'},
          subtitles:{'fr':'Système financier et grandes fortunes','ru':'Финансовая система и крупные состояния'}, estimatedMinutes:12),
        LessonInfo(moduleId:5, lessonId:4, iconEmoji:'🌾',
          titles:{'fr':'L\'Agriculture — le grenier du monde','ru':'Сельское хозяйство — мировая житница'},
          subtitles:{'fr':'Blé, tournesol et souveraineté alimentaire','ru':'Пшеница, подсолнух и продовольственная безопасность'}, estimatedMinutes:10),
        LessonInfo(moduleId:5, lessonId:5, iconEmoji:'💻',
          titles:{'fr':'Le Numérique et la Tech russe','ru':'Цифровые технологии и российский ИТ'},
          subtitles:{'fr':'Yandex, VKontakte et l\'écosystème russe','ru':'Яндекс, ВКонтакте и российская экосистема'}, estimatedMinutes:10),
      ],
    ),
    ModuleInfo(
      id: 6, iconEmoji: '🏠',
      titles: {'fr': 'La Vie Quotidienne', 'ru': 'Повседневная жизнь'},
      subtitles: {'fr': 'Logement, Transport, Travail', 'ru': 'Жильё, транспорт, работа'},
      descriptions: {
        'fr': 'Comment vivent réellement les Russes — appartements, métro, salaires, famille.',
        'ru': 'Как реально живут русские — квартиры, метро, зарплаты, семья.'
      },
      lessons: [
        LessonInfo(moduleId:6, lessonId:1, iconEmoji:'🏢',
          titles:{'fr':'Le Logement russe','ru':'Жильё в России'},
          subtitles:{'fr':'Appartements soviétiques et vie en communauté','ru':'Советские квартиры и коллективный быт'}, estimatedMinutes:10),
        LessonInfo(moduleId:6, lessonId:2, iconEmoji:'🚇',
          titles:{'fr':'Le Métro de Moscou — un palais souterrain','ru':'Московское метро — подземный дворец'},
          subtitles:{'fr':'Transport, architecture et vie urbaine','ru':'Транспорт, архитектура и городская жизнь'}, estimatedMinutes:10),
        LessonInfo(moduleId:6, lessonId:3, iconEmoji:'💼',
          titles:{'fr':'Travailler en Russie','ru':'Работа в России'},
          subtitles:{'fr':'Salaires, hiérarchie, mentalité professionnelle','ru':'Зарплаты, иерархия, профессиональный менталитет'}, estimatedMinutes:10),
        LessonInfo(moduleId:6, lessonId:4, iconEmoji:'🎒',
          titles:{'fr':'École, Université et Éducation','ru':'Школа, университет и образование'},
          subtitles:{'fr':'Le système éducatif russe','ru':'Российская система образования'}, estimatedMinutes:10),
        LessonInfo(moduleId:6, lessonId:5, iconEmoji:'👨‍👩‍👧',
          titles:{'fr':'La Famille et les Femmes en Russie','ru':'Семья и женщины в России'},
          subtitles:{'fr':'Rôles, démographie, évolutions','ru':'Роли, демография, изменения'}, estimatedMinutes:10),
      ],
    ),
    ModuleInfo(
      id: 7, iconEmoji: '🍲',
      titles: {'fr': 'La Gastronomie Russe', 'ru': 'Русская гастрономия'},
      subtitles: {'fr': 'Cuisine, Vodka & Table russe', 'ru': 'Кухня, водка и русский стол'},
      descriptions: {
        'fr': 'Bortsch, caviar, vodka — bien plus qu\'un cliché : un art de vivre.',
        'ru': 'Борщ, икра, водка — гораздо больше, чем клише: настоящее искусство жизни.'
      },
      lessons: [
        LessonInfo(moduleId:7, lessonId:1, iconEmoji:'🥣',
          titles:{'fr':'Les Soupes Russes — l\'âme du repas','ru':'Русские супы — душа трапезы'},
          subtitles:{'fr':'Bortsch, solianka, ouchá','ru':'Борщ, солянка, уха'}, estimatedMinutes:10),
        LessonInfo(moduleId:7, lessonId:2, iconEmoji:'🥚',
          titles:{'fr':'Zakouski — l\'art des hors-d\'œuvre','ru':'Закуски — искусство холодных блюд'},
          subtitles:{'fr':'Caviar, hareng, salade Olivier','ru':'Икра, сельдь, салат оливье'}, estimatedMinutes:10),
        LessonInfo(moduleId:7, lessonId:3, iconEmoji:'🥟',
          titles:{'fr':'Plats principaux et pelmeni','ru':'Основные блюда и пельмени'},
          subtitles:{'fr':'Bœuf Stroganov, kotlety, pelmeni','ru':'Бефстроганов, котлеты, пельмени'}, estimatedMinutes:10),
        LessonInfo(moduleId:7, lessonId:4, iconEmoji:'🍺',
          titles:{'fr':'La Vodka et les Boissons russes','ru':'Водка и русские напитки'},
          subtitles:{'fr':'Histoire, rituels, kvas et thé','ru':'История, ритуалы, квас и чай'}, estimatedMinutes:12),
        LessonInfo(moduleId:7, lessonId:5, iconEmoji:'🍽️',
          titles:{'fr':'La Table russe — codes et rituels','ru':'Русский стол — коды и ритуалы'},
          subtitles:{'fr':'Invitations, toasts, gestes à éviter','ru':'Приглашения, тосты, запрещённые жесты'}, estimatedMinutes:12),
      ],
    ),
    ModuleInfo(
      id: 8, iconEmoji: '📚',
      titles: {'fr': 'Arts & Littérature', 'ru': 'Искусство и литература'},
      subtitles: {'fr': 'Tolstoï, Dostoïevski & Ballets', 'ru': 'Толстой, Достоевский и балет'},
      descriptions: {
        'fr': 'La Russie, géant culturel — ses écrivains, peintres et danseurs ont changé le monde.',
        'ru': 'Россия — культурный гигант: её писатели, художники и танцоры изменили мир.'
      },
      lessons: [
        LessonInfo(moduleId:8, lessonId:1, iconEmoji:'📖',
          titles:{'fr':'Tolstoï et Dostoïevski — les géants du roman','ru':'Толстой и Достоевский — гиганты романа'},
          subtitles:{'fr':'Guerre et Paix, Crime et Châtiment','ru':'Война и мир, Преступление и наказание'}, estimatedMinutes:14),
        LessonInfo(moduleId:8, lessonId:2, iconEmoji:'🎭',
          titles:{'fr':'Tchekhov, Pouchkine et la Poésie','ru':'Чехов, Пушкин и поэзия'},
          subtitles:{'fr':'Théâtre, vers et âme russe','ru':'Театр, стихи и русская душа'}, estimatedMinutes:12),
        LessonInfo(moduleId:8, lessonId:3, iconEmoji:'🩰',
          titles:{'fr':'Le Ballet Russe — l\'art de la perfection','ru':'Русский балет — искусство совершенства'},
          subtitles:{'fr':'Bolchoï, Kirov, Lac des Cygnes','ru':'Большой, Кировский, Лебединое озеро'}, estimatedMinutes:12),
        LessonInfo(moduleId:8, lessonId:4, iconEmoji:'🎨',
          titles:{'fr':'Peinture et Avant-garde russe','ru':'Живопись и русский авангард'},
          subtitles:{'fr':'Kandinsky, Malevitch, icônes','ru':'Кандинский, Малевич, иконы'}, estimatedMinutes:12),
        LessonInfo(moduleId:8, lessonId:5, iconEmoji:'🏛️',
          titles:{'fr':'Architecture — du Kremlin au Constructivisme','ru':'Архитектура — от Кремля до конструктивизма'},
          subtitles:{'fr':'Styles, époques, symboles','ru':'Стили, эпохи, символы'}, estimatedMinutes:10),
      ],
    ),
    ModuleInfo(
      id: 9, iconEmoji: '🎵',
      titles: {'fr': 'Musique & Cinéma', 'ru': 'Музыка и кино'},
      subtitles: {'fr': 'Tchaïkovski, Eisenstein & Pop russe', 'ru': 'Чайковский, Эйзенштейн и русский поп'},
      descriptions: {
        'fr': 'De Tchaïkovski au rap russe — une scène musicale et cinématographique étonnante.',
        'ru': 'От Чайковского до русского рэпа — удивительная музыкальная и кинематографическая сцена.'
      },
      lessons: [
        LessonInfo(moduleId:9, lessonId:1, iconEmoji:'🎻',
          titles:{'fr':'Tchaïkovski et la Musique classique','ru':'Чайковский и классическая музыка'},
          subtitles:{'fr':'Lac des Cygnes, Casse-Noisette, Symphonies','ru':'Лебединое озеро, Щелкунчик, симфонии'}, estimatedMinutes:12),
        LessonInfo(moduleId:9, lessonId:2, iconEmoji:'🎸',
          titles:{'fr':'Rock soviétique et Post-soviétique','ru':'Советский и постсоветский рок'},
          subtitles:{'fr':'Kino, DDT, Zemfira','ru':'Кино, ДДТ, Земфира'}, estimatedMinutes:10),
        LessonInfo(moduleId:9, lessonId:3, iconEmoji:'🎤',
          titles:{'fr':'Pop, Rap et Musique contemporaine','ru':'Поп, рэп и современная музыка'},
          subtitles:{'fr':'Scène musicale d\'aujourd\'hui','ru':'Современная музыкальная сцена'}, estimatedMinutes:10),
        LessonInfo(moduleId:9, lessonId:4, iconEmoji:'🎬',
          titles:{'fr':'Eisenstein et le Cinéma soviétique','ru':'Эйзенштейн и советское кино'},
          subtitles:{'fr':'Potemkine, Tarkovski, Kubrick du Kremlin','ru':'Потёмкин, Тарковский, Кубрик Кремля'}, estimatedMinutes:12),
        LessonInfo(moduleId:9, lessonId:5, iconEmoji:'📺',
          titles:{'fr':'Cinéma russe contemporain','ru':'Современное российское кино'},
          subtitles:{'fr':'Léviathan, Leto, films à voir','ru':'Левиафан, Лето, фильмы для просмотра'}, estimatedMinutes:10),
      ],
    ),
    ModuleInfo(
      id: 10, iconEmoji: '🤝',
      titles: {'fr': 'Codes Sociaux & Savoir-Vivre', 'ru': 'Социальные коды и этикет'},
      subtitles: {'fr': 'Comment se comporter avec des Russes', 'ru': 'Как вести себя с русскими'},
      descriptions: {
        'fr': 'Les 10 erreurs à ne pas faire — et les clés pour créer de vrais liens.',
        'ru': '10 ошибок, которые нужно избежать — и ключи к настоящим связям.'
      },
      lessons: [
        LessonInfo(moduleId:10, lessonId:1, iconEmoji:'🎁',
          titles:{'fr':'Invitations et Cadeaux','ru':'Приглашения и подарки'},
          subtitles:{'fr':'Chez des Russes : les codes à connaître','ru':'В гостях у русских: коды, которые надо знать'}, estimatedMinutes:10),
        LessonInfo(moduleId:10, lessonId:2, iconEmoji:'🥂',
          titles:{'fr':'Toasts et Rituels de Table','ru':'Тосты и застольные ритуалы'},
          subtitles:{'fr':'L\'art du toast à la russe','ru':'Искусство русского тоста'}, estimatedMinutes:10),
        LessonInfo(moduleId:10, lessonId:3, iconEmoji:'💬',
          titles:{'fr':'Communication et Sujets à éviter','ru':'Общение и темы, которых следует избегать'},
          subtitles:{'fr':'Tabous, politique, fierté nationale','ru':'Табу, политика, национальная гордость'}, estimatedMinutes:12),
        LessonInfo(moduleId:10, lessonId:4, iconEmoji:'🏪',
          titles:{'fr':'Commerces, Marchés et Lieux publics','ru':'Магазины, рынки и общественные места'},
          subtitles:{'fr':'Comment se comporter dans la vie quotidienne','ru':'Как вести себя в повседневной жизни'}, estimatedMinutes:10),
        LessonInfo(moduleId:10, lessonId:5, iconEmoji:'🌉',
          titles:{'fr':'Construire des Liens franco-russes','ru':'Строить французско-российские связи'},
          subtitles:{'fr':'Relations culturelles et amicales durables','ru':'Долгосрочные культурные и дружеские связи'}, estimatedMinutes:12),
      ],
    ),
  ];

  Future<void> init() async {
    _isLoaded = true;
  }

  Future<Map<String, dynamic>?> loadLesson(int moduleId, int lessonId) async {
    final key = 'm${moduleId}_l$lessonId';
    if (_lessonCache.containsKey(key)) return _lessonCache[key];

    try {
      final path = 'assets/lessons/module_$moduleId/lesson_$lessonId.json';
      final raw = await rootBundle.loadString(path);
      final data = json.decode(raw) as Map<String, dynamic>;
      _lessonCache[key] = data;
      return data;
    } catch (e) {
      debugPrint('Error loading lesson m$moduleId/l$lessonId: $e');
      return null;
    }
  }

  ModuleInfo? getModule(int id) {
    try {
      return modules.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  LessonInfo? getLessonInfo(int moduleId, int lessonId) {
    final mod = getModule(moduleId);
    if (mod == null) return null;
    try {
      return mod.lessons.firstWhere((l) => l.lessonId == lessonId);
    } catch (_) {
      return null;
    }
  }
}

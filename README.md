# 🇷🇺 RussiePourTous — Россия для всех

Application Flutter bilingue FR/RU pour les francophones souhaitant découvrir et comprendre la Russie.

## 🎯 Concept

**RussiePourTous** est le pendant de *FrancePourTous* — mais dans l'autre sens :
conçu pour un **Français curieux de la Russie**, qui veut comprendre sa culture, son histoire, son âme.

Interface principale en **français**, avec toggle vers le **russe** pour les apprenants avancés.

## 📚 10 Modules × 5 Leçons

| # | Module | Thèmes |
|---|--------|--------|
| 1 | 🏰 Les Racines de la Russie | Histoire, origines, révolution, URSS |
| 2 | 🗺️ L'Immensité Russe | Moscou, Saint-Pétersbourg, Sibérie, Extrême-Orient |
| 3 | 🏛️ L'État Russe | Constitution, Poutine, fédéralisme, médias |
| 4 | 🌙 L'Âme Russe | Doushá, collectivisme, orthodoxie, dacha |
| 5 | 🛢️ L'Économie Russe | Pétrole, oligarques, agriculture, tech |
| 6 | 🏠 La Vie Quotidienne | Logement, métro de Moscou, travail, éducation |
| 7 | 🍲 La Gastronomie Russe | Bortsch, zakouski, vodka, codes de table |
| 8 | 📚 Arts & Littérature | Tolstoï, Dostoïevski, ballet, peinture |
| 9 | 🎵 Musique & Cinéma | Tchaïkovski, Eisenstein, Tarkovski, rock soviétique |
| 10 | 🤝 Codes Sociaux | Invitations, toasts, communication, liens FR-RU |

## 🏗️ Architecture

```
russie_pour_tous/
├── assets/
│   ├── lang/fr.json          # UI français
│   ├── lang/ru.json          # UI russe
│   └── lessons/module_N/lesson_N.json  # 50 leçons bilingues
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── theme/app_theme.dart   # Couleurs drapeau russe (blanc, bleu, rouge)
│   ├── services/
│   │   ├── content_service.dart
│   │   ├── language_service.dart
│   │   └── progress_service.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── module_screen.dart
│   │   ├── lesson_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── glossary_screen.dart
│   │   └── urgences_screen.dart  # Ressources Russie + conseils voyageur
│   └── widgets/language_toggle.dart
└── android/                   # Package: com.russieapp
```

## 🛠️ Build

```bash
flutter pub get
flutter analyze
flutter build apk --release
```

## 🔄 Différences par rapport à FrancePourTous

| Aspect | FrancePourTous | RussiePourTous |
|--------|----------------|----------------|
| Audience | Russophones en France | Francophones curieux de Russie |
| Langue principale | Russe (UI) / Français (contenu) | Français (UI & contenu) |
| Couleurs | Bleu tricolore | Bleu/Rouge russe (#003DA5 / #CC0000) |
| Urgences | Services français (SAMU, CAF...) | Ambassade FR, numéros russes, conseils visa |
| Section spéciale | Conseil d'Ami (intégration en France) | Conseil du Voyageur (préparer son voyage) |


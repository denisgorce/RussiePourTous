import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'services/progress_service.dart';
import 'services/content_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize services
  final languageService = LanguageService();
  final progressService = ProgressService();
  final contentService = ContentService();

  await languageService.init();
  await progressService.init();
  await contentService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => languageService),
        ChangeNotifierProvider(create: (_) => progressService),
        Provider(create: (_) => contentService),
      ],
      child: const RussiePourTousApp(),
    ),
  );
}

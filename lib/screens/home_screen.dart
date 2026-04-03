import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import 'module_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final progress = context.watch<ProgressService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Flag gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.bleuRussie,
            actions: [const LanguageToggle(), const SizedBox(width: 12)],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppTheme.bleuRussie, Color(0xFF8B0000)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          lang.t('home_greeting'),
                          style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress.overallProgress,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.or,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${(progress.overallProgress * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white, fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Module grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final module = ContentService.modules[index];
                  final prog = progress.getModuleProgress(module.id);
                  final avgScore = progress.getModuleAverageScore(module.id);
                  final gradientColors = AppTheme.moduleGradients[index];

                  return _ModuleCard(
                    module: module,
                    langCode: lang.langCode,
                    progress: prog,
                    averageScore: avgScore,
                    gradientColors: gradientColors,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ModuleScreen(moduleId: module.id),
                      ),
                    ),
                  );
                },
                childCount: ContentService.modules.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ModuleInfo module;
  final String langCode;
  final double progress;
  final double averageScore;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.module,
    required this.langCode,
    required this.progress,
    required this.averageScore,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress >= 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.35),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(module.iconEmoji, style: const TextStyle(fontSize: 28)),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('✓', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'M${module.id}',
                        style: const TextStyle(
                          fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),

              const Spacer(),

              Text(
                module.titles[langCode] ?? '',
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: Colors.white, height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                module.subtitles[langCode] ?? '',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),

              const SizedBox(height: 10),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0 ? AppTheme.or : Colors.white.withOpacity(0.4),
                  ),
                  minHeight: 4,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 5).round()}/5',
                    style: TextStyle(
                      fontSize: 10, color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (averageScore > 0)
                    Text(
                      '⭐ ${averageScore.round()}%',
                      style: const TextStyle(
                        fontSize: 10, color: AppTheme.or,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

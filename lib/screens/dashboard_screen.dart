import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final progress = context.watch<ProgressService>();

    final completedLessons = progress.totalLessonsCompleted;
    final avgScore = progress.averageScore;
    final streak = progress.currentStreak;
    final totalMinutes = completedLessons * 11; // avg 11 min/lesson

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('dashboard_title')),
        actions: [const LanguageToggle(), const SizedBox(width: 12)],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Global stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  icon: '📚',
                  value: '$completedLessons/50',
                  label: lang.t('dashboard_total_lessons'),
                  color: AppTheme.bleuRussie,
                ),
                _StatCard(
                  icon: '⭐',
                  value: avgScore > 0 ? '${avgScore.round()}%' : '--',
                  label: lang.t('dashboard_total_score'),
                  color: const Color(0xFFF59E0B),
                ),
                _StatCard(
                  icon: '🔥',
                  value: '$streak',
                  label: lang.t('dashboard_streak'),
                  color: AppTheme.rougeRussie,
                ),
                _StatCard(
                  icon: '⏱️',
                  value: '${totalMinutes}m',
                  label: lang.t('dashboard_time'),
                  color: const Color(0xFF059669),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Overall progress bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.bleuRussie, Color(0xFF1A4BC4)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'Progression globale',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.overallProgress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.or),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedLessons / 50 leçons — ${(progress.overallProgress * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13, fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Per-module breakdown
            Text(
              lang.isFrench ? 'Détail par module' : 'По модулям',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            ...ContentService.modules.map((module) {
              final modProg = progress.getModuleProgress(module.id);
              final modScore = progress.getModuleAverageScore(module.id);
              final gradColors = AppTheme.moduleGradients[module.id - 1];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradColors),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              module.iconEmoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                module.titles[lang.langCode] ?? '',
                                style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${(modProg * 5).round()}/5 leçons',
                                style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (modScore > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _scoreColor(modScore).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${modScore.round()}%',
                              style: TextStyle(
                                color: _scoreColor(modScore),
                                fontSize: 12, fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: modProg,
                        backgroundColor: AppTheme.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          modProg > 0 ? gradColors.first : AppTheme.borderColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return const Color(0xFFF59E0B);
    return AppTheme.rougeRussie;
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

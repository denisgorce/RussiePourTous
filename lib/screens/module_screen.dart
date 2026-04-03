import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import 'lesson_screen.dart';

class ModuleScreen extends StatelessWidget {
  final int moduleId;
  const ModuleScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final progress = context.watch<ProgressService>();
    final module = ContentService.modules.firstWhere((m) => m.id == moduleId);
    final gradColors = AppTheme.moduleGradients[moduleId - 1];
    final lc = lang.langCode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradColors,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(module.iconEmoji, style: const TextStyle(fontSize: 42)),
                        const SizedBox(height: 8),
                        Text(
                          module.titles[lc] ?? '',
                          style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          module.subtitles[lc] ?? '',
                          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 12),
                        // Module progress bar
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress.getModuleProgress(moduleId),
                                  backgroundColor: Colors.white.withOpacity(0.25),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.or),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${(progress.getModuleProgress(moduleId) * 5).round()}/5',
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [const LanguageToggle(), const SizedBox(width: 12)],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Module description
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    module.descriptions[lc] ?? '',
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  lc == 'fr' ? 'Leçons' : 'Уроки',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),

                // Lessons list
                ...module.lessons.map((lesson) {
                  final isDone = progress.isLessonCompleted(moduleId, lesson.lessonId);
                  final quizDone = progress.isQuizCompleted(moduleId, lesson.lessonId);
                  final score = progress.getLessonScore(moduleId, lesson.lessonId);

                  // Lesson 1 always unlocked; others unlock when previous is done
                  final isLocked = lesson.lessonId > 1 &&
                      !progress.isLessonCompleted(moduleId, lesson.lessonId - 1);

                  return GestureDetector(
                    onTap: isLocked
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LessonScreen(
                                  moduleId: moduleId,
                                  lessonId: lesson.lessonId,
                                ),
                              ),
                            ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? AppTheme.bgColor
                            : isDone
                                ? Colors.white
                                : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDone
                              ? AppTheme.successColor.withOpacity(0.5)
                              : isLocked
                                  ? AppTheme.borderColor
                                  : gradColors.first.withOpacity(0.3),
                          width: isDone ? 1.5 : 1,
                        ),
                        boxShadow: isDone
                            ? [
                                BoxShadow(
                                  color: AppTheme.successColor.withOpacity(0.08),
                                  blurRadius: 8, offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Icon circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppTheme.successColor
                                  : isLocked
                                      ? AppTheme.borderColor
                                      : gradColors.first.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                isDone
                                    ? '✓'
                                    : isLocked
                                        ? '🔒'
                                        : lesson.iconEmoji,
                                style: TextStyle(
                                  fontSize: isDone ? 18 : 20,
                                  color: isDone ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Title + meta
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.titles[lc] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isLocked
                                        ? AppTheme.textSecondary
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '⏱ ${lesson.estimatedMinutes} ${lang.t('minutes')}  ·  📝 5 questions',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                if (!isLocked && !isDone)
                                  Text(
                                    lesson.subtitles[lc] ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: gradColors.first.withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Score badge or arrow
                          if (isDone && quizDone && score > 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _scoreColor(score.toDouble())
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$score%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _scoreColor(score.toDouble()),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _starRating(score.toDouble()),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            )
                          else if (isDone)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                lc == 'fr' ? 'Lu ✓' : 'Прочит. ✓',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else if (!isLocked)
                            Icon(
                              Icons.chevron_right,
                              color: gradColors.first.withOpacity(0.5),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return const Color(0xFFF59E0B);
    return AppTheme.rougeRussie;
  }

  String _starRating(double score) {
    if (score >= 80) return '⭐⭐⭐';
    if (score >= 60) return '⭐⭐';
    return '⭐';
  }
}

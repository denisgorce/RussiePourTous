// ─────────────────────────────────────────────────────────────────────
// GLOSSARY SCREEN
// ─────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';


class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final progress = context.watch<ProgressService>();
    final content = context.read<ContentService>();

    final completedLessons = progress.completedLessons;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('glossary_title')),
        actions: [const LanguageToggle(), const SizedBox(width: 12)],
        automaticallyImplyLeading: false,
      ),
      body: completedLessons.isEmpty
          ? _EmptyGlossary(lang: lang)
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: lang.t('glossary_search'),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                // Glossary content
                Expanded(
                  child: FutureBuilder<List<_GlossaryEntry>>(
                    future: _buildGlossary(content, lang, completedLessons),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var entries = snapshot.data!;
                      if (_searchQuery.isNotEmpty) {
                        entries = entries.where((e) =>
                          e.term.toLowerCase().contains(_searchQuery) ||
                          e.definition.toLowerCase().contains(_searchQuery)
                        ).toList();
                      }

                      if (entries.isEmpty) {
                        return const Center(
                          child: Text('Aucun résultat', style: TextStyle(color: AppTheme.textSecondary)),
                        );
                      }

                      // Group by module
                      final grouped = <int, List<_GlossaryEntry>>{};
                      for (final e in entries) {
                        grouped.putIfAbsent(e.moduleId, () => []).add(e);
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: grouped.keys.length,
                        itemBuilder: (context, i) {
                          final modId = grouped.keys.elementAt(i);
                          final modEntries = grouped[modId]!;
                          final moduleInfo = ContentService.modules.firstWhere((m) => m.id == modId);
                          final gradColors = AppTheme.moduleGradients[modId - 1];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              // Module header
                              Row(
                                children: [
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: gradColors),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(child: Text(moduleInfo.iconEmoji, style: const TextStyle(fontSize: 16))),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    moduleInfo.titles[lang.langCode] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Entries
                              ...modEntries.map((entry) => Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        entry.term,
                                        style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w700,
                                          color: AppTheme.bleuRussie,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        entry.definition,
                                        style: const TextStyle(
                                          fontSize: 13, color: AppTheme.textSecondary, height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<List<_GlossaryEntry>> _buildGlossary(
    ContentService content,
    LanguageService lang,
    List<LessonProgress> completedLessons,
  ) async {
    final entries = <_GlossaryEntry>[];
    for (final lp in completedLessons) {
      final lessonData = await content.loadLesson(lp.moduleId, lp.lessonId);
      if (lessonData == null) continue;
      final glossaryRaw = lessonData[lang.langCode]?['glossary'] as List<dynamic>?;
      if (glossaryRaw == null) continue;
      for (final item in glossaryRaw.cast<Map<String, dynamic>>()) {
        entries.add(_GlossaryEntry(
          moduleId: lp.moduleId,
          term: item['term'] ?? '',
          definition: item['definition'] ?? '',
        ));
      }
    }
    return entries;
  }
}

class _GlossaryEntry {
  final int moduleId;
  final String term;
  final String definition;
  const _GlossaryEntry({required this.moduleId, required this.term, required this.definition});
}

class _EmptyGlossary extends StatelessWidget {
  final LanguageService lang;
  const _EmptyGlossary({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📖', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              lang.t('glossary_empty'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
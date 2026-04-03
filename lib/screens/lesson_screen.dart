import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final int moduleId;
  final int lessonId;

  const LessonScreen({
    super.key,
    required this.moduleId,
    required this.lessonId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  Map<String, dynamic>? _lessonData;
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();
  double _readProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadLesson();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    final current = _scrollController.offset;
    setState(() => _readProgress = (current / max).clamp(0.0, 1.0));
  }

  Future<void> _loadLesson() async {
    final content = context.read<ContentService>();
    final data = await content.loadLesson(widget.moduleId, widget.lessonId);
    if (mounted) {
      setState(() {
        _lessonData = data;
        _loading = false;
      });
    }
    // Mark lesson as started
    await context.read<ProgressService>().markLessonCompleted(
      widget.moduleId, widget.lessonId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final lc = lang.langCode;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('...'),
          actions: [const LanguageToggle(), const SizedBox(width: 12)],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_lessonData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Leçon introuvable.')),
      );
    }

    final d = _lessonData![lc] as Map<String, dynamic>;
    final sections = (d['sections'] as List<dynamic>).cast<Map<String, dynamic>>();
    final conseilAmi = d['conseil_ami'] as Map<String, dynamic>;
    final glossary = (d['glossary'] as List<dynamic>).cast<Map<String, dynamic>>();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App bar with read progress
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.bleuRussie,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  d['lesson_title'] ?? '',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                actions: [const LanguageToggle(), const SizedBox(width: 12)],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: LinearProgressIndicator(
                    value: _readProgress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.or),
                    minHeight: 4,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero intro card
                    _HeroCard(
                      moduleId: widget.moduleId,
                      lessonData: _lessonData!,
                      langCode: lc,
                    ),

                    const SizedBox(height: 16),

                    // 6 theme sections
                    ...sections.asMap().entries.map((entry) {
                      return _SectionCard(section: entry.value, index: entry.key);
                    }),

                    const SizedBox(height: 8),

                    // Conseil d'Ami box
                    _ConseilAmiCard(conseilAmi: conseilAmi),

                    const SizedBox(height: 16),

                    // Glossary
                    if (glossary.isNotEmpty) _GlossaryCard(glossary: glossary),

                    const SizedBox(height: 24),

                    // CTA: Start quiz
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            moduleId: widget.moduleId,
                            lessonId: widget.lessonId,
                            lessonData: _lessonData!,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      child: Text(lang.t('lesson_quiz') + ' 📝'),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int moduleId;
  final Map<String, dynamic> lessonData;
  final String langCode;

  const _HeroCard({
    required this.moduleId,
    required this.lessonData,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    final d = lessonData[langCode] as Map<String, dynamic>;
    final gradColors = AppTheme.moduleGradients[moduleId - 1];
    final meta = lessonData['meta'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradColors,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradColors.first.withOpacity(0.3),
            blurRadius: 16, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meta['lesson_icon']?.toString() ?? '📖',
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 8),
          Text(
            d['lesson_title'] ?? '',
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
            ),
          ),
          Text(
            d['lesson_subtitle'] ?? '',
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          Text(
            d['intro'] ?? '',
            style: TextStyle(
              fontSize: 14, color: Colors.white.withOpacity(0.9), height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: [
              _HeroChip('⏱ ${meta['estimated_minutes']} min'),
              _HeroChip('📝 5 questions'),
              _HeroChip('🎓 ${meta['difficulty'] ?? ''}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  const _HeroChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}

class _SectionCard extends StatefulWidget {
  final Map<String, dynamic> section;
  final int index;

  const _SectionCard({required this.section, required this.index});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // First section is always expanded
    _expanded = widget.index == 0;
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    final body = section['body'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (always visible)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.bleuRussie.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text(section['icon'] ?? '📌', style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.bleuRussie.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            section['theme'] ?? '',
                            style: const TextStyle(
                              fontSize: 10, color: AppTheme.bleuRussie,
                              fontWeight: FontWeight.w700, letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          section['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expandable body
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: _RichText(text: body),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

/// Renders text with **bold** markdown support
class _RichText extends StatelessWidget {
  final String text;
  const _RichText({required this.text});

  @override
  Widget build(BuildContext context) {
    return _buildRichText(context, text);
  }

  Widget _buildRichText(BuildContext context, String rawText) {
    final paragraphs = rawText.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((para) {
        final trimmed = para.trim();
        if (trimmed.isEmpty) return const SizedBox(height: 8);

        final spans = _parseInline(trimmed);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14.5, color: AppTheme.textPrimary, height: 1.7,
              ),
              children: spans,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<InlineSpan> _parseInline(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.bleuRussie),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }
}

class _ConseilAmiCard extends StatelessWidget {
  final Map<String, dynamic> conseilAmi;
  const _ConseilAmiCard({required this.conseilAmi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.12),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(conseilAmi['icon'] ?? '💡', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                conseilAmi['title'] ?? '',
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RichText(text: conseilAmi['content'] ?? ''),
        ],
      ),
    );
  }
}

class _GlossaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> glossary;
  const _GlossaryCard({required this.glossary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📖', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Vocabulaire clé',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...glossary.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    item['term'] ?? '',
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
                    item['definition'] ?? '',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

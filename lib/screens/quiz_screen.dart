import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';

class QuizScreen extends StatefulWidget {
  final int moduleId;
  final int lessonId;
  final Map<String, dynamic> lessonData;

  const QuizScreen({
    super.key,
    required this.moduleId,
    required this.lessonId,
    required this.lessonData,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  bool _quizFinished = false;
  late List<Map<String, dynamic>> _questions;

  late AnimationController _shakeController;
  late AnimationController _bounceController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    );
    _bounceController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    _loadQuestions();
  }

  void _loadQuestions() {
    final lang = context.read<LanguageService>();
    final lc = lang.langCode;
    final rawList = widget.lessonData[lc]?['quiz'] as List<dynamic>? ?? [];
    _questions = rawList.cast<Map<String, dynamic>>();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      final correct = _questions[_currentQuestion]['correct_index'] as int;
      if (index == correct) {
        _correctCount++;
        _bounceController.forward(from: 0);
      } else {
        _shakeController.forward(from: 0);
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    await context.read<ProgressService>().saveQuizResult(
      moduleId: widget.moduleId,
      lessonId: widget.lessonId,
      correctAnswers: _correctCount,
      totalQuestions: _questions.length,
    );
    setState(() => _quizFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(lang.t('quiz_title'))),
        body: const Center(child: Text('Quiz non disponible.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('quiz_title')),
        actions: [const LanguageToggle(), const SizedBox(width: 12)],
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _quizFinished
          ? _ResultScreen(
              correct: _correctCount,
              total: _questions.length,
              lang: lang,
              onRetry: () => setState(() {
                _currentQuestion = 0;
                _selectedAnswer = null;
                _answered = false;
                _correctCount = 0;
                _quizFinished = false;
              }),
              onFinish: () => Navigator.pop(context),
              questions: _questions,
            )
          : _QuestionView(
              question: _questions[_currentQuestion],
              questionIndex: _currentQuestion,
              total: _questions.length,
              selectedAnswer: _selectedAnswer,
              answered: _answered,
              lang: lang,
              shakeAnimation: _shakeAnimation,
              onSelect: _selectAnswer,
              onNext: _nextQuestion,
            ),
    );
  }
}

// ─── QUESTION VIEW ──────────────────────────────────────────────────

class _QuestionView extends StatelessWidget {
  final Map<String, dynamic> question;
  final int questionIndex;
  final int total;
  final int? selectedAnswer;
  final bool answered;
  final LanguageService lang;
  final Animation<double> shakeAnimation;
  final Function(int) onSelect;
  final VoidCallback onNext;

  const _QuestionView({
    required this.question,
    required this.questionIndex,
    required this.total,
    required this.selectedAnswer,
    required this.answered,
    required this.lang,
    required this.shakeAnimation,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final options = (question['options'] as List<dynamic>).cast<String>();
    final correctIndex = question['correct_index'] as int;
    final explanation = question['explanation'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicators
          Row(
            children: List.generate(total, (i) {
              Color dotColor;
              if (i < questionIndex) {
                dotColor = AppTheme.successColor;
              } else if (i == questionIndex) {
                dotColor = AppTheme.bleuRussie;
              } else {
                dotColor = AppTheme.borderColor;
              }

              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: dotColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          Text(
            '${lang.t('quiz_question')} ${questionIndex + 1} ${lang.t('quiz_of')} $total',
            style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              question['question'] as String? ?? '',
              style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700,
                height: 1.5, color: AppTheme.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Options
          ...options.asMap().entries.map((entry) {
            final i = entry.key;
            final option = entry.value;
            return _OptionButton(
              text: option,
              index: i,
              correctIndex: correctIndex,
              selectedAnswer: selectedAnswer,
              answered: answered,
              shakeAnimation: shakeAnimation,
              onTap: () => onSelect(i),
            );
          }),

          // Explanation
          if (answered) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selectedAnswer == correctIndex
                    ? AppTheme.successColor.withOpacity(0.08)
                    : AppTheme.rougeRussie.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedAnswer == correctIndex
                      ? AppTheme.successColor.withOpacity(0.3)
                      : AppTheme.rougeRussie.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAnswer == correctIndex
                        ? '✅ ${lang.t('correct')}'
                        : '❌ ${lang.t('incorrect')}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: selectedAnswer == correctIndex
                          ? AppTheme.successColor
                          : AppTheme.rougeRussie,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(explanation, style: const TextStyle(fontSize: 13.5, height: 1.6)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          if (answered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  questionIndex < (5 - 1)
                      ? lang.t('quiz_next')
                      : lang.t('quiz_finish'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final int index;
  final int correctIndex;
  final int? selectedAnswer;
  final bool answered;
  final Animation<double> shakeAnimation;
  final VoidCallback onTap;

  const _OptionButton({
    required this.text,
    required this.index,
    required this.correctIndex,
    required this.selectedAnswer,
    required this.answered,
    required this.shakeAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedAnswer == index;
    final isCorrect = index == correctIndex;

    Color bgColor = Colors.white;
    Color borderColor = AppTheme.borderColor;
    Color textColor = AppTheme.textPrimary;

    if (answered) {
      if (isCorrect) {
        bgColor = AppTheme.successColor.withOpacity(0.1);
        borderColor = AppTheme.successColor;
        textColor = const Color(0xFF166534);
      } else if (isSelected && !isCorrect) {
        bgColor = AppTheme.rougeRussie.withOpacity(0.08);
        borderColor = AppTheme.rougeRussie;
        textColor = AppTheme.rougeRussie;
      }
    } else if (isSelected) {
      bgColor = AppTheme.bleuRussie.withOpacity(0.08);
      borderColor = AppTheme.bleuRussie;
    }

    Widget button = GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: answered && isCorrect
                    ? AppTheme.successColor
                    : answered && isSelected
                        ? AppTheme.rougeRussie
                        : borderColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  answered && isCorrect
                      ? '✓'
                      : answered && isSelected && !isCorrect
                          ? '✗'
                          : String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: answered && (isCorrect || (isSelected && !isCorrect))
                        ? Colors.white
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.5, color: textColor,
                  fontWeight: isCorrect && answered ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Shake wrong answer
    if (answered && isSelected && !isCorrect) {
      return AnimatedBuilder(
        animation: shakeAnimation,
        builder: (context, child) {
          final offset = 8 * shakeAnimation.value * (1 - shakeAnimation.value) * 4;
          return Transform.translate(
            offset: Offset(offset % 2 == 0 ? offset : -offset, 0),
            child: child,
          );
        },
        child: button,
      );
    }

    return button;
  }
}

// ─── RESULT SCREEN ──────────────────────────────────────────────────

class _ResultScreen extends StatelessWidget {
  final int correct;
  final int total;
  final LanguageService lang;
  final VoidCallback onRetry;
  final VoidCallback onFinish;
  final List<Map<String, dynamic>> questions;

  const _ResultScreen({
    required this.correct,
    required this.total,
    required this.lang,
    required this.onRetry,
    required this.onFinish,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final score = ((correct / total) * 100).round();
    final stars = score >= 80 ? 3 : score >= 60 ? 2 : 1;

    String emoji;
    String message;
    if (score >= 80) {
      emoji = '🎉';
      message = lang.isFrench ? 'Excellent travail !' : 'Отличная работа!';
    } else if (score >= 60) {
      emoji = '👍';
      message = lang.isFrench ? 'Bien joué !' : 'Хорошо сделано!';
    } else {
      emoji = '💪';
      message = lang.isFrench ? 'Continuez à apprendre !' : 'Продолжайте учиться!';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                Text(
                  lang.t('quiz_result_title'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),

                // Big score
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 56, fontWeight: FontWeight.w900,
                    color: score >= 80
                        ? AppTheme.successColor
                        : score >= 60
                            ? const Color(0xFFF59E0B)
                            : AppTheme.rougeRussie,
                  ),
                ),

                Text(
                  '$correct / $total ${lang.isFrench ? 'bonnes réponses' : 'правильных ответов'}',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),

                const SizedBox(height: 12),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Text(
                    i < stars ? '⭐' : '☆',
                    style: const TextStyle(fontSize: 28),
                  )),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.bleuRussie, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text(
                    lang.t('quiz_retry'),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.bleuRussie),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onFinish,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(lang.t('quiz_continue')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

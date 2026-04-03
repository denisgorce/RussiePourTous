import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonProgress {
  final int moduleId;
  final int lessonId;
  final bool lessonCompleted;
  final bool quizCompleted;
  final int quizScore;        // 0-100
  final int totalQuestions;
  final int correctAnswers;
  final DateTime? completedAt;

  LessonProgress({
    required this.moduleId,
    required this.lessonId,
    this.lessonCompleted = false,
    this.quizCompleted = false,
    this.quizScore = 0,
    this.totalQuestions = 5,
    this.correctAnswers = 0,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'moduleId': moduleId,
    'lessonId': lessonId,
    'lessonCompleted': lessonCompleted,
    'quizCompleted': quizCompleted,
    'quizScore': quizScore,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
    moduleId: json['moduleId'],
    lessonId: json['lessonId'],
    lessonCompleted: json['lessonCompleted'] ?? false,
    quizCompleted: json['quizCompleted'] ?? false,
    quizScore: json['quizScore'] ?? 0,
    totalQuestions: json['totalQuestions'] ?? 5,
    correctAnswers: json['correctAnswers'] ?? 0,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
  );

  LessonProgress copyWith({
    bool? lessonCompleted,
    bool? quizCompleted,
    int? quizScore,
    int? correctAnswers,
    DateTime? completedAt,
  }) => LessonProgress(
    moduleId: moduleId,
    lessonId: lessonId,
    lessonCompleted: lessonCompleted ?? this.lessonCompleted,
    quizCompleted: quizCompleted ?? this.quizCompleted,
    quizScore: quizScore ?? this.quizScore,
    totalQuestions: totalQuestions,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    completedAt: completedAt ?? this.completedAt,
  );
}

class ProgressService extends ChangeNotifier {
  static const String _prefKey = 'lesson_progress';
  static const String _streakKey = 'learning_streak';
  static const String _lastActiveKey = 'last_active_date';
  static const int totalModules = 10;
  static const int lessonsPerModule = 5;

  final Map<String, LessonProgress> _progress = {};
  int _currentStreak = 0;
  DateTime? _lastActiveDate;

  int get currentStreak => _currentStreak;
  int get totalLessonsCompleted => _progress.values.where((p) => p.lessonCompleted).length;
  int get totalQuizzesCompleted => _progress.values.where((p) => p.quizCompleted).length;

  double get overallProgress {
    const total = totalModules * lessonsPerModule;
    return totalLessonsCompleted / total;
  }

  double get averageScore {
    final completed = _progress.values.where((p) => p.quizCompleted).toList();
    if (completed.isEmpty) return 0;
    final sum = completed.fold<int>(0, (acc, p) => acc + p.quizScore);
    return sum / completed.length;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load lesson progress
    final raw = prefs.getString(_prefKey);
    if (raw != null) {
      final Map<String, dynamic> decoded = json.decode(raw);
      decoded.forEach((key, val) {
        _progress[key] = LessonProgress.fromJson(val as Map<String, dynamic>);
      });
    }

    // Load streak
    _currentStreak = prefs.getInt(_streakKey) ?? 0;
    final lastDateStr = prefs.getString(_lastActiveKey);
    if (lastDateStr != null) {
      _lastActiveDate = DateTime.parse(lastDateStr);
    }

    _updateStreak();
  }

  void _updateStreak() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (_lastActiveDate == null) {
      // First time
      _currentStreak = 1;
      _lastActiveDate = todayDate;
    } else {
      final lastDate = DateTime(
        _lastActiveDate!.year, _lastActiveDate!.month, _lastActiveDate!.day
      );
      final diff = todayDate.difference(lastDate).inDays;

      if (diff == 0) {
        // Same day, streak unchanged
      } else if (diff == 1) {
        // Consecutive day
        _currentStreak++;
        _lastActiveDate = todayDate;
      } else {
        // Streak broken
        _currentStreak = 1;
        _lastActiveDate = todayDate;
      }
    }

    await _saveStreakData();
    notifyListeners();
  }

  Future<void> _saveStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, _currentStreak);
    if (_lastActiveDate != null) {
      await prefs.setString(_lastActiveKey, _lastActiveDate!.toIso8601String());
    }
  }

  String _key(int moduleId, int lessonId) => '${moduleId}_$lessonId';

  LessonProgress? getProgress(int moduleId, int lessonId) {
    return _progress[_key(moduleId, lessonId)];
  }

  bool isLessonCompleted(int moduleId, int lessonId) {
    return _progress[_key(moduleId, lessonId)]?.lessonCompleted ?? false;
  }

  bool isQuizCompleted(int moduleId, int lessonId) {
    return _progress[_key(moduleId, lessonId)]?.quizCompleted ?? false;
  }

  int getLessonScore(int moduleId, int lessonId) {
    return _progress[_key(moduleId, lessonId)]?.quizScore ?? 0;
  }

  double getModuleProgress(int moduleId) {
    int completed = 0;
    for (int i = 1; i <= lessonsPerModule; i++) {
      if (isLessonCompleted(moduleId, i)) completed++;
    }
    return completed / lessonsPerModule;
  }

  double getModuleAverageScore(int moduleId) {
    final scores = <int>[];
    for (int i = 1; i <= lessonsPerModule; i++) {
      final p = getProgress(moduleId, i);
      if (p != null && p.quizCompleted) {
        scores.add(p.quizScore);
      }
    }
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  Future<void> markLessonCompleted(int moduleId, int lessonId) async {
    final key = _key(moduleId, lessonId);
    final existing = _progress[key];
    _progress[key] = (existing ?? LessonProgress(moduleId: moduleId, lessonId: lessonId))
        .copyWith(lessonCompleted: true, completedAt: DateTime.now());
    await _saveProgress();
    _updateStreak();
    notifyListeners();
  }

  Future<void> saveQuizResult({
    required int moduleId,
    required int lessonId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final key = _key(moduleId, lessonId);
    final existing = _progress[key];
    final score = ((correctAnswers / totalQuestions) * 100).round();

    _progress[key] = (existing ?? LessonProgress(moduleId: moduleId, lessonId: lessonId))
        .copyWith(
          lessonCompleted: true,
          quizCompleted: true,
          quizScore: score,
          correctAnswers: correctAnswers,
          completedAt: DateTime.now(),
        );

    await _saveProgress();
    _updateStreak();
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(
      _progress.map((k, v) => MapEntry(k, v.toJson()))
    );
    await prefs.setString(_prefKey, encoded);
  }

  Future<void> resetAll() async {
    _progress.clear();
    _currentStreak = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_lastActiveKey);
    notifyListeners();
  }

  // Glossary: collect all terms from completed lessons
  List<LessonProgress> get completedLessons =>
      _progress.values.where((p) => p.lessonCompleted).toList();
}

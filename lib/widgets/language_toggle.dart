import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// The signature FR/RU toggle button
class LanguageToggle extends StatefulWidget {
  final bool compact;
  const LanguageToggle({super.key, this.compact = false});

  @override
  State<LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<LanguageToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _switching = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleToggle(LanguageService lang) async {
    if (_switching) return;
    setState(() => _switching = true);

    await _controller.forward();
    await lang.toggle();
    await _controller.reverse();

    if (mounted) setState(() => _switching = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: () => _handleToggle(lang),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppTheme.blanc.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppTheme.blanc.withOpacity(0.4), width: 1.5),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 10 : 14,
            vertical: widget.compact ? 5 : 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flag icon
              Text(
                lang.isFrench ? '🇷🇺' : '🇫🇷',
                style: TextStyle(fontSize: widget.compact ? 14 : 16),
              ),
              const SizedBox(width: 6),
              // Language label
              Text(
                lang.isFrench ? 'РУС' : 'FR',
                style: TextStyle(
                  fontSize: widget.compact ? 11 : 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.blanc,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A large prominent toggle for the splash/home screen
class LanguageToggleLarge extends StatelessWidget {
  const LanguageToggleLarge({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangOption(
            flag: '🇫🇷',
            label: 'Français',
            isActive: lang.isFrench,
            onTap: () {
              if (!lang.isFrench) lang.toggle();
            },
          ),
          _LangOption(
            flag: '🇷🇺',
            label: 'Русский',
            isActive: !lang.isFrench,
            onTap: () {
              if (lang.isFrench) lang.toggle();
            },
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.bleuRussie : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isActive ? AppTheme.blanc : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

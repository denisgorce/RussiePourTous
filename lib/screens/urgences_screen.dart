import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';

class UrgencesScreen extends StatelessWidget {
  const UrgencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final isFr = lang.isFrench;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('urgences_title')),
        actions: [const LanguageToggle(), const SizedBox(width: 12)],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── EMERGENCY NUMBERS (Russia) ─────────────────────────
            _SectionHeader(
              icon: '🚨',
              title: isFr ? 'Numéros d\'urgence en Russie' : 'Номера экстренных служб',
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _EmergencyCard(
                  number: '112',
                  emoji: '🆘',
                  label: isFr ? 'Numéro universel\n(fonctionne partout)' : 'Единый номер\n(работает везде)',
                  color: AppTheme.rougeRussie,
                ),
                _EmergencyCard(
                  number: '02',
                  emoji: '👮',
                  label: isFr ? 'Police\n(Полиция)' : 'Полиция\nPoliciya',
                  color: AppTheme.bleuRussie,
                ),
                _EmergencyCard(
                  number: '03',
                  emoji: '🚑',
                  label: isFr ? 'Ambulance\n(Скорая помощь)' : 'Скорая помощь\nAmbulance',
                  color: const Color(0xFFDC2626),
                ),
                _EmergencyCard(
                  number: '01',
                  emoji: '🚒',
                  label: isFr ? 'Pompiers\n(Пожарные)' : 'Пожарные\nPompiery',
                  color: const Color(0xFFEA580C),
                ),
              ],
            ),

            const SizedBox(height: 10),
            _HorizontalTile(
              number: '8-800-100-52-52',
              emoji: '🧠',
              label: isFr ? 'Ligne psychologique nationale (gratuite)' : 'Психологическая помощь (бесплатно)',
              color: const Color(0xFF7C3AED),
            ),

            const SizedBox(height: 24),

            // ── FRENCH DIPLOMACY ───────────────────────────────────
            _SectionHeader(
              icon: '🇫🇷',
              title: isFr ? 'Ambassade & Consulat de France' : 'Посольство и консульство Франции',
            ),
            const SizedBox(height: 10),

            _LinkCard(
              emoji: '🏛️',
              title: isFr ? 'France Diplomatie — Russie' : 'France Diplomatie — Россия',
              subtitle: isFr
                  ? 'Alertes, conseils aux voyageurs, services consulaires'
                  : 'Предупреждения, советы путешественникам, консульские услуги',
              url: 'france.fr/russie',
              color: AppTheme.bleuRussie,
            ),
            _LinkCard(
              emoji: '📋',
              title: isFr ? 'Visa & Passeport biométrique' : 'Виза и биометрический паспорт',
              subtitle: isFr
                  ? 'Demandes de visa russes — Consulat de Russie en France'
                  : 'Заявки на российские визы — консульство России во Франции',
              url: 'visa.kdmid.ru',
              color: AppTheme.rougeRussie,
            ),
            _LinkCard(
              emoji: '📞',
              title: isFr ? 'Urgences consulaires 24h/24' : 'Консульские экстренные услуги 24/7',
              subtitle: isFr
                  ? '+7 495 937 15 00 — Ambassade de France à Moscou'
                  : '+7 495 937 15 00 — Посольство Франции в Москве',
              url: '+7 495 937 15 00',
              color: const Color(0xFF1565C0),
            ),

            const SizedBox(height: 24),

            // ── TRAVEL RESOURCES ──────────────────────────────────
            _SectionHeader(
              icon: '✈️',
              title: isFr ? 'Préparer son voyage' : 'Подготовка к путешествию',
            ),
            const SizedBox(height: 10),

            _LinkCard(
              emoji: '🌍',
              title: 'Routard.com — Russie',
              subtitle: isFr
                  ? 'Guides pratiques, itinéraires, hôtels, monnaie'
                  : 'Практические гиды, маршруты, отели, валюта',
              url: 'routard.com/russie',
              color: const Color(0xFF059669),
            ),
            _LinkCard(
              emoji: '💊',
              title: isFr ? 'Santé & Assurance voyage' : 'Здоровье и страховка путешественника',
              subtitle: isFr
                  ? 'Vaccins recommandés, eau potable, précautions sanitaires'
                  : 'Рекомендуемые прививки, питьевая вода, санитарные меры',
              url: 'sante.fr/russie',
              color: const Color(0xFF0284C7),
            ),
            _LinkCard(
              emoji: '💱',
              title: isFr ? 'Rouble russe (₽)' : 'Российский рубль (₽)',
              subtitle: isFr
                  ? 'Taux de change — emporter des euros/dollars, les cartes VISA/MC non acceptées'
                  : 'Курс валют — везите евро/доллары, карты VISA/MC не принимаются',
              url: 'xe.com/eur-rub',
              color: const Color(0xFFD97706),
            ),
            _LinkCard(
              emoji: '📡',
              title: isFr ? 'Accès Internet & VPN' : 'Доступ в Интернет и VPN',
              subtitle: isFr
                  ? 'Certains sites occidentaux sont bloqués — préparez un VPN avant de partir'
                  : 'Ряд западных сайтов заблокирован — установите VPN перед поездкой',
              url: 'france-diplomatie.fr/russie/tech',
              color: const Color(0xFF6366F1),
            ),

            const SizedBox(height: 24),

            // ── PRACTICAL TIPS ────────────────────────────────────
            _SectionHeader(
              icon: '💡',
              title: isFr ? 'Les 5 réflexes avant de partir' : '5 шагов перед отъездом',
            ),
            const SizedBox(height: 10),

            ...[
              _Tip(
                step: '1',
                emoji: '📄',
                title: isFr ? 'Vérifier son visa' : 'Проверьте визу',
                body: isFr
                    ? 'Les ressortissants français doivent obtenir un visa russe avant le départ. Déposez votre demande au moins 3 semaines à l\'avance au Consulat de Russie. Le visa électronique (e-visa) est disponible pour certaines entrées.'
                    : 'Французские граждане должны получить российскую визу до отъезда. Подавайте заявку минимум за 3 недели в консульство России. Электронная виза (е-виза) доступна для ряда пунктов въезда.',
              ),
              _Tip(
                step: '2',
                emoji: '💳',
                title: isFr ? 'Emporter du cash' : 'Берите наличные',
                body: isFr
                    ? 'Les cartes Visa et Mastercard françaises ne fonctionnent plus en Russie depuis 2022. Emportez des euros ou des dollars US pour les échanger en roubles sur place. Les DAB en Russie n\'acceptent que les cartes russes (Mir).'
                    : 'Французские карты Visa и Mastercard не работают в России с 2022 года. Везите евро или доллары США для обмена на рубли. Российские банкоматы принимают только карты «Мир».',
              ),
              _Tip(
                step: '3',
                emoji: '📱',
                title: isFr ? 'Installer un VPN' : 'Установите VPN',
                body: isFr
                    ? 'Instagram, Facebook, Twitter/X, WhatsApp sont bloqués ou restreints en Russie. Installez un VPN fiable (Proton VPN, Mullvad) AVANT de partir — il est difficile de les installer depuis la Russie.'
                    : 'Instagram, Facebook, Twitter/X, WhatsApp заблокированы или ограничены в России. Установите надёжный VPN (Proton VPN, Mullvad) ДО отъезда — за рубежом их сложнее установить.',
              ),
              _Tip(
                step: '4',
                emoji: '🏥',
                title: isFr ? 'Souscrire une assurance voyage' : 'Оформите страховку путешественника',
                body: isFr
                    ? 'Une assurance médicale rapatriement est indispensable. Les soins hospitaliers peuvent être très coûteux pour un étranger sans couverture. Vérifiez que votre assurance couvre la Russie.'
                    : 'Медицинская страховка с репатриацией обязательна. Стационарное лечение может быть очень дорогим для иностранца без покрытия. Убедитесь, что страховка действует в России.',
              ),
              _Tip(
                step: '5',
                emoji: '📋',
                title: isFr ? 'Inscription Ariane (MEAE)' : 'Регистрация Ariane (МИД Франции)',
                body: isFr
                    ? 'Inscrivez-vous sur le portail Ariane du Ministère des Affaires Étrangères pour être contacté en cas de crise. Service gratuit, discret, indispensable pour tout Français à l\'étranger.'
                    : 'Зарегистрируйтесь на портале Ariane МИД Франции, чтобы с вами связались в кризисной ситуации. Бесплатный, незаметный и необходимый сервис для каждого француза за рубежом.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── WIDGETS ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
          )),
        ),
      ],
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final String number, emoji, label;
  final Color color;
  const _EmergencyCard({required this.number, required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(number, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w600, height: 1.3)),
          ]),
        ],
      ),
    );
  }
}

class _HorizontalTile extends StatelessWidget {
  final String number, emoji, label;
  final Color color;
  const _HorizontalTile({required this.number, required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Text(number, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color))),
        Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String emoji, title, subtitle, url;
  final Color color;
  const _LinkCard({required this.emoji, required this.title, required this.subtitle, required this.url, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.3)),
          const SizedBox(height: 3),
          Text(url, style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
        ])),
        Icon(Icons.open_in_new, size: 16, color: color.withOpacity(0.6)),
      ]),
    );
  }
}

class _Tip extends StatelessWidget {
  final String step, emoji, title, body;
  const _Tip({required this.step, required this.emoji, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bleuRussie.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: AppTheme.bleuRussie, borderRadius: BorderRadius.circular(50)),
          child: Center(child: Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.bleuRussie))),
          ]),
          const SizedBox(height: 5),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textSecondary)),
        ])),
      ]),
    );
  }
}

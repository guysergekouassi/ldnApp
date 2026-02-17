import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class ConfessionScreen extends StatefulWidget {
  const ConfessionScreen({Key? key}) : super(key: key);

  @override
  _ConfessionScreenState createState() => _ConfessionScreenState();
}

class _ConfessionScreenState extends State<ConfessionScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  int _currentStep = 0;
  final List<ConfessionStep> _completedSteps = [];
  final TextEditingController _reflectionController = TextEditingController();

  final List<ConfessionStep> _examinationSteps = [
    ConfessionStep(
      title: 'Relation avec Dieu',
      icon: Icons.church,
      questions: [
        'Ai-je prié chaque jour ?',
        'Ai-je lu l\'Évangile ?',
        'Ai-je manqué la messe le dimanche sans raison valable ?',
        'Ai-je respecté le nom de Dieu ?',
        'Ai-je pratiqué la superstition ou l\'occultisme ?',
      ],
    ),
    ConfessionStep(
      title: 'Relation avec les autres',
      icon: Icons.people,
      questions: [
        'Ai-je menti ?',
        'Ai-je calomnié ou médisé ?',
        'Ai-je jugé les autres ?',
        'Ai-je refusé de pardonner ?',
        'Ai-ai causé des divisions ?',
      ],
    ),
    ConfessionStep(
      title: 'Respect de la vie',
      icon: Icons.favorite,
      questions: [
        'Ai-je eu des pensées de haine ?',
        'Ai-je été colérique ou violent ?',
        'Ai-ai respecté mon corps ?',
        'Ai-ai respecté la vie des autres ?',
        'Ai-ai été envieux ou jaloux ?',
      ],
    ),
    ConfessionStep(
      title: 'Honnêteté et justice',
      icon: Icons.balance,
      questions: [
        'Ai-je volé quelque chose ?',
        'Ai-ai triché ?',
        'Ai-ai été honnête dans mes études/travail ?',
        'Ai-ai rendu ce qui ne m\'appartient pas ?',
        'Ai-ai été juste avec les autres ?',
      ],
    ),
    ConfessionStep(
      title: 'Pureté et chasteté',
      icon: Icons.water_drop,
      questions: [
        'Ai-ai eu des pensées impures ?',
        'Ai-ai regardé des contenus inappropriés ?',
        'Ai-ai respecté la dignité de mon corps ?',
        'Ai-ai vécu dans la chasteté selon mon état ?',
        'Ai-ai respecté les autres dans leur dignité ?',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Préparation à la Confession',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kAccentColor,
          unselectedLabelColor: kTextSecondaryColor,
          indicatorColor: kAccentColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Examen'),
            Tab(text: 'Prières'),
            Tab(text: 'Guide'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExaminationTab(),
          _buildPrayersTab(),
          _buildGuideTab(),
        ],
      ),
    );
  }

  Widget _buildExaminationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressHeader(),
          const SizedBox(height: 24),
          _buildCurrentStep(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildReflectionSection(),
        ],
      ),
    );
  }

  Widget _buildPrayersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrayerSection(
            'Avant la Confession',
            [
              PrayerItem(
                title: 'Prière à l\'Esprit Saint',
                text: 'Viens, Esprit Saint, éclaire mon cœur. Aide-moi à connaître mes péchés et à m\'en repentir sincèrement.',
              ),
              PrayerItem(
                title: 'Acte de contrition',
                text: 'Mon Dieu, j\'ai un très grand regret de t\'avoir offensé, parce que tu es infiniment bon, infiniment aimable, et que le péché te déplaît. Je prends la ferme résolution, avec le secours de ta sainte grâce, de ne plus t\'offenser et de faire pénitence.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPrayerSection(
            'Après la Confession',
            [
              PrayerItem(
                title: 'Prière d\'action de grâce',
                text: 'Merci, mon Dieu, pour le pardon que tu m\'as accordé. Aide-moi à vivre en fidélité à mes promesses.',
              ),
              PrayerItem(
                title: 'Prière pour la conversion',
                text: 'Seigneur, transforme mon cœur. Fais de moi un témoin de ton amour et de ta miséricorde.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuideSection(
            'Comment se confesser ?',
            [
              '1. **Préparation** : Faites l\'examen de conscience',
              '2. **Prière initiale** : Priez l\'Esprit Saint',
              '3. **Accueil** : Le prêtre vous accueille avec bienveillance',
              '4. **Confession** : Dites vos péchés avec sincérité',
              '5. **Conseil** : Le prêtre vous donne des conseils',
              '6. **Pénitence** : Le prêtre vous donne une pénitence',
              '7. **Contrition** : Exprimez votre regret',
              '8. **Absolution** : Recevez le pardon de Dieu',
              '9. **Action de grâce** : Remerciez Dieu',
            ],
          ),
          const SizedBox(height: 24),
          _buildGuideSection(
            'Conseils pratiques',
            [
            '• Soyez sincère et humble',
            '• Ne cachez aucun péché grave',
            '• Écoutez attentivement les conseils',
            '• Acceptez la pénitence avec joie',
            '• Vivez vraiment la conversion',
            '• Revenez régulièrement',
            '• Confiez-vous à la miséricorde de Dieu',
            ],
          ),
          const SizedBox(height: 24),
          _buildFAQSection(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology, color: kPrimaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Examen de conscience',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Étape ${_currentStep + 1}/${_examinationSteps.length}',
                      style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _examinationSteps.length,
            backgroundColor: kDividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(kAccentColor),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    final step = _examinationSteps[_currentStep];
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kAccentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(step.icon, color: kAccentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...step.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestionItem(question, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(String question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: _completedSteps.contains(_examinationSteps[_currentStep]),
            onChanged: (value) {
              // Toggle completion for this question
            },
            activeColor: kAccentColor,
          ),
          Expanded(
            child: Text(
              question,
              style: TextStyle(
                fontSize: 14,
                color: _completedSteps.contains(_examinationSteps[_currentStep]) 
                    ? kTextSecondaryColor 
                    : kTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _currentStep > 0 ? _previousStep : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Précédent'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryColor,
              side: BorderSide(color: kPrimaryColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _nextStep,
            icon: const Icon(Icons.arrow_forward),
            label: Text(_currentStep == _examinationSteps.length - 1 ? 'Terminer' : 'Suivant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt, color: kAccentColor),
              const SizedBox(width: 8),
              const Text(
                'Réflexion personnelle',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reflectionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Notez vos réflexions, vos regrets, vos résolutions...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kDividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kPrimaryColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Prenez le temps de réfléchir à ce que le Saint-Esprit vous révèle. Notez les points sur lesquels vous devez travailler.',
            style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSection(String title, List<PrayerItem> prayers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
        ),
        const SizedBox(height: 16),
        ...prayers.map((prayer) => _buildPrayerCard(prayer)).toList(),
      ],
    );
  }

  Widget _buildPrayerCard(PrayerItem prayer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, color: kAccentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prayer.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: kPrimaryColor),
                  onPressed: () {
                    // TODO: Implement text-to-speech
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prayer.text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'À quelle fréquence se confesser ?',
        'answer': 'L\'Église recommande de se confesser au moins une fois par an, mais il est conseillé de le faire plus régulièrement (mensuellement ou trimestriellement).',
      },
      {
        'question': 'Que faire si j\'ai oublié un péché ?',
        'answer': 'Si vous avez oublié un péché par ignorance, il est pardonné. Vous pouvez le mentionner lors de votre prochaine confession.',
      },
      {
        'question': 'Le prêtre peut-il révéler mes péchés ?',
        'answer': 'Non. Le secret de la confession est absolu et inviolable. Le prêtre est lié par le sceau sacramentel même sous peine de mort.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Questions Fréquentes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
        ),
        const SizedBox(height: 16),
        ...faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)).toList(),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: TextStyle(fontSize: 14, color: kTextSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _examinationSteps.length - 1) {
      setState(() {
        _currentStep++;
        _animationController.forward();
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _animationController.reverse();
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Examen Terminé!'),
        content: const Text('Vous avez complété l\'examen de conscience. Vous êtes prêt pour la confession. N\'oubliez pas de prier l\'acte de contrition.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetExamination();
            },
            child: const Text('Recommencer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(1); // Go to prayers tab
            },
            child: const Text('Prières'),
          ),
        ],
      ),
    );
  }

  void _resetExamination() {
    setState(() {
      _currentStep = 0;
      _completedSteps.clear();
      _reflectionController.clear();
    });
  }
}

class ConfessionStep {
  final String title;
  final IconData icon;
  final List<String> questions;

  ConfessionStep({
    required this.title,
    required this.icon,
    required this.questions,
  });
}

class PrayerItem {
  final String title;
  final String text;

  PrayerItem({
    required this.title,
    required this.text,
  });
}

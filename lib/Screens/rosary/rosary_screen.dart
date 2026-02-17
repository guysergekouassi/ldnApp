import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class RosaryScreen extends StatefulWidget {
  const RosaryScreen({Key? key}) : super(key: key);

  @override
  _RosaryScreenState createState() => _RosaryScreenState();
}

class _RosaryScreenState extends State<RosaryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int _currentDecade = 0;
  int _currentBead = 0;
  bool _isPlaying = false;
  RosaryType _selectedRosary = RosaryType.joyful;
  bool _showScripture = false;
  
  final List<RosaryMystery> _mysteries = {
    RosaryType.joyful: [
      RosaryMystery(
        title: 'L\'Annonciation',
        scripture: 'L\'ange Gabriel fut envoyé par Dieu dans une ville de Galilée, appelée Nazareth, à une jeune fille vierge, fiancée à un homme de la maison de David, nommé Joseph. Le nom de la jeune fille était Marie. (Lc 1,26-27)',
        fruit: 'Humilité',
        reflection: 'Marie apprend qu\'elle sera la mère du Sauveur. Elle répond "oui" à Dieu avec humilité et confiance.',
      ),
      RosaryMystery(
        title: 'La Visitation',
        scripture: 'En ces jours-là, Marie se mit en route et se rendit en hâte vers une ville de la montagne de Judée. (Lc 1,39)',
        fruit: 'Charité',
        reflection: 'Marie visite sa cousine Élisabeth et l\'aide dans son besoin. Elle partage la joie et l\'amour.',
      ),
      RosaryMystery(
        title: 'La Nativité',
        scripture: 'Marie mit au monde son fils premier-né ; elle l\'emmaillota et le coucha dans une mangeoire, car il n\'y avait pas de place pour eux dans la salle d\'hôtes. (Lc 2,7)',
        fruit: 'Pauvreté',
        reflection: 'Jésus naît dans la simplicité. Il nous enseigne la valeur de la pauvreté spirituelle.',
      ),
      RosaryMystery(
        title: 'La Présentation',
        scripture: 'Quand fut accompli le temps prescrit par la loi de Moïse pour la purification, les parents de Jésus l\'amenèrent à Jérusalem pour le présenter au Seigneur. (Lc 2,22)',
        fruit: 'Obéissance',
        reflection: 'Marie et Joseph obéissent fidèlement à la loi de Dieu. Ils nous montrent l\'exemple de l\'obéissance.',
      ),
      RosaryMystery(
        title: 'Le Recouvrement',
        scripture: 'Quand il eut douze ans, ils montèrent à Jérusalem comme c\'était la coutume pour la fête. (Lc 2,42)',
        fruit: 'Joie',
        reflection: 'Marie et Joseph retrouvent Jésus dans le Temple. Ils découvrent sa mission divine.',
      ),
    ],
    RosaryType.luminous: [
      RosaryMystery(
        title: 'Le Baptême de Jésus',
        scripture: 'Jésus venant de Galilée fut baptisé par Jean dans le Jourdain. (Mt 3,13)',
        fruit: 'Ouverture à l\'Esprit',
        reflection: 'Jésus commence sa mission publique. Le Père se révèle et l\'Esprit descend.',
      ),
      RosaryMystery(
        title: 'Les Noces de Cana',
        scripture: 'Il y eut un mariage à Cana en Galilée. La mère de Jésus était là. (Jn 2,1)',
        fruit: 'Confiance en Marie',
        reflection: 'Marie intercède pour les jeunes mariés. Jésus accomplit son premier miracle.',
      ),
      RosaryMystery(
        title: 'L\'Annonce du Royaume',
        scripture: 'Jésus parcourait toute la Galilée, proclamant la Bonne Nouvelle du Royaume. (Mt 4,23)',
        fruit: 'Conversion',
        reflection: 'Jésus nous appelle à la conversion et à la foi. Il guérit les malades.',
      ),
      RosaryMystery(
        title: 'La Transfiguration',
        scripture: 'Jésus prit avec lui Pierre, Jacques et Jean, et il les fit monter à l\'écart sur une haute montagne. (Mt 17,1)',
        fruit: 'Contemplation',
        reflection: 'Jésus révèle sa gloire divine. Il nous prépare à comprendre sa passion.',
      ),
      RosaryMystery(
        title: 'L\'Institution de l\'Eucharistie',
        scripture: 'Pendant le repas, Jésus prit du pain, le bénit, le rompit et le donna à ses disciples. (Mt 26,26)',
        fruit: 'Adoration',
        reflection: 'Jésus se donne lui-même sous les espèces du pain et du vin. Il reste avec nous.',
      ),
    ],
    RosaryType.sorrowful: [
      RosaryMystery(
        title: 'L\'Agonie',
        scripture: 'Jésus parvint avec ses disciples à un domaine appelé Gethsémani et leur dit : "Restez ici, tandis que je vais prier là-bas." (Mt 26,36)',
        fruit: 'Contrition',
        reflection: 'Jésus souffre intérieurement en acceptant la volonté du Père. Il nous enseigne le courage.',
      ),
      RosaryMystery(
        title: 'La Flagellation',
        scripture: 'Pilate fit délier Jésus et le fit flageller. (Jn 19,1)',
        fruit: 'Purification',
        reflection: 'Jésus endure la souffrance physique pour nos péchés. Il nous montre le chemin de la purification.',
      ),
      RosaryMystery(
        title: 'Le Couronnement d\'épines',
        scripture: 'Les soldats tressèrent une couronne d\'épines, la posèrent sur sa tête. (Mt 27,29)',
        fruit: 'Courage',
        reflection: 'Jésus endure l\'humiliation avec dignité. Il nous apprend à porter nos croix.',
      ),
      RosaryMystery(
        title: 'Le Portement de Croix',
        scripture: 'Quand ils l\'eurent crucifié, ils se partagèrent ses vêtements. (Mt 27,35)',
        fruit: 'Patience',
        reflection: 'Jésus porte sa croix jusqu\'au Calvaire. Il nous accompagne dans nos souffrances.',
      ),
      RosaryMystery(
        title: 'La Crucifixion',
        scripture: 'Jésus poussa un grand cri et rendit l\'esprit. (Mt 27,50)',
        fruit: 'Pardon',
        reflection: 'Jésus donne sa vie par amour. Il nous pardonne et nous ouvre les portes du ciel.',
      ),
    ],
    RosaryType.glorious: [
      RosaryMystery(
        title: 'La Résurrection',
        scripture: 'Il n\'est pas ici, car il est ressuscité comme il l\'avait dit. (Mt 28,6)',
        fruit: 'Foi',
        reflection: 'Jésus vainct la mort. Il nous donne la vie éternelle et l\'espérance.',
      ),
      RosaryMystery(
        title: 'L\'Ascension',
        scripture: 'Le Seigneur Jésus, après leur avoir parlé, fut enlevé au ciel et s\'assit à la droite de Dieu. (Mc 16,19)',
        fruit: 'Espérance',
        reflection: 'Jésus retourne auprès du Père. Il nous prépare une place dans le ciel.',
      ),
      RosaryMystery(
        title: 'La Pentecôte',
        scripture: 'Tous furent remplis d\'Esprit Saint. (Ac 2,4)',
        fruit: 'Sagesse',
        reflection: 'L\'Esprit Saint descend sur les apôtres. Il nous guide et nous fortifie.',
      ),
      RosaryMystery(
        title: 'L\'Assomption',
        scripture: 'Marie fut élevée au ciel dans la gloire. (Tradition)',
        fruit: 'Grâce',
        reflection: 'Marie est la première ressuscitée. Elle nous montre le chemin vers Dieu.',
      ),
      RosaryMystery(
        title: 'Le Couronnement',
        scripture: 'Une grande signe parut dans le ciel : une femme revêtue du soleil. (Ap 12,1)',
        fruit: 'Confiance',
        reflection: 'Marie est couronnée Reine du ciel et de la terre. Elle intercède pour nous.',
      ),
    ],
  }[RosaryType.joyful]!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _audioPlayer.dispose();
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
          'Chapelet Guidé',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: kTextColor),
            onPressed: _showRosaryGuide,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: kAccentColor,
          unselectedLabelColor: kTextSecondaryColor,
          indicatorColor: kAccentColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Prière'),
            Tab(text: 'Mystères'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrayerTab(),
          _buildMysteriesTab(),
        ],
      ),
    );
  }

  Widget _buildPrayerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRosarySelector(),
          const SizedBox(height: 24),
          _buildCurrentDecade(),
          const SizedBox(height: 24),
          _buildRosaryBeads(),
          const SizedBox(height: 24),
          _buildPrayerControls(),
          const SizedBox(height: 24),
          _buildPrayerText(),
        ],
      ),
    );
  }

  Widget _buildMysteriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMysterySelector(),
          const SizedBox(height: 24),
          ..._mysteries.asMap().entries.map((entry) {
            final index = entry.key;
            final mystery = entry.value;
            return _buildMysteryCard(mystery, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRosarySelector() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type de Chapelet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RosaryType.values.map((type) {
              final isSelected = _selectedRosary == type;
              return FilterChip(
                label: Text(_getRosaryTypeName(type)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedRosary = type;
                    _updateMysteries();
                  });
                },
                backgroundColor: kBackgroundColor,
                selectedColor: kAccentColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? kAccentColor : kTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDecade() {
    if (_currentDecade >= _mysteries.length) return const SizedBox.shrink();
    
    final mystery = _mysteries[_currentDecade];
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
                child: Icon(Icons.auto_stories, color: kAccentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mystère ${_currentDecade + 1}/5',
                      style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
                    ),
                    Text(
                      mystery.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Fruit : ${mystery.fruit}',
                      style: TextStyle(fontSize: 12, color: kAccentColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showScripture) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parole de Dieu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: kPrimaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mystery.scripture,
                    style: TextStyle(fontSize: 12, color: kTextSecondaryColor, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showScripture = !_showScripture;
                    });
                  },
                  icon: Icon(_showScripture ? Icons.visibility_off : Icons.visibility),
                  label: Text(_showScripture ? 'Cacher' : 'Lire l\'Écriture'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    side: BorderSide(color: kPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRosaryBeads() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progression',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (decadeIndex) {
              return Column(
                children: [
                  Text(
                    'Dizaine ${decadeIndex + 1}',
                    style: TextStyle(fontSize: 10, color: kTextSecondaryColor),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(10, (beadIndex) {
                      final isCurrentDecade = decadeIndex == _currentDecade;
                      final isCurrentBead = isCurrentDecade && beadIndex == _currentBead;
                      final isCompleted = decadeIndex < _currentDecade || 
                                       (isCurrentDecade && beadIndex < _currentBead);
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCompleted ? kAccentColor : 
                                 isCurrentBead ? kPrimaryColor : kDividerColor,
                          shape: BoxShape.circle,
                          border: isCurrentBead ? Border.all(color: kPrimaryColor, width: 2) : null,
                        ),
                      );
                    }),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentDecade * 10 + _currentBead) / 50,
            backgroundColor: kDividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(kAccentColor),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${_currentDecade * 10 + _currentBead}/50 prières',
              style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerControls() {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _currentBead > 0 ? _previousBead : null,
            icon: const Icon(Icons.skip_previous),
            color: kPrimaryColor,
          ),
          IconButton.filled(
            onPressed: _isPlaying ? _pausePrayer : _playPrayer,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            style: IconButton.styleFrom(
              backgroundColor: kAccentColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(56, 56),
            ),
          ),
          IconButton(
            onPressed: _currentBead < 9 ? _nextBead : _nextDecade,
            icon: const Icon(Icons.skip_next),
            color: kPrimaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerText() {
    final prayer = _getCurrentPrayer();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: kAccentColor),
              const SizedBox(width: 8),
              Text(
                prayer.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prayer.text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMysterySelector() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mystères ${_getRosaryTypeName(_selectedRosary)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _getRosaryDescription(_selectedRosary),
            style: TextStyle(fontSize: 14, color: kTextSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMysteryCard(RosaryMystery mystery, int index) {
    final isCurrent = index == _currentDecade;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrent ? kAccentColor : kPrimaryLightColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mystery.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Fruit : ${mystery.fruit}',
                        style: TextStyle(fontSize: 12, color: kAccentColor),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kAccentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ACTUEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mystery.scripture,
              style: TextStyle(
                fontSize: 12,
                color: kTextSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mystery.reflection,
              style: TextStyle(fontSize: 14, color: kTextColor),
            ),
          ],
        ),
      ),
    );
  }

  PrayerItem _getCurrentPrayer() {
    if (_currentBead == 0) {
      return PrayerItem(title: 'Notre Père', text: 'Notre Père, qui es aux cieux, que ton nom soit sanctifié, que ton règne vienne, que ta volonté soit faite sur la terre comme au ciel. Donne-nous aujourd\'hui notre pain de ce jour. Pardonne-nous nos offenses, comme nous pardonnons aussi à ceux qui nous ont offensés. Ne nous soumets pas à la tentation, mais délivre-nous du mal. Amen.');
    } else {
      return PrayerItem(title: 'Je vous salue Marie', text: 'Je vous salue, Marie, pleine de grâce, le Seigneur est avec vous. Vous êtes bénie entre toutes les femmes, et Jésus, le fruit de vos entrailles, est béni. Sainte Marie, Mère de Dieu, priez pour nous, pauvres pécheurs, maintenant et à l\'heure de notre mort. Amen.');
    }
  }

  void _updateMysteries() {
    setState(() {
      _currentDecade = 0;
      _currentBead = 0;
      _mysteries.clear();
      _mysteries.addAll(_getMysteriesForType(_selectedRosary));
    });
  }

  List<RosaryMystery> _getMysteriesForType(RosaryType type) {
    switch (type) {
      case RosaryType.joyful:
        return [
          RosaryMystery(title: 'L\'Annonciation', scripture: 'Lc 1,26-38', fruit: 'Humilité', reflection: 'Marie dit son "oui" à Dieu.'),
          RosaryMystery(title: 'La Visitation', scripture: 'Lc 1,39-56', fruit: 'Charité', reflection: 'Marie sert sa cousine Élisabeth.'),
          RosaryMystery(title: 'La Nativité', scripture: 'Lc 2,1-20', fruit: 'Pauvreté', reflection: 'Jésus naît dans la simplicité.'),
          RosaryMystery(title: 'La Présentation', scripture: 'Lc 2,22-38', fruit: 'Obéissance', reflection: 'Marie et Joseph présentent Jésus au Temple.'),
          RosaryMystery(title: 'Le Recouvrement', scripture: 'Lc 2,41-52', fruit: 'Joie', reflection: 'Marie et Joseph retrouvent Jésus.'),
        ];
      case RosaryType.luminous:
        return [
          RosaryMystery(title: 'Le Baptême', scripture: 'Mt 3,13-17', fruit: 'Ouverture à l\'Esprit', reflection: 'Jésus commence sa mission.'),
          RosaryMystery(title: 'Cana', scripture: 'Jn 2,1-12', fruit: 'Confiance en Marie', reflection: 'Premier miracle de Jésus.'),
          RosaryMystery(title: 'Annonce du Royaume', scripture: 'Mc 1,14-15', fruit: 'Conversion', reflection: 'Jésus annonce la Bonne Nouvelle.'),
          RosaryMystery(title: 'Transfiguration', scripture: 'Mt 17,1-8', fruit: 'Contemplation', reflection: 'Jésus révèle sa gloire.'),
          RosaryMystery(title: 'Eucharistie', scripture: 'Mt 26,26-29', fruit: 'Adoration', reflection: 'Jésus se donne en nourriture.'),
        ];
      case RosaryType.sorrowful:
        return [
          RosaryMystery(title: 'L\'Agonie', scripture: 'Mt 26,36-46', fruit: 'Contrition', reflection: 'Jésus accepte sa passion.'),
          RosaryMystery(title: 'La Flagellation', scripture: 'Mt 27,26', fruit: 'Purification', reflection: 'Jésus souffre pour nous.'),
          RosaryMystery(title: 'Couronnement d\'épines', scripture: 'Mt 27,27-31', fruit: 'Courage', reflection: 'Jésus endure l\'humiliation.'),
          RosaryMystery(title: 'Portement de Croix', scripture: 'Mt 27,32', fruit: 'Patience', reflection: 'Jésus porte sa croix.'),
          RosaryMystery(title: 'Crucifixion', scripture: 'Mt 27,33-56', fruit: 'Pardon', reflection: 'Jésus donne sa vie.'),
        ];
      case RosaryType.glorious:
        return [
          RosaryMystery(title: 'Résurrection', scripture: 'Mt 28,1-10', fruit: 'Foi', reflection: 'Jésus vainct la mort.'),
          RosaryMystery(title: 'Ascension', scripture: 'Mc 16,19-20', fruit: 'Espérance', reflection: 'Jésus retourne au Père.'),
          RosaryMystery(title: 'Pentecôte', scripture: 'Ac 2,1-11', fruit: 'Sagesse', reflection: 'L\'Esprit Saint descend.'),
          RosaryMystery(title: 'Assomption', scripture: 'Tradition', fruit: 'Grâce', reflection: 'Marie est élevée au ciel.'),
          RosaryMystery(title: 'Couronnement', scripture: 'Ap 12,1', fruit: 'Confiance', reflection: 'Marie est Reine du ciel.'),
        ];
    }
  }

  String _getRosaryTypeName(RosaryType type) {
    switch (type) {
      case RosaryType.joyful:
        return 'Joyeux';
      case RosaryType.luminous:
        return 'Lumineux';
      case RosaryType.sorrowful:
        return 'Douloureux';
      case RosaryType.glorious:
        return 'Glorieux';
    }
  }

  String _getRosaryDescription(RosaryType type) {
    switch (type) {
      case RosaryType.joyful:
        return 'Méditons sur la joie de l\'Incarnation (Lundi et Samedi)';
      case RosaryType.luminous:
        return 'Contemplons la vie publique de Jésus (Jeudi)';
      case RosaryType.sorrowful:
        return 'Réfléchissons sur la passion du Christ (Mardi et Vendredi)';
      case RosaryType.glorious:
        return 'Célébrons la victoire du Christ (Mercredi et Dimanche)';
    }
  }

  void _playPrayer() async {
    setState(() {
      _isPlaying = true;
    });
    _animationController.forward();
    
    // Simuler la lecture audio
    await Future.delayed(const Duration(seconds: 3));
    
    if (_isPlaying) {
      _nextBead();
    }
  }

  void _pausePrayer() {
    setState(() {
      _isPlaying = false;
    });
    _animationController.stop();
  }

  void _nextBead() {
    setState(() {
      if (_currentBead < 9) {
        _currentBead++;
      } else {
        _nextDecade();
      }
      _isPlaying = false;
    });
  }

  void _previousBead() {
    setState(() {
      if (_currentBead > 0) {
        _currentBead--;
      } else if (_currentDecade > 0) {
        _currentDecade--;
        _currentBead = 9;
      }
      _isPlaying = false;
    });
  }

  void _nextDecade() {
    setState(() {
      if (_currentDecade < 4) {
        _currentDecade++;
        _currentBead = 0;
      } else {
        _showCompletionDialog();
      }
      _isPlaying = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chapelet Terminé!'),
        content: const Text('Vous avez complété le chapelet. Que Dieu vous bénisse!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetRosary();
            },
            child: const Text('Recommencer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  void _resetRosary() {
    setState(() {
      _currentDecade = 0;
      _currentBead = 0;
      _isPlaying = false;
    });
  }

  void _showRosaryGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guide du Chapelet'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Comment prier le chapelet :', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Commencez par le signe de la croix'),
              Text('2. Récitez le Credo'),
              Text('3. Récitez un Notre Père'),
              Text('4. Récitez trois Je vous salue Marie'),
              Text('5. Récitez un Gloire au Père'),
              Text('6. Méditez chaque mystère en récitant'),
              Text('   - 1 Notre Père'),
              Text('   - 10 Je vous salue Marie'),
              Text('   - 1 Gloire au Père'),
              Text('7. Terminez par le signe de la croix'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

enum RosaryType {
  joyful,
  luminous,
  sorrowful,
  glorious,
}

class RosaryMystery {
  final String title;
  final String scripture;
  final String fruit;
  final String reflection;

  RosaryMystery({
    required this.title,
    required this.scripture,
    required this.fruit,
    required this.reflection,
  });
}

class PrayerItem {
  final String title;
  final String text;

  PrayerItem({required this.title, required this.text});
}

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class DivineOfficeScreen extends StatefulWidget {
  const DivineOfficeScreen({Key? key}) : super(key: key);

  @override
  _DivineOfficeScreenState createState() => _DivineOfficeScreenState();
}

class _DivineOfficeScreenState extends State<DivineOfficeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentAudioUrl;
  int _currentOfficeIndex = 0;

  final List<Office> _offices = [
    Office(
      id: '1',
      title: 'Laudes',
      time: '06:00',
      description: 'Prière du matin pour louer Dieu au lever du jour',
      audioUrl: 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample.mp3',
      readings: [
        Reading(title: 'Psaume 95', content: 'Venez, crions de joie pour le Seigneur...'),
        Reading(title: 'Cantique de Zacharie', content: 'Béni soit le Seigneur, le Dieu d\'Israël...'),
        Reading(title: 'Lecture brève', content: 'Frères, vous avez été appelés à la liberté...'),
      ],
    ),
    Office(
      id: '2',
      title: 'Tierce',
      time: '09:00',
      description: 'Prière du milieu de matinée',
      audioUrl: 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample.mp3',
      readings: [
        Reading(title: 'Psaume 119', content: 'Ta parole est une lampe pour mes pas...'),
      ],
    ),
    Office(
      id: '3',
      title: 'Sexte',
      time: '12:00',
      description: 'Prière du midi',
      audioUrl: 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample.mp3',
      readings: [
        Reading(title: 'Psaume 91', content: 'Celui qui demeure à l\'abri du Très-Haut...'),
      ],
    ),
    Office(
      id: '4',
      title: 'None',
      time: '15:00',
      description: 'Prière du milieu d\'après-midi',
      audioUrl: 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample.mp3',
      readings: [
        Reading(title: 'Psaume 130', content: 'Des profondeurs je crie vers toi, Seigneur...'),
      ],
    ),
    Office(
      id: '5',
      title: 'Vêpres',
      time: '18:00',
      description: 'Prière du soir pour remercier Dieu',
      audioUrl: 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample.mp3',
      readings: [
        Reading(title: 'Psaume 141', content: 'Seigneur, je t\'appelle, hâte-toi de me répondre...'),
        Reading(title: 'Cantique de Marie', content: 'Mon âme exalte le Seigneur...'),
      ],
    ),
    Office(
      id: '6',
      title: 'Complies',
      time: '21:00',
      description: 'Prière avant de dormir',
      audioUrl: 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample.mp3',
      readings: [
        Reading(title: 'Psaume 4', content: 'Quand je crie, réponds-moi, Dieu de ma justice...'),
        Reading(title: 'Cantique de Siméon', content: 'Maintenant, Souverain Maître, tu peux laisser ton serviteur s\'en aller...'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'Office des Heures',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kAccentColor,
          unselectedLabelColor: kTextSecondaryColor,
          indicatorColor: kAccentColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Aujourd\'hui'),
            Tab(text: 'Textes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(),
          _buildTextsView(),
        ],
      ),
      bottomNavigationBar: _currentAudioUrl != null ? _buildAudioPlayer() : null,
    );
  }

  Widget _buildTodayView() {
    final currentHour = DateTime.now().hour;
    final currentOffice = _getCurrentOffice(currentHour);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentOfficeCard(currentOffice),
          const SizedBox(height: 24),
          _buildAllOfficesGrid(),
          const SizedBox(height: 24),
          _buildPrayerIntentions(),
        ],
      ),
    );
  }

  Widget _buildTextsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Textes de l\'Office',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
          ),
          const SizedBox(height: 16),
          ..._offices[_currentOfficeIndex].readings.map((reading) => _buildReadingCard(reading)).toList(),
        ],
      ),
    );
  }

  Widget _buildCurrentOfficeCard(Office office) {
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
                child: Icon(Icons.access_time, color: kPrimaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Office actuel',
                      style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
                    ),
                    Text(
                      office.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor),
                    ),
                    Text(
                      office.time,
                      style: TextStyle(fontSize: 14, color: kAccentColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            office.description,
            style: TextStyle(fontSize: 14, color: kTextSecondaryColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _playAudio(office.audioUrl),
                  icon: Icon(_isPlaying && _currentAudioUrl == office.audioUrl 
                      ? Icons.pause 
                      : Icons.play_arrow),
                  label: Text(_isPlaying && _currentAudioUrl == office.audioUrl 
                      ? 'Pause' 
                      : 'Écouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentOfficeIndex = _offices.indexOf(office);
                    });
                    _tabController.animateTo(1);
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Lire les textes'),
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

  Widget _buildAllOfficesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tous les offices',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _offices.length,
          itemBuilder: (context, index) {
            final office = _offices[index];
            final isCurrentOffice = office == _getCurrentOffice(DateTime.now().hour);
            
            return InkWell(
              onTap: () {
                setState(() {
                  _currentOfficeIndex = index;
                });
                _tabController.animateTo(1);
              },
              borderRadius: BorderRadius.circular(16),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isCurrentOffice ? kAccentColor : kPrimaryLightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.church_outlined,
                            size: 16,
                            color: isCurrentOffice ? Colors.white : kPrimaryColor,
                          ),
                        ),
                        const Spacer(),
                        if (isCurrentOffice)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kAccentColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'ACTUEL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      office.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      office.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextSecondaryColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${office.readings.length} textes',
                      style: TextStyle(
                        fontSize: 10,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReadingCard(Reading reading) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reading.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reading.content,
              style: TextStyle(
                fontSize: 14,
                color: kTextSecondaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement text-to-speech
                  },
                  icon: const Icon(Icons.volume_up, size: 16),
                  label: const Text('Écouter'),
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerIntentions() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: kAccentColor),
              const SizedBox(width: 8),
              const Text(
                'Intentions de prière',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Pour les malades et les personnes âgées\n'
            '• Pour les jeunes en recherche de sens\n'
            '• Pour les vocations sacerdotales et religieuses\n'
            '• Pour la paix dans le monde',
            style: TextStyle(
              fontSize: 14,
              color: kTextSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _isPlaying ? _pauseAudio : _resumeAudio,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 32,
                color: kAccentColor,
              ),
              IconButton(
                onPressed: _stopAudio,
                icon: const Icon(Icons.stop),
                iconSize: 24,
                color: kTextSecondaryColor,
              ),
              Expanded(
                child: Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds.toDouble(),
                      onChanged: (value) {
                        _seekAudio(Duration(seconds: value.toInt()));
                      },
                      activeColor: kAccentColor,
                      inactiveColor: kDividerColor,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_position)),
                        Text(_formatDuration(_duration)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Office _getCurrentOffice(int hour) {
    if (hour >= 5 && hour < 8) return _offices[0]; // Laudes
    if (hour >= 8 && hour < 11) return _offices[1]; // Tierce
    if (hour >= 11 && hour < 14) return _offices[2]; // Sexte
    if (hour >= 14 && hour < 17) return _offices[3]; // None
    if (hour >= 17 && hour < 20) return _offices[4]; // Vêpres
    return _offices[5]; // Complies
  }

  Future<void> _playAudio(String url) async {
    try {
      if (_currentAudioUrl == url && _isPlaying) {
        await _pauseAudio();
      } else {
        await _audioPlayer.play(UrlSource(url));
        setState(() {
          _currentAudioUrl = url;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la lecture audio: $e')),
      );
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _resumeAudio() async {
    await _audioPlayer.resume();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _currentAudioUrl = null;
      _position = Duration.zero;
    });
  }

  Future<void> _seekAudio(Duration position) async {
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class Office {
  final String id;
  final String title;
  final String time;
  final String description;
  final String audioUrl;
  final List<Reading> readings;

  Office({
    required this.id,
    required this.title,
    required this.time,
    required this.description,
    required this.audioUrl,
    required this.readings,
  });
}

class Reading {
  final String title;
  final String content;

  Reading({
    required this.title,
    required this.content,
  });
}

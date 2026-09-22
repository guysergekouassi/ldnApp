import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../models/prayer_activity_model.dart';
import 'chapelet_guide_screen.dart';
import 'office_des_heures_screen.dart';
import 'evangile_du_jour_screen.dart';
import 'neuvaines_list_screen.dart';
import 'preparation_confession_screen.dart';
import 'intentions_semaine_screen.dart';
import 'divine_misericorde_screen.dart';
import 'bible_plans_screen.dart';

class PrionsEnsembleScreen extends StatefulWidget {
  const PrionsEnsembleScreen({Key? key}) : super(key: key);

  @override
  State<PrionsEnsembleScreen> createState() => _PrionsEnsembleScreenState();
}

class _PrionsEnsembleScreenState extends State<PrionsEnsembleScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  Map<String, String> _prayerTimes = {
    'Matin': '06:30',
    'Midi': '12:00',
    'Soir': '21:30',
  };

  /// Jours de récitation des mystères : convention liturgique fixe, elle n'a
  /// pas vocation à être éditée en base. Seule la liste des mystères proposés
  /// vient de Firestore.
  static const Map<String, String> _joursDesMysteres = {
    'Joyeux': "Lundi et Samedi",
    'Douloureux': "Mardi et Vendredi",
    'Glorieux': "Mercredi et Dimanche",
    'Lumineux': "Jeudi",
  };

  static final Map<String, Color> _couleurDesMysteres = {
    'Joyeux': Colors.orange,
    'Douloureux': Colors.redAccent,
    'Glorieux': Colors.amber,
    'Lumineux': Colors.yellow.shade700,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildGrid(context),
          const SizedBox(height: 20),
          _buildProgramme(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/sunset_bg.jpg"),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Container(
          // Hauteur minimale et non figée : avec un texte agrandi par les
          // réglages système, le contenu débordait de l'en-tête.
          constraints: const BoxConstraints(minHeight: 250),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.5),
                const Color(0xFFF8F9FA),
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pan_tool_outlined, color: Colors.orange),
                        ),
                        const SizedBox(width: 10),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.orange, Colors.red],
                          ).createShader(bounds),
                          child: const Text(
                            "Prions Ensemble",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Comment veux-tu rencontrer",
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                Row(
                  children: const [
                    Text(
                      "Dieu ",
                      style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "aujourd'hui ?",
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: StreamBuilder<List<PrayerActivity>>(
        stream: _firestoreService.getPrayerActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: Colors.orange)),
            );
          }

          final activities = snapshot.data ?? [];
          if (activities.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                "Aucune proposition de prière pour le moment.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Un ratio figé donnait une hauteur de cellule proportionnelle à la
          // largeur de l'écran : sur un petit écran, ou avec un texte agrandi
          // par les réglages système, le titre et le bouton débordaient.
          // On calcule la hauteur dont la carte a réellement besoin.
          return LayoutBuilder(
            builder: (context, constraints) {
              const colonnes = 3;
              const espacement = 10.0;
              final largeurCarte =
                  (constraints.maxWidth - espacement * (colonnes - 1)) / colonnes;

              // La vignette occupe 40 % de la carte (flex 40/60 dans _buildCard).
              // Le reste doit loger le titre (3 lignes), la durée et le bouton,
              // dont la hauteur suit l'agrandissement de police du système.
              final echelleTexte = MediaQuery.textScalerOf(context).scale(1.0);
              final hauteurTexte = 92.0 * echelleTexte;
              final hauteurCarte = (largeurCarte * 0.62) + hauteurTexte;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: colonnes,
                crossAxisSpacing: espacement,
                mainAxisSpacing: 15,
                childAspectRatio: largeurCarte / hauteurCarte,
                children: activities
                    .map((activity) => _buildCard(
                          activity.title,
                          activity.duration,
                          activity.imageAsset,
                          _iconFor(activity.iconName),
                          _colorFor(activity.colorHex),
                          onTap: () => _openActivity(activity.action),
                        ))
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'brightness_high':
        return Icons.brightness_high;
      case 'menu_book':
        return Icons.menu_book;
      case 'local_fire_department_outlined':
        return Icons.local_fire_department_outlined;
      case 'add':
        return Icons.add;
      case 'favorite_border':
        return Icons.favorite_border;
      default:
        return Icons.self_improvement;
    }
  }

  Color _colorFor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.orange;
    }
  }

  /// Résout la clé de destination portée par l'activité.
  void _openActivity(String action) {
    switch (action) {
      case 'chapelet':
        _showMysteriesSelection(context);
        break;
      case 'office':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const OfficeDesHeuresScreen()));
        break;
      case 'evangile':
        Navigator.push(context, MaterialPageRoute(builder: (context) => EvangileDuJourScreen()));
        break;
      case 'neuvaines':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NeuvainesListScreen()));
        break;
      case 'confession':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PreparationConfessionScreen()));
        break;
      case 'intentions':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const IntentionsSemaineScreen()));
        break;
      case 'misericorde':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DivineMisericordeScreen()));
        break;
      case 'bible':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const BiblePlansScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cette proposition n'est pas encore disponible.")),
        );
    }
  }

  Widget _buildCard(String title, String duration, String imagePath, IconData icon, Color btnColor, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
                      ],
                    ),
                    child: Icon(icon, color: btnColor, size: 16),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 8, right: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 11, height: 1.2),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 10, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          duration,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 26,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: onTap ?? () {},
                      child: const Text("Commencer", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramme() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: _uid == null
        ? const Center(child: Text("Connectez-vous pour configurer votre programme", style: TextStyle(color: Colors.grey)))
        : StreamBuilder<Map<String, String>>(
          stream: _firestoreService.getPrayerTimes(_uid!),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              _prayerTimes = snapshot.data!;
            }
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_today, color: Colors.orange, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Mon programme de prière", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            Text("Reste fidèle, chaque prière compte.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showPrayerTimesDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Text("Configurer", style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                              Icon(Icons.settings, size: 12, color: Colors.orange),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Stack(
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Container(
                        height: 6,
                        width: 200, 
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.orange, Colors.redAccent]),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Positioned(
                        left: 195,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Center(child: Icon(Icons.star, size: 8, color: Colors.orange)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  Builder(
                    builder: (context) {
                      final hour = DateTime.now().hour;
                      final isMatin = hour < 12;
                      final isMidi = hour >= 12 && hour < 17;
                      final isSoir = hour >= 17;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTimePhase("Matin", _prayerTimes['Matin'] ?? "06:30", Icons.wb_sunny_outlined, isMatin),
                          _buildTimePhase("Midi", _prayerTimes['Midi'] ?? "12:00", Icons.brightness_high_outlined, isMidi),
                          _buildTimePhase("Soir", _prayerTimes['Soir'] ?? "21:30", Icons.nightlight_round, isSoir),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star, color: Colors.orange, size: 12),
                      SizedBox(width: 5),
                      Text("Dieu t'accompagne à chaque instant.", style: TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  )
                ],
              ),
            );
          }
        ),
    );
  }

  Future<void> _showPrayerTimesDialog() async {
    Map<String, String> tempTimes = Map.from(_prayerTimes);
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text("Modifier mes rappels", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['Matin', 'Midi', 'Soir'].map((period) {
                  return ListTile(
                    title: Text("Prière du $period"),
                    trailing: Text(tempTimes[period]!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    onTap: () async {
                      final parts = tempTimes[period]!.split(':');
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                      );
                      if (time != null) {
                        setDialogState(() {
                          final hh = time.hour.toString().padLeft(2, '0');
                          final mm = time.minute.toString().padLeft(2, '0');
                          tempTimes[period] = "$hh:$mm";
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                  onPressed: () async {
                    Navigator.pop(context);
                    if (_uid != null) {
                      await _firestoreService.updatePrayerTimes(_uid!, tempTimes);
                    }
                    
                    await _rescheduleNotifications(tempTimes);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Horaires mis à jour !")));
                    }
                  },
                  child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _rescheduleNotifications(Map<String, String> times) async {
    await NotificationService().syncPrayerReminders(times);
  }

  Widget _buildTimePhase(String title, String timeStr, IconData icon, bool completed) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: completed ? Colors.orange.shade50 : Colors.transparent,
                shape: BoxShape.circle,
                border: completed ? null : Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Icon(icon, color: completed ? Colors.orange : Colors.grey, size: 20),
            ),
            if (completed)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: completed ? Colors.black87 : Colors.grey)),
            Text(timeStr, style: TextStyle(fontSize: 10, color: completed ? Colors.green : Colors.grey)),
          ],
        )
      ],
    );
  }

  void _showMysteriesSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Choisir les mystères", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 10),
              const Text("Sélectionne les mystères que tu souhaites méditer aujourd'hui.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),
              StreamBuilder<List<String>>(
                stream: _firestoreService.getChapeletMysteryTypes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                    );
                  }

                  final types = snapshot.data ?? [];
                  if (types.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Les mystères ne sont pas encore disponibles.",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: types
                        .map((type) => _buildMysteryOption(
                              context,
                              type,
                              _joursDesMysteres[type] ?? "",
                              _couleurDesMysteres[type] ?? Colors.orange,
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMysteryOption(BuildContext context, String type, String days, Color color) {
    return ListTile(
      leading: Icon(Icons.brightness_high, color: color),
      title: Text("Mystères $type", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(days, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChapeletGuideScreen(mysteryType: type)));
      },
    );
  }
}

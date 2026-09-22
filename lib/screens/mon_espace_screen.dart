import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/versets_catalogue.dart';
import '../services/notification_service.dart';
import '../models/objectif_model.dart';
import '../models/regularite_model.dart';
import '../components/user_avatar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'carnet_spirituel_screen.dart';
import 'create_intention_screen.dart';
import 'all_intentions_screen.dart';
import 'all_objectifs_screen.dart';
import 'welcome_screen.dart';
import '../components/ldn_signature.dart';
import '../services/auth_service.dart';
import '../models/discipline_model.dart';
import 'membre_screen.dart';
import 'aller_plus_loin_screen.dart';

class MonEspaceScreen extends StatefulWidget {
  const MonEspaceScreen({Key? key}) : super(key: key);

  @override
  State<MonEspaceScreen> createState() => _MonEspaceScreenState();
}

class _MonEspaceScreenState extends State<MonEspaceScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  /// Session ouverte sans compte : Mon Espace propose alors la conversion.
  bool get _estInvite => FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

  /// Ancre du bloc « Paramètres », ciblée par l'icône d'engrenage de l'en-tête.
  final GlobalKey _parametresKey = GlobalKey();

  Map<String, String> _prayerTimes = {
    'Matin': '06:30',
    'Midi': '12:00',
    'Soir': '21:30',
  };

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _firestoreService.checkAndInitializeUserObjectifs(_uid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (_estInvite) ...[
                    _buildBandeauInvite(),
                    const SizedBox(height: 10),
                  ],
                  _buildAccesMembre(),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildAnneeSpirituelle()),
                      const SizedBox(width: 10),
                      Expanded(child: _buildRegularite()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildProgrammePriere(),
                  const SizedBox(height: 10),
                  _buildIntentions(),
                  const SizedBox(height: 10),
                  _buildAllerPlusLoin(),
                  const SizedBox(height: 15),
                  _buildParametres(),
                  const SizedBox(height: 15),
                  _buildParoleAujourdHui(),
                  const LdnSignature(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 220,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/sunset_bg.jpg"), // Replace with appropriate bg
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFF8F9FA).withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CurrentUserAvatar(radius: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: _uid != null ? _firestoreService.getUserProfile(_uid!) : null,
                    builder: (context, userSnapshot) {
                      String userName = "Yannick"; // Default fallback
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        var data = userSnapshot.data!.data() as Map<String, dynamic>?;
                        if (data != null && data.containsKey('fullName')) {
                          userName = data['fullName'].toString().split(' ')[0]; // Prends le prénom
                        }
                      }

                      return StreamBuilder<Map<String, String>>(
                        stream: _firestoreService.getVersetDuJour(),
                        builder: (context, verseSnapshot) {
                          final verset = verseSnapshot.data;
                          final String verseText = verset?['content'] ?? versetParDefaut.contenu;
                          final String reference = verset?['reference'] ?? versetParDefaut.reference;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mon Espace",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Bonjour $userName !",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "« $verseText »",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF0F172A),
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reference,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          );
                        }
                      );
                    }
                  ),
                ),
                GestureDetector(
                  onTap: _scrollToParametres,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.settings_outlined, size: 20, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String number, String title, {IconData? icon, Color? numColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: numColor ?? Colors.orange, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        if (icon != null) Icon(icon, size: 14, color: const Color(0xFF0F172A)),
      ],
    );
  }

  Widget _buildAnneeSpirituelle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("1", "Mon année spirituelle", icon: Icons.track_changes),
          const SizedBox(height: 15),
          StreamBuilder<List<Objectif>>(
            stream: _uid != null ? _firestoreService.getUserObjectifs(_uid!) : Stream.value([]),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }

              final objectifs = snapshot.data!;
              
              // Helper pour convertir l'icon string en IconData
              IconData getIcon(String iconName) {
                switch(iconName) {
                  case 'pan_tool_outlined': return Icons.pan_tool_outlined;
                  case 'menu_book': return Icons.menu_book;
                  case 'menu_book_outlined': return Icons.menu_book_outlined;
                  default: return Icons.track_changes;
                }
              }

              return Column(
                children: objectifs.map((obj) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildGoalProgress(
                      getIcon(obj.icon), 
                      Color(int.parse(obj.colorHex.replaceFirst('#', '0xFF'))), 
                      obj.title, 
                      obj.progress
                    ),
                  );
                }).toList(),
              );
            }
          ),
          const SizedBox(height: 5),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AllObjectifsScreen()),
              ),
              child: const Text("Voir tous mes objectifs >", style: TextStyle(color: Color(0xFF5B4FC8), fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress(IconData icon, Color color, String title, double progress) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              const Text("Objectif annuel", style: TextStyle(color: Colors.grey, fontSize: 8)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegularite() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: _uid == null 
        ? Column(
            children: [
              _buildSectionHeader("2", "Ma régularité"),
              const SizedBox(height: 15),
              const Text("Connectez-vous", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        : StreamBuilder<Regularite>(
          stream: _firestoreService.getRegularite(_uid!),
          builder: (context, snapshot) {
            int streak = 0;
            Map<String, bool> weekDays = {'L': false, 'M': false, 'M2': false, 'J': false, 'V': false, 'S': false, 'D': false};
            
            if (snapshot.hasData) {
              streak = snapshot.data!.streak;
              weekDays = {
                'L': snapshot.data!.weekDays['L'] ?? false,
                'M': snapshot.data!.weekDays['M1'] ?? false, // M1 = Mardi
                'M2': snapshot.data!.weekDays['M2'] ?? false, // M2 = Mercredi
                'J': snapshot.data!.weekDays['J'] ?? false,
                'V': snapshot.data!.weekDays['V'] ?? false,
                'S': snapshot.data!.weekDays['S'] ?? false,
                'D': snapshot.data!.weekDays['D'] ?? false,
              };
            }

            return Column(
              children: [
                _buildSectionHeader("2", "Ma régularité"),
                const SizedBox(height: 15),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: streak > 0 ? (streak % 30) / 30 : 0, // Exemple de progression sur 30 jours
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        strokeWidth: 4,
                      ),
                    ),
                    Column(
                      children: [
                        Text("$streak", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const Text("jours\nconsécutifs", textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDayCircle("L", weekDays['L']!),
                    _buildDayCircle("M", weekDays['M']!),
                    _buildDayCircle("M", weekDays['M2']!),
                    _buildDayCircle("J", weekDays['J']!),
                    _buildDayCircle("V", weekDays['V']!),
                    _buildDayCircle("S", weekDays['S']!),
                    _buildDayCircle("D", weekDays['D']!),
                  ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Garde le feu allumé ! 🔥", style: TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            );
          }
        ),
    );
  }

  Widget _buildDayCircle(String day, bool isChecked) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isChecked ? const Color(0xFF0F172A) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0F172A)),
          ),
          alignment: Alignment.center,
          child: isChecked ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
        ),
      ],
    );
  }

  Widget _buildProgrammePriere() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: _uid == null 
        ? const Center(child: Text("Connectez-vous pour voir votre programme", style: TextStyle(fontSize: 10, color: Colors.grey)))
        : StreamBuilder<Map<String, String>>(
          stream: _firestoreService.getPrayerTimes(_uid!),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              _prayerTimes = snapshot.data!;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.access_time, size: 14, color: Color(0xFF0F172A)),
                    SizedBox(width: 6),
                    Expanded(child: Text("Mon programme de prière", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A)))),
                  ],
                ),
                const SizedBox(height: 15),
                _buildPriereTime(Icons.wb_sunny_outlined, Colors.orange, "Matin", _prayerTimes['Matin'] ?? "06:30"),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 10),
                _buildPriereTime(Icons.wb_sunny, Colors.orangeAccent, "Midi", _prayerTimes['Midi'] ?? "12:00"),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 10),
                _buildPriereTime(Icons.nightlight_round, const Color(0xFF0F172A), "Soir", _prayerTimes['Soir'] ?? "21:30"),
                const SizedBox(height: 15),
                Center(
                  child: GestureDetector(
                    onTap: () => _showPrayerTimesDialog(),
                    child: const Text("Modifier mes rappels >", style: TextStyle(color: Color(0xFF5B4FC8), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
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
                    // Sauvegarder dans Firestore
                    if (_uid != null) {
                      await _firestoreService.updatePrayerTimes(_uid!, tempTimes);
                    }
                    
                    // Reprogrammer les notifications
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

  Widget _buildPriereTime(IconData icon, Color iconColor, String label, String time) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF0F172A))),
        ),
        const Spacer(),
        Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(width: 8),
        const Icon(Icons.notifications_none, size: 14, color: Colors.grey),
      ],
    );
  }

  Widget _buildIntentions() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pan_tool_outlined, size: 12, color: Colors.orange),
              SizedBox(width: 4),
              Expanded(child: Text("Mes intentions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF0F172A)))),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<Map<String, int>>(
            stream: _uid != null ? _firestoreService.getUserIntentionsStats(_uid!) : Stream.value({'actives':0, 'exaucees':0}),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? {'actives':0, 'exaucees':0};
              return Column(
                children: [
                  _buildIntentionRow("Intentions actives", "${stats['actives']}", Colors.orange.shade50, Colors.orange),
                  const SizedBox(height: 6),
                  _buildIntentionRow("Intentions exaucées", "${stats['exaucees']}", Colors.green.shade50, Colors.green),
                ],
              );
            }
          ),
          const SizedBox(height: 6),
          GestureDetector(
            // Les grâces reçues sont consignées dans le carnet spirituel,
            // onglet « Prières exaucées ».
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CarnetSpirituelScreen(initialTab: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(child: Text("Journal des grâces\nreçues", style: TextStyle(fontSize: 8, color: Color(0xFF0F172A)))),
                Icon(Icons.chevron_right, size: 10, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade50,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateIntentionScreen()),
              ),
              child: const Text("Déposer une intention", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntentionRow(String label, String count, Color bgColor, Color textColor) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllIntentionsScreen()),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
            child: Text(count, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 10, color: Colors.grey),
        ],
      ),
    );
  }

  /// Fait défiler la page jusqu'au bloc « Paramètres » (icône d'engrenage
  /// de l'en-tête).
  void _scrollToParametres() {
    final ctx = _parametresKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  /// Récapitulatif factuel des données que l'application enregistre, tel que
  /// le code les écrit réellement dans Firestore.
  void _showConfidentialite() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Text("Confidentialité", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 15),
            const Text(
              "Voici précisément ce que l'application enregistre sur toi.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ..._donneesEnregistrees.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text(entry.value, style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.black87)),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),
            const Text(
              "Tes publications et intentions déposées dans la Communauté sont visibles "
              "par les autres membres. Tout le reste (carnet, favoris, statistiques, "
              "horaires de prière) reste privé.",
              style: TextStyle(fontSize: 12, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static const Map<String, String> _donneesEnregistrees = {
    "Profil":
        "Ton nom, ton adresse email et ta photo, fournis à l'inscription ou par ton compte Google.",
    "Vie de prière":
        "Ta régularité, tes jours de prière validés, tes objectifs, tes horaires de rappel "
        "et l'avancement de tes parcours et neuvaines.",
    "Carnet et favoris":
        "Les notes de ton carnet spirituel et les versets ou prières que tu mets en favori.",
    "Communauté":
        "Tes publications, tes intentions de prière et les intentions pour lesquelles tu as prié.",
    "Quiz":
        "Tes points, ton niveau et ta position au classement.",
  };

  /// Informations du compte, alimentées par Firebase Auth et le document
  /// `users`, avec les actions réellement disponibles.
  void _showCompte() {
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Mon compte", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 20),
              if (user == null)
                const Text("Tu n'es pas connecté.", style: TextStyle(color: Colors.grey))
              else ...[
                Row(
                  children: [
                    const CurrentUserAvatar(radius: 26),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName?.isNotEmpty == true ? user.displayName! : "Membre",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(user.email ?? "", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_reset, color: Color(0xFF0F172A)),
                  title: const Text("Changer mon mot de passe", style: TextStyle(fontSize: 14)),
                  subtitle: const Text("Un email de réinitialisation te sera envoyé.", style: TextStyle(fontSize: 11)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final email = user.email;
                    if (email == null || email.isEmpty) return;
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Email envoyé à $email."), backgroundColor: Colors.green),
                      );
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Envoi impossible pour le moment."), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Se déconnecter", style: TextStyle(fontSize: 14, color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Entrée vers l'espace Membre.
  ///
  /// Le palier affiché est recalculé à la volée depuis la règle de vie et la
  /// régularité : il n'est jamais stocké, donc jamais en retard sur les faits.
  Widget _buildAccesMembre() {
    if (_uid == null) return const SizedBox.shrink();

    return StreamBuilder<DisciplineMembre>(
      stream: _firestoreService.getDiscipline(_uid!),
      builder: (context, disciplineSnapshot) {
        final discipline =
            disciplineSnapshot.data ?? const DisciplineMembre(engagementIds: []);

        return StreamBuilder<Regularite>(
          stream: _firestoreService.getRegularite(_uid!),
          builder: (context, regulariteSnapshot) {
            final statut = StatutMembreLibelle.calculer(
              estInvite: _estInvite,
              nombreEngagements: discipline.engagementIds.length,
              streak: regulariteSnapshot.data?.streak ?? 0,
            );
            final couleur = Color(
              int.parse(statut.couleurHex.replaceFirst('#', '0xFF')),
            );

            return InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MembreScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [couleur, Color.lerp(couleur, Colors.black, 0.3) ?? couleur],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.badge_outlined, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Espace Membre",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            discipline.estDefinie
                                ? "${statut.libelle} · ${discipline.engagementIds.length} engagements"
                                : "${statut.libelle} · choisis ta règle de vie",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Bandeau affiché aux comptes invités.
  ///
  /// Le mode invité enregistre bien la progression, mais elle est liée à
  /// l'installation : sans compte, une réinstallation la perd. Le bandeau le
  /// dit et propose la conversion, qui conserve tout.
  Widget _buildBandeauInvite() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Colors.orange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tu es en mode invité",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Crée ton compte pour garder ta progression même en changeant de téléphone.",
                  style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 32),
                  ),
                  onPressed: _showCreationCompte,
                  child: const Text(
                    "Créer mon compte",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formulaire de conversion du compte invité en compte définitif.
  ///
  /// On passe par `lierCompteEmail` / `lierCompteGoogle` plutôt que par une
  /// inscription classique : l'identifiant Firebase est conservé, donc toute
  /// la progression déjà enregistrée reste rattachée au membre.
  Future<void> _showCreationCompte() async {
    final nomController = TextEditingController();
    final emailController = TextEditingController();
    final motDePasseController = TextEditingController();
    bool enCours = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> terminer(Future<User?> Function() action) async {
            setSheetState(() => enCours = true);
            try {
              final user = await action();
              if (user == null) {
                setSheetState(() => enCours = false);
                return; // connexion Google annulée
              }
              if (!sheetContext.mounted) return;
              Navigator.pop(sheetContext);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Compte créé : ta progression est sauvegardée 🎉"),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {}); // le bandeau disparaît
            } on FirebaseAuthException catch (e) {
              setSheetState(() => enCours = false);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_messageErreurAuth(e)), backgroundColor: Colors.red),
              );
            } catch (e) {
              setSheetState(() => enCours = false);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Création impossible. Vérifie ta connexion."),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Créer mon compte",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Tout ce que tu as déjà enregistré est conservé.",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nomController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: "Mon nom",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: motDePasseController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        helperText: "6 caractères minimum",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: enCours
                            ? null
                            : () {
                                final nom = nomController.text.trim();
                                final email = emailController.text.trim();
                                final motDePasse = motDePasseController.text;

                                if (nom.isEmpty || email.isEmpty || motDePasse.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Renseigne ton nom, ton email et un mot de passe de 6 caractères."),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                terminer(() => _authService.lierCompteEmail(nom, email, motDePasse));
                              },
                        child: enCours
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                "Créer mon compte",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("OU", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: enCours ? null : () => terminer(_authService.lierCompteGoogle),
                        icon: const Icon(Icons.account_circle_outlined, color: Colors.black87, size: 20),
                        label: const Text(
                          "Continuer avec Google",
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _messageErreurAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
      case 'credential-already-in-use':
        return "Cet email est déjà utilisé. Connecte-toi avec ce compte.";
      case 'invalid-email':
        return "Cet email n'est pas valide.";
      case 'weak-password':
        return "Mot de passe trop faible : 6 caractères minimum.";
      case 'operation-not-allowed':
        return "Ce mode de connexion n'est pas activé côté Firebase.";
      default:
        return "Création impossible. Réessaie dans un instant.";
    }
  }

  /// Entrée vers « Aller plus loin ».
  ///
  /// Placée dans Mon Espace et non dans la Communauté : on cherche de l'aide
  /// depuis son espace personnel, pas depuis un fil public.
  Widget _buildAllerPlusLoin() {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllerPlusLoinScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.support_outlined, color: Colors.orange, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aller plus loin",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 3),
                  Text(
                    "Deuil, solitude, doute, dépendance… Trouve vers qui te tourner, ou demande une écoute.",
                    style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildParametres() {
    return Container(
      key: _parametresKey,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.settings_outlined, size: 16, color: Color(0xFF0F172A)),
              SizedBox(width: 8),
              Text("Paramètres", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.start,
            children: [
              _buildParamItem(Icons.notifications_none, "Notifications", onTap: _showPrayerTimesDialog),
              _buildParamItem(Icons.nightlight_round, "Mode nuit", action: _buildToggleSwitch()),
              _buildParamItem(Icons.shield_outlined, "Confidentialité", onTap: _showConfidentialite),
              _buildParamItem(Icons.person_outline, "Compte", onTap: _showCompte),
              _buildParamItem(
                Icons.logout, 
                "Déconnexion", 
                action: const Icon(Icons.exit_to_app, size: 14, color: Colors.red),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParamItem(IconData icon, String label, {Widget? action, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF0F172A))),
          ),
          const SizedBox(width: 8),
          action ?? Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isNightMode = themeProvider.isDarkMode;
        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
          },
          child: Container(
            width: 28,
            height: 14,
            decoration: BoxDecoration(
              color: isNightMode ? Colors.orange : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: isNightMode ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildParoleAujourdHui() {
    return StreamBuilder<Map<String, String>>(
      stream: _firestoreService.getVersetDuJour(),
      builder: (context, snapshot) {
        final verset = snapshot.data;
        final String verseText = verset?['content'] ?? versetParDefaut.contenu;
        final String reference = verset?['reference'] ?? versetParDefaut.reference;

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(15),
            image: const DecorationImage(
              image: AssetImage("assets/sunset_bg.jpg"), // Image de fond
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Parole pour aujourd'hui", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text("« $verseText »", style: const TextStyle(color: Colors.white, fontSize: 11, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 5),
                    Text(reference, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

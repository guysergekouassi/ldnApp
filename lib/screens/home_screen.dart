import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'prions_ensemble_screen.dart';
import 'grandir_dans_la_foi_screen.dart';
import 'metanoia_screen.dart';
import 'communaute_screen.dart';
import 'mon_espace_screen.dart';
import 'bons_plans_screen.dart';
import 'quiz_jeux_screen.dart';
import 'evangile_du_jour_screen.dart';
import 'chapelet_guide_screen.dart';
import 'carnet_spirituel_screen.dart';
import '../services/firestore_service.dart';
import '../services/versets_catalogue.dart';
import '../services/notification_service.dart';
import '../services/intention_watcher.dart';
import '../models/intention_model.dart';
import '../models/daily_task_model.dart';
import '../models/favori_model.dart';
import '../models/parcours_content_model.dart';
import 'parcours_detail_screen.dart';
import '../components/app_bottom_nav_bar.dart';
import '../components/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  /// Onglet affiché à l'ouverture. Permet aux écrans secondaires de revenir
  /// au shell sur l'onglet choisi via [AppBottomNavBar].
  final int initialIndex;

  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late int _currentIndex = widget.initialIndex;

  /// Le shell est recréé à chaque changement d'onglet depuis un écran
  /// secondaire ; on ne réamorce le contenu Firestore qu'une fois par session.
  static bool _contentInitialized = false;

  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  /// Jour courant du parcours. Volontairement **non final** : l'application
  /// reste souvent ouverte d'un jour sur l'autre, et une clé figée à
  /// l'ouverture affichait indéfiniment la progression de la veille.
  String _today = FirestoreService.dayKey(DateTime.now());

  /// Déclenche la bascule au passage de minuit tant que l'écran est affiché.
  Timer? _rolloverTimer;

  @override
  void initState() {
    super.initState();

    // Bascule de journée : minuteur jusqu'à minuit, plus une revérification au
    // retour au premier plan (le minuteur ne tourne pas en veille prolongée).
    WidgetsBinding.instance.addObserver(this);
    _programmerBasculeDeJournee();

    if (_contentInitialized) return;
    _contentInitialized = true;

    _setUpNotifications();

    // Initialiser le contenu des parcours s'il n'existe pas encore dans Firebase
    _firestoreService.checkAndInitializeParcoursContent();
    // Le chemin Métanoïa n'était semé nulle part : sans cela, ses niveaux et
    // ses leçons restaient vides.
    _firestoreService.checkAndInitializeMetanoia();
    // Initialiser les défis s'ils n'existent pas
    _firestoreService.checkAndInitializeChallenges();
    _firestoreService.checkAndInitializeEvents();
    _firestoreService.checkAndInitializeAnnonces();
    _firestoreService.checkAndInitializeFraternity();
    _firestoreService.checkAndInitializeDailyContent();
    // Catalogue de versets : sans lui, le verset du jour ne tournerait pas.
    _firestoreService.checkAndInitializeVersets();
    _firestoreService.checkAndInitializeDailyTasks();
    _firestoreService.checkAndInitializeNeuvaines();
    _firestoreService.checkAndInitializePrayerActivities();
    _firestoreService.checkAndInitializeExamenConscience();
    _firestoreService.checkAndInitializeConfessionContent();
  }

  @override
  void dispose() {
    _rolloverTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _rafraichirJour();
  }

  /// Arme un minuteur sur le prochain minuit (plus une seconde de marge) pour
  /// que le parcours du jour reparte à zéro sans relancer l'application.
  void _programmerBasculeDeJournee() {
    _rolloverTimer?.cancel();
    final maintenant = DateTime.now();
    final minuit = DateTime(maintenant.year, maintenant.month, maintenant.day + 1);
    _rolloverTimer = Timer(
      minuit.difference(maintenant) + const Duration(seconds: 1),
      _rafraichirJour,
    );
  }

  /// Recale [_today] sur la date réelle et réarme le minuteur.
  void _rafraichirJour() {
    if (!mounted) return;
    final jour = FirestoreService.dayKey(DateTime.now());
    if (jour != _today) setState(() => _today = jour);
    _programmerBasculeDeJournee();
  }

  /// Demande l'autorisation, (re)programme les rappels de prière à partir des
  /// horaires enregistrés, puis démarre la veille sur les intentions.
  ///
  /// Les rappels sont reprogrammés à chaque lancement : sans cela, un
  /// utilisateur qui n'ouvre jamais la boîte de dialogue des horaires ne
  /// recevait aucune notification.
  Future<void> _setUpNotifications() async {
    await NotificationService().requestPermissions();

    if (_uid != null) {
      try {
        final times = await _firestoreService.getPrayerTimes(_uid!).first;
        await NotificationService().syncPrayerReminders(times);
      } catch (e) {
        debugPrint("Programmation des rappels impossible : $e");
      }
    }

    await IntentionWatcher().start();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'wb_sunny_outlined':
        return Icons.wb_sunny_outlined;
      case 'menu_book':
        return Icons.menu_book;
      case 'circle_outlined':
        return Icons.circle_outlined;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'pan_tool_outlined':
        return Icons.pan_tool_outlined;
      case 'people_outline':
        return Icons.people_outline;
      case 'self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const PrionsEnsembleScreen(),
          const GrandirDansLaFoiScreen(),
          CommunauteScreen(),
          const MonEspaceScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildVersetDuJour(),
                const SizedBox(height: 20),
                _buildParcours(),
                const SizedBox(height: 20),
                _buildIntention(),
                const SizedBox(height: 20),
                _buildContinuer(),
                const SizedBox(height: 20),
                _buildCarnetSpirituel(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildMenuShortcut(
                        "Bons Plans",
                        Icons.card_giftcard,
                        const Color(0xFFD98E2A),
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BonsPlansScreen())),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildMenuShortcut(
                        "Quiz & Jeux",
                        Icons.sports_esports,
                        const Color(0xFF5B4FC8),
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizJeuxScreen())),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/sunset_bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CurrentUserAvatar(radius: 25),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bonjour", style: TextStyle(color: Colors.black87, fontSize: 14)),
                    Row(
                      children: [
                        Flexible(
                          child: FutureBuilder<DocumentSnapshot?>(
                            future: FirebaseAuth.instance.currentUser != null
                                ? FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get()
                                : Future<DocumentSnapshot?>.value(null),
                            builder: (context, snapshot) {
                              String prenom = "Ami(e)";
                              
                              if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                                final data = snapshot.data!.data() as Map<String, dynamic>?;
                                if (data != null && data.containsKey('fullName') && data['fullName'].toString().isNotEmpty) {
                                  prenom = data['fullName'].toString().split(' ').first;
                                }
                              } else if (FirebaseAuth.instance.currentUser?.displayName != null && FirebaseAuth.instance.currentUser!.displayName!.isNotEmpty) {
                                prenom = FirebaseAuth.instance.currentUser!.displayName!.split(' ').first;
                              }
                              
                              return Text(
                                prenom, 
                                style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text("👋", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Que le Seigneur te bénisse 💛", 
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersetDuJour() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage("assets/mountain_bg.png"),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.2),
            ],
          ),
        ),
        child: StreamBuilder<Map<String, String>>(
          stream: _firestoreService.getVersetDuJour(),
          builder: (context, snapshot) {
            const String titre = "Verset du jour";
            final verset = snapshot.data;
            final String verseText = verset?['content'] ?? versetParDefaut.contenu;
            final String reference = verset?['reference'] ?? versetParDefaut.reference;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.menu_book, color: Colors.orange, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(titre, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 5),
                    _buildBookmarkButton(reference, verseText),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("“", style: TextStyle(color: Colors.orange, fontSize: 40, fontWeight: FontWeight.bold, height: 1)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            verseText,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.4),
                          ),
                          const SizedBox(height: 15),
                          Text(reference, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(String reference, String verseText) {
    if (_uid == null) {
      return const Icon(Icons.bookmark_border, color: Colors.grey);
    }

    return StreamBuilder<List<Favori>>(
      stream: _firestoreService.getUserFavoris(_uid!),
      builder: (context, snapshot) {
        final favoris = snapshot.data ?? [];
        final isFavori = favoris.any((f) => f.type == 'verset' && f.title == reference);

        return GestureDetector(
          onTap: () async {
            final ajoute = await _firestoreService.toggleFavori(
              _uid!,
              Favori(
                id: '',
                title: reference,
                imageUrl: 'assets/mountain_bg.png',
                type: 'verset',
                reference: verseText,
              ),
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ajoute ? "Ajouté à tes favoris ⭐" : "Retiré de tes favoris"),
                backgroundColor: ajoute ? Colors.orange : Colors.grey,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Icon(
            isFavori ? Icons.bookmark : Icons.bookmark_border,
            color: isFavori ? Colors.orange : Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildParcours() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: StreamBuilder<List<DailyTask>>(
        stream: _firestoreService.getDailyTasks(),
        builder: (context, tasksSnapshot) {
          final commonTasks = tasksSnapshot.data ?? [];

          return StreamBuilder<List<DailyTask>>(
            stream: _uid != null
                ? _firestoreService.getCustomDailyTasks(_uid!)
                : Stream.value(<DailyTask>[]),
            builder: (context, customSnapshot) {
              // Les intentions personnelles complètent les étapes communes,
              // à la suite de celles-ci.
              final tasks = <DailyTask>[...commonTasks, ...(customSnapshot.data ?? <DailyTask>[])];

              return StreamBuilder<List<String>>(
                stream: _uid != null
                    ? _firestoreService.getDailyTasksProgress(_uid!, _today)
                    : Stream.value(<String>[]),
                builder: (context, progressSnapshot) {
                  final completedIds = progressSnapshot.data ?? <String>[];
                  final completedCount = tasks.where((t) => completedIds.contains(t.id)).length;
                  final double progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

                  return Column(
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
                          const Expanded(
                            child: Text("Mon parcours aujourd'hui", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 5),
                          Text("${(progress * 100).toInt()} %", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              splashRadius: 20,
                              tooltip: "Ajouter une intention personnelle",
                              icon: const Icon(Icons.add_circle_outline, color: Colors.orange, size: 20),
                              onPressed: () => _showCustomTaskDialog(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (tasksSnapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(color: Colors.orange),
                        )
                      else if (tasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("Aucune étape prévue pour aujourd'hui.", style: TextStyle(color: Colors.grey)),
                        )
                      else
                        ...tasks.asMap().entries.map((entry) {
                          final task = entry.value;
                          final isLast = entry.key == tasks.length - 1;
                          return _buildTaskItem(task, completedIds.contains(task.id), tasks.length, completedCount, isLast: isLast);
                        }),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            foregroundColor: Colors.orange,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _showCustomTaskDialog(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Ajouter mon intention", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Formulaire d'ajout / de modification d'une intention personnelle du
  /// parcours du jour. [task] est renseigné en mode modification.
  Future<void> _showCustomTaskDialog({DailyTask? task}) async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connectez-vous pour ajouter vos intentions."), backgroundColor: Colors.orange),
      );
      return;
    }

    final result = await showDialog<_CustomTaskDraft>(
      context: context,
      builder: (dialogContext) => _CustomTaskDialog(
        task: task,
        iconResolver: _getIconData,
      ),
    );

    if (result == null) return;

    if (task == null) {
      await _firestoreService.addCustomDailyTask(_uid!, result.title, icon: result.icon);
    } else {
      await _firestoreService.updateCustomDailyTask(_uid!, task.id, result.title, icon: result.icon);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(task == null ? "Intention ajoutée à votre parcours." : "Intention modifiée."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteCustomTask(DailyTask task) async {
    if (_uid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer l'intention ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('"${task.title}" sera retirée de votre parcours.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _firestoreService.deleteCustomDailyTask(_uid!, task.id, _today);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Intention supprimée."), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _toggleTask(DailyTask task, bool completed, int totalTasks, int completedCount) async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connectez-vous pour sauvegarder votre parcours."), backgroundColor: Colors.orange),
      );
      return;
    }

    await _firestoreService.toggleDailyTask(_uid!, _today, task.id, !completed);

    // Quand toutes les étapes du jour sont validées, on enregistre le jour de prière.
    if (!completed && totalTasks > 0 && completedCount + 1 == totalTasks) {
      final valide = await _firestoreService.validerJourDePriere(_uid!);
      if (valide && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parcours du jour terminé ! 🙌"), backgroundColor: Colors.green),
        );
      }
    }
  }

  Widget _buildTaskItem(DailyTask task, bool completed, int totalTasks, int completedCount, {bool isLast = false}) {
    final hasDetail = task.action.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 15, top: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleTask(task, completed, totalTasks, completedCount),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                completed ? Icons.check_circle : Icons.circle_outlined,
                key: ValueKey<bool>(completed),
                color: completed ? Colors.green : Colors.grey.shade400,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (task.action == 'evangile') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EvangileDuJourScreen()));
                } else if (task.action == 'chapelet') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChapeletGuideScreen()));
                } else {
                  _toggleTask(task, completed, totalTasks, completedCount);
                }
              },
              // Appui long : raccourci vers la modification de ses propres
              // intentions.
              onLongPress: task.isCustom ? () => _showCustomTaskDialog(task: task) : null,
              child: Row(
                children: [
                  Icon(_getIconData(task.iconName), color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: completed ? Colors.grey : const Color(0xFF0F172A),
                        fontWeight: completed ? FontWeight.normal : FontWeight.bold,
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (hasDetail)
                    const Icon(Icons.chevron_right, color: Colors.orange, size: 18),
                ],
              ),
            ),
          ),
          if (task.isCustom)
            SizedBox(
              width: 28,
              height: 28,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                tooltip: "Modifier ou supprimer",
                icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade500),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showCustomTaskDialog(task: task);
                  } else if (value == 'delete') {
                    _deleteCustomTask(task);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                        SizedBox(width: 10),
                        Text("Modifier"),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Supprimer", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIntention() {
    return StreamBuilder<List<Intention>>(
      stream: FirestoreService().getIntentions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

        final intention = snapshot.data!.first;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people, color: Colors.orange, size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(child: Text("Intention communautaire", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(intention.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15)),
                    const SizedBox(height: 5),
                    Text("${intention.count} personnes prient déjà", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 15),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await FirestoreService().incrementIntentionCount(intention.id);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Merci pour votre prière 🙏'), backgroundColor: Colors.orange),
                          );
                        },
                        icon: const Icon(Icons.pan_tool_outlined, color: Colors.white, size: 16),
                        label: const Text("Je prie aussi", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Image.asset("assets/hands_heart.png", height: 100),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildContinuer() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _firestoreService.getCurrentParcours(user.uid),
      builder: (context, progressSnapshot) {
        final current = progressSnapshot.data;

        return StreamBuilder<List<ParcoursContent>>(
          stream: _firestoreService.getAllParcours(),
          builder: (context, parcoursSnapshot) {
            final parcours = parcoursSnapshot.data ?? [];

            String title = "Découvrir les parcours";
            double percentage = 0.0;
            String buttonText = "Commencer >";
            bool hasProgress = false;
            String? targetId;

            if (current != null && parcours.isNotEmpty) {
              final id = current['parcoursId'] as String;
              final match = parcours.where((p) => p.id == id);

              if (match.isNotEmpty) {
                final parcoursEnCours = match.first;
                final completed = (current['completedDays'] ?? 0) as int;
                final total = parcoursEnCours.lessons.length;

                title = parcoursEnCours.title;
                percentage = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
                buttonText = "Reprendre >";
                hasProgress = true;
                targetId = parcoursEnCours.id;
              }
            }

            return _buildContinuerCard(title, percentage, buttonText, hasProgress, targetId);
          },
        );
      },
    );
  }

  Widget _buildContinuerCard(
    String title,
    double percentage,
    String buttonText,
    bool hasProgress,
    String? targetId,
  ) {
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flag, color: Colors.deepPurple, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(hasProgress ? "Continuer mon parcours" : "Commencer un parcours", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16)),
                        if (hasProgress) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: LinearProgressIndicator(
                                    value: percentage,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text("${(percentage * 100).toInt()} %", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 5),
                          const Text("Lance-toi dans l'aventure !", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B4FC8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // On reprend le parcours réellement en cours ; sans
                        // progression, on ouvre le catalogue des parcours.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => targetId != null
                                ? ParcoursDetailScreen(parcoursId: targetId)
                                : const MetanoiaScreen(),
                          ),
                        );
                      },
                      child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  /// Carnet spirituel : déplacé de « Mon Espace » vers l'accueil pour que les
  /// rhémas, prières exaucées et méditations soient visibles dès l'ouverture.
  Widget _buildCarnetSpirituel() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book, color: Colors.orange, size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Mon Carnet Spirituel",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Ce que Dieu me dit au fil du temps",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          StreamBuilder<Map<String, int>>(
            stream: _uid != null
                ? _firestoreService.getUserCarnetStats(_uid!)
                : Stream.value(const {'rhemas': 0, 'exaucees': 0, 'meditations': 0}),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? const {'rhemas': 0, 'exaucees': 0, 'meditations': 0};
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCarnetStat("${stats['rhemas']}", "Rhémas"),
                  _buildCarnetStat("${stats['exaucees']}", "Prières exaucées"),
                  _buildCarnetStat("${stats['meditations']}", "Méditations"),
                ],
              );
            },
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CarnetSpirituelScreen()),
              ),
              child: const Text(
                "Ouvrir mon carnet",
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarnetStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: AppBottomNavBar.items,
    );
  }

  Widget _buildMenuShortcut(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
            ),
          ],
        ),
      ),
    );
  }
}


/// Saisie retournée par [_CustomTaskDialog].
class _CustomTaskDraft {
  final String title;
  final String icon;

  const _CustomTaskDraft(this.title, this.icon);
}

/// Boîte de dialogue de saisie d'une intention personnelle. Elle est isolée
/// dans son propre widget pour que le [TextEditingController] soit libéré à la
/// disparition effective de la route, et non pendant son animation de sortie.
class _CustomTaskDialog extends StatefulWidget {
  final DailyTask? task;
  final IconData Function(String) iconResolver;

  const _CustomTaskDialog({Key? key, this.task, required this.iconResolver}) : super(key: key);

  @override
  State<_CustomTaskDialog> createState() => _CustomTaskDialogState();
}

class _CustomTaskDialogState extends State<_CustomTaskDialog> {
  static const List<String> _icons = [
    'favorite_border',
    'wb_sunny_outlined',
    'menu_book',
    'circle_outlined',
    'nightlight_round',
    'pan_tool_outlined',
    'people_outline',
    'self_improvement',
  ];

  late final TextEditingController _controller = TextEditingController(text: widget.task?.title ?? '');
  late String _selectedIcon = widget.task?.iconName ?? 'favorite_border';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdition = widget.task != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEdition ? "Modifier l'intention" : "Nouvelle intention",
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 18),
      ),
      // Le clavier réduit fortement la hauteur disponible : le contenu doit
      // pouvoir défiler plutôt que déborder.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 60,
              decoration: InputDecoration(
                hintText: "Ex : Prier pour ma famille",
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text("Icône", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((name) {
                final isSelected = name == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = name),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? Colors.orange : Colors.transparent),
                    ),
                    child: Icon(
                      widget.iconResolver(name),
                      size: 20,
                      color: isSelected ? Colors.orange : Colors.grey.shade600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isEmpty) return;
            Navigator.pop(context, _CustomTaskDraft(title, _selectedIcon));
          },
          child: Text(isEdition ? "Enregistrer" : "Ajouter"),
        ),
      ],
    );
  }
}

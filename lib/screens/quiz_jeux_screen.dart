import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../components/app_bottom_nav_bar.dart';
import '../components/user_avatar.dart';
import 'quiz_screen.dart';
import 'quiz_list_screen.dart';
import '../models/quiz_mode_model.dart';

class QuizJeuxScreen extends StatefulWidget {
  const QuizJeuxScreen({Key? key}) : super(key: key);

  @override
  State<QuizJeuxScreen> createState() => _QuizJeuxScreenState();
}

class _QuizJeuxScreenState extends State<QuizJeuxScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  _buildDefisDuJour(),
                  const SizedBox(height: 25),
                  _buildCategoriesQuiz(),
                  const SizedBox(height: 25),
                  _buildJeux(),
                  const SizedBox(height: 25),
                  _buildClassement(),
                  const SizedBox(height: 25),
                  _buildRecompenses(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
            width: MediaQuery.of(context).size.width * 0.8,
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/sunset_bg.jpg"), // Open Bible with cross bg
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFF8F9FA).withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Quiz & Jeux",
                          style: TextStyle(
                            fontSize: 24, // Adjusted slightly to fit with back button
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.notifications_none, size: 20, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.emoji_events_outlined, size: 20, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 3,
                  margin: const EdgeInsets.only(top: 8, bottom: 15),
                  color: Colors.orange,
                ),
                const SizedBox(
                  width: 250,
                  child: Text(
                    "Apprends en t'amusant et grandis dans la foi !",
                    style: TextStyle(fontSize: 12, color: Color(0xFF0F172A), height: 1.4),
                  ),
                ),
                const SizedBox(height: 30),
                // Stats Banner
                StreamBuilder<Map<String, dynamic>>(
                  stream: _uid != null ? _firestoreService.getUserGamificationStats(_uid!) : Stream.value({'level':1, 'title':'Chercheur', 'points':0, 'streak':0}),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ?? {'level':1, 'title':'Chercheur', 'points':0, 'streak':0};
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatTopItem(Icons.emoji_events, Colors.orange, "Niveau", "${stats['level']}", "${stats['title']}"),
                          Container(width: 1, height: 40, color: Colors.white24),
                          _buildStatTopItem(Icons.star, Colors.orange, "Points", "${stats['points']}", "Total cumulé", isCenter: true),
                          Container(width: 1, height: 40, color: Colors.white24),
                          _buildStatTopItem(Icons.local_fire_department, Colors.orange, "Série actuelle", "${stats['streak']}", "jours consécutifs"),
                        ],
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTopItem(IconData icon, Color iconColor, String title, String value, String subtitle, {bool isCenter = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 9)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(color: isCenter ? Colors.greenAccent : Colors.white54, fontSize: 8)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {String actionText = "Voir tout"}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  actionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF0F172A)),
                ),
              ),
              const Icon(Icons.chevron_right, size: 14, color: Color(0xFF0F172A)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefisDuJour() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Défis du jour"),
        const SizedBox(height: 15),
        StreamBuilder<Map<String, dynamic>?>(
          stream: _firestoreService.getDailyChallenge(),
          builder: (context, snapshot) {
            final data = snapshot.data ?? {
              'title': "Connais-tu bien\nl'Évangile de Jean ?",
              'description': "Réponds à 5 questions\net gagne 50 points !",
              'points': 50,
            };
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: IntrinsicHeight(
                child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                                child: const Icon(Icons.track_changes, color: Colors.orange, size: 16),
                              ),
                              const SizedBox(width: 8),
                              const Text("DÉFI DU JOUR", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A), height: 1.2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['description'],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          StreamBuilder<Map<String, dynamic>>(
                            stream: _uid != null ? _firestoreService.getUserGamificationStats(_uid!) : Stream.value({}),
                            builder: (context, statsSnapshot) {
                              final now = DateTime.now();
                              final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                              final lastPlayed = statsSnapshot.data?['lastDailyChallengeDate'] ?? '';
                              final hasPlayedToday = lastPlayed == todayStr;

                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasPlayedToday ? Colors.grey : const Color(0xFF0F172A),
                                  minimumSize: const Size(100, 25),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: hasPlayedToday ? null : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizScreen(
                                        quizId: 'defi_du_jour',
                                        pointsToWin: data['points'] ?? 50,
                                        title: "Défi du jour",
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(hasPlayedToday ? "Déjà complété" : "Commencer", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                    if (!hasPlayedToday) const SizedBox(width: 4),
                                    if (!hasPlayedToday) const Icon(Icons.chevron_right, size: 14, color: Colors.white),
                                  ],
                                ),
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                        child: Image.asset("assets/sunset_bg.jpg", fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          children: [
                            Text("${data['points']}", style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12)),
                            const Text("points", style: TextStyle(color: Colors.grey, fontSize: 8)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildCategoriesQuiz() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Catégories de quiz", actionText: "Voir toutes"),
        const SizedBox(height: 15),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestoreService.getQuizCategories(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(height: 90, child: Center(child: CircularProgressIndicator()));
            }
            final categories = snapshot.data!;

            return StreamBuilder<Map<String, int>>(
              stream: _firestoreService.getQuizCountsByCategory(),
              builder: (context, countsSnapshot) {
                final counts = countsSnapshot.data ?? const <String, int>{};

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final title = cat['title'] ?? '';
                      final n = counts[title] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: _buildCategorieCard(
                          context,
                          _iconeCategorie(cat),
                          Color(cat['color']),
                          title,
                          n == 0 ? "Bientôt" : "$n quiz",
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          }
        ),
      ],
    );
  }

  /// Icône d'une catégorie. On lit d'abord le nom d'icône ; les catégories
  /// créées par les anciennes versions ne portent qu'un code hexadécimal, on
  /// continue de le traduire pour elles.
  IconData _iconeCategorie(Map<String, dynamic> categorie) {
    switch ((categorie['icon'] ?? '').toString()) {
      case 'menu_book':
        return Icons.menu_book;
      case 'church_outlined':
        return Icons.church_outlined;
      case 'person_outline':
        return Icons.person_outline;
      case 'eco_outlined':
        return Icons.eco_outlined;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'self_improvement':
        return Icons.self_improvement;
    }

    switch (categorie['iconCode']) {
      case 0xe3eb:
        return Icons.menu_book;
      case 0xeff1:
        return Icons.church_outlined;
      case 0xe491:
        return Icons.person_outline;
      case 0xef26:
        return Icons.eco_outlined;
      default:
        return Icons.category;
    }
  }

  Widget _buildCategorieCard(BuildContext context, IconData icon, Color color, String title, String subtitle) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizListScreen(
              categoryTitle: title,
              categoryColor: color,
              categoryIcon: icon,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 8, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildJeux() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Jeux"),
        const SizedBox(height: 15),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestoreService.getGamesList(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
            }
            final games = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: games.map((game) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: _buildJeuCard(
                      game['img'] ?? 'assets/sunset_bg.jpg',
                      game['title'] ?? '',
                      game['desc'] ?? '',
                      game['badge'] ?? '',
                      Color(game['badgeColor'] ?? 0xFF0F172A),
                      onTap: () => _ouvrirJeu(game),
                    ),
                  );
                }).toList(),
              ),
            );
          }
        ),
      ],
    );
  }

  /// Un jeu n'a pas sa propre banque de questions : il applique sa règle aux
  /// quiz de la catégorie choisie. Toutes les catégories sont donc jouables
  /// dans les trois jeux.
  void _ouvrirJeu(Map<String, dynamic> jeu) {
    final mode = quizModeDepuisNom(jeu['mode']?.toString());
    final titreJeu = (jeu['title'] ?? 'Jeu').toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titreJeu,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Text(mode.regle, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
                const SizedBox(height: 20),
                const Text(
                  "Choisis une catégorie",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _firestoreService.getQuizCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                      );
                    }

                    final categories = snapshot.data!;

                    return StreamBuilder<Map<String, int>>(
                      stream: _firestoreService.getQuizCountsByCategory(),
                      builder: (context, countsSnapshot) {
                        final counts = countsSnapshot.data ?? const <String, int>{};

                        return Column(
                          children: categories.map((cat) {
                            final titre = (cat['title'] ?? '').toString();
                            final nombre = counts[titre] ?? 0;
                            final couleur = Color(cat['color'] ?? 0xFF5B4FC8);
                            final icone = _iconeCategorie(cat);
                            final disponible = nombre > 0;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: couleur.withOpacity(disponible ? 0.12 : 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icone, color: disponible ? couleur : Colors.grey.shade400, size: 20),
                              ),
                              title: Text(
                                titre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: disponible ? const Color(0xFF0F172A) : Colors.grey,
                                ),
                              ),
                              subtitle: Text(
                                disponible ? "$nombre quiz" : "Bientôt",
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: disponible ? Colors.grey : Colors.grey.shade300,
                              ),
                              onTap: !disponible
                                  ? null
                                  : () {
                                      Navigator.pop(sheetContext);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => QuizListScreen(
                                            categoryTitle: titre,
                                            categoryColor: couleur,
                                            categoryIcon: icone,
                                            mode: mode,
                                            gameTitle: titreJeu,
                                          ),
                                        ),
                                      );
                                    },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJeuCard(String img, String title, String desc, String badge, Color badgeColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            child: Image.asset(img, height: 90, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 90, color: Colors.grey[200])),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(fontSize: 9, color: Colors.grey, height: 1.3)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF0F172A), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildClassement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Ton classement", actionText: "Voir le classement"),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              StreamBuilder<Map<String, dynamic>>(
                stream: _uid != null ? _firestoreService.getUserGamificationStats(_uid!) : Stream.value({'points': 0, 'title': 'Chercheur'}),
                builder: (context, snapshot) {
                  final points = (snapshot.data?['points'] ?? 0) as int;
                  final titre = (snapshot.data?['title'] ?? 'Chercheur').toString();

                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _firestoreService.getLeaderboard(),
                    builder: (context, boardSnapshot) {
                      // Rang réel : nombre de joueurs devant toi, + 1.
                      final players = boardSnapshot.data ?? [];
                      final devant = players.where((p) => ((p['points'] ?? 0) as int) > points).length;
                      final rang = players.isEmpty ? null : devant + 1;

                      return Row(
                        children: [
                          const CurrentUserAvatar(radius: 18),
                          const SizedBox(width: 10),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(
                              rang?.toString() ?? "-",
                              style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Toi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                                Text("$points points", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                points == 0 ? "Nouveau" : titre,
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.emoji_events, color: Colors.orange, size: 16),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                }
              ),
              const SizedBox(height: 15),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 15),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.getLeaderboard(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text("Aucun classement pour le moment.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    );
                  }
                  
                  final players = snapshot.data!;
                  return Column(
                    children: List.generate(players.length > 5 ? 5 : players.length, (index) {
                      final player = players[index];
                      Color iconColor = Colors.grey.shade400;
                      if (index == 0) iconColor = Colors.amber;
                      else if (index == 1) iconColor = Colors.grey.shade400;
                      else if (index == 2) iconColor = Colors.brown.shade300;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildClassementItem(
                          "${index + 1}", 
                          player['name'] ?? 'Joueur inconnu', 
                          "${player['points'] ?? 0} points", 
                          iconColor,
                          avatar: player['avatar']
                        ),
                      );
                    }),
                  );
                }
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassementItem(String rank, String name, String points, Color iconColor, {String? avatar}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(rank, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        UserAvatar(imageReference: avatar, radius: 14),
        const SizedBox(width: 10),
        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A)))),
        Text(points, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(width: 15),
        Icon(Icons.emoji_events, color: iconColor, size: 16),
      ],
    );
  }

  /// Paliers de récompense, calculés à partir des points réellement cumulés
  /// par l'utilisateur (`gamification.points`).
  static const List<Map<String, dynamic>> _paliersRecompenses = [
    {'points': 100, 'label': "Badge Chercheur"},
    {'points': 500, 'label': "Badge Disciple"},
    {'points': 1000, 'label': "Badge Témoin"},
    {'points': 2500, 'label': "Badge Apôtre"},
    {'points': 5000, 'label': "Badge Lumière des Nations"},
  ];

  void _showRecompenses() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StreamBuilder<Map<String, dynamic>>(
          stream: _uid != null
              ? _firestoreService.getUserGamificationStats(_uid!)
              : Stream.value({'points': 0}),
          builder: (context, snapshot) {
            final int points = (snapshot.data?['points'] ?? 0) as int;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mes récompenses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 5),
                  Text("$points points cumulés", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ..._paliersRecompenses.map((palier) {
                    final int seuil = palier['points'] as int;
                    final bool debloque = points >= seuil;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        debloque ? Icons.emoji_events : Icons.lock_outline,
                        color: debloque ? Colors.amber : Colors.grey.shade400,
                      ),
                      title: Text(
                        palier['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: debloque ? const Color(0xFF0F172A) : Colors.grey,
                        ),
                      ),
                      subtitle: Text(
                        debloque ? "Débloqué 🎉" : "Encore ${seuil - points} points",
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecompenses() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.orange, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Gagne des récompenses !", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 4),
                Text("Cumule des points, garde ta série et débloque des récompenses exclusives.", style: TextStyle(color: Colors.white, fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              minimumSize: const Size(100, 25),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _showRecompenses,
            child: const Text("Voir les récompenses >", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Quiz & Jeux s'ouvre depuis l'accueil : c'est cet onglet qui reste actif.
  Widget _buildBottomNav() => const AppBottomNavBar(currentIndex: 0);
}

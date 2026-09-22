import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/versets_catalogue.dart';
import '../models/metanoia_model.dart';
import '../models/parcours_content_model.dart';
import '../models/objectif_model.dart';
import 'metanoia_screen.dart';
import 'parcours_detail_screen.dart';
import 'all_objectifs_screen.dart';
import 'all_favoris_screen.dart';

class GrandirDansLaFoiScreen extends StatefulWidget {
  const GrandirDansLaFoiScreen({Key? key}) : super(key: key);

  @override
  State<GrandirDansLaFoiScreen> createState() => _GrandirDansLaFoiScreenState();
}

class _GrandirDansLaFoiScreenState extends State<GrandirDansLaFoiScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController _searchController = TextEditingController();

  String _ongletActif = _ongletTous;
  String _searchQuery = '';

  static const String _ongletTous = "Tous";
  static const String _ongletNouveautes = "Nouveautés";

  /// Onglets réellement utiles : « Tous », « Nouveautés » s'il existe au moins
  /// un parcours récent, puis une entrée par catégorie présente en base. Une
  /// catégorie ajoutée depuis la console apparaît donc d'elle-même, et aucun
  /// onglet ne peut plus ouvrir sur une liste vide.
  List<String> _ongletsPour(List<ParcoursContent> parcours) {
    final onglets = <String>[_ongletTous];
    if (parcours.any((p) => p.isNew)) onglets.add(_ongletNouveautes);

    final categories = parcours
        .map((p) => p.category.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    onglets.addAll(categories);
    return onglets;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'landscape':
        return Icons.landscape;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'add':
        return Icons.add;
      case 'menu_book':
        return Icons.menu_book;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'shield_outlined':
        return Icons.shield_outlined;
      case 'people_outline':
        return Icons.people_outline;
      case 'pan_tool_outlined':
        return Icons.pan_tool_outlined;
      default:
        return Icons.track_changes;
    }
  }

  Color _colorFor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.orange;
    }
  }

  /// Applique l'onglet actif puis la recherche libre (titre, sous-titre, thème).
  List<ParcoursContent> _applyFilters(List<ParcoursContent> parcours) {
    var filtered = parcours.where((p) {
      if (_ongletActif == _ongletTous) return true;
      if (_ongletActif == _ongletNouveautes) return p.isNew;
      return p.category.toLowerCase() == _ongletActif.toLowerCase();
    });

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
          p.title.toLowerCase().contains(query) ||
          p.subtitle.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query));
    }

    return filtered.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        // Un seul flux de parcours alimente les onglets, la liste et les
        // thèmes : ils ne peuvent plus se contredire, et la page n'ouvre plus
        // deux écoutes concurrentes sur la même collection.
        child: StreamBuilder<List<ParcoursContent>>(
          stream: _firestoreService.getAllParcours(),
          builder: (context, snapshot) {
            final enChargement = snapshot.connectionState == ConnectionState.waiting;
            final parcours = snapshot.data ?? const <ParcoursContent>[];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  const SizedBox(height: 15),
                  _buildTabs(_ongletsPour(parcours)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContinueCard(),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Parcours recommandés pour toi",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _ongletActif = _ongletTous;
                                });
                              },
                              child: const Text("Voir tout >", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildParcoursRecommandes(parcours, enChargement),
                        const SizedBox(height: 25),
                        const Text("Thèmes populaires", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                        const SizedBox(height: 15),
                        _buildThemesPopulaires(parcours, enChargement),
                        const SizedBox(height: 25),
                        _buildQuoteCard(),
                        const SizedBox(height: 25),
                        _buildObjectifCard(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Grandir dans la foi", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                SizedBox(height: 5),
                Text("Découvre des parcours pour nourrir ton âme.", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.orange),
              tooltip: "Mes favoris",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AllFavorisScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _searchQuery = value.trim()),
          decoration: InputDecoration(
            hintText: "Rechercher un parcours, un thème...",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(List<String> onglets) {
    // L'onglet actif peut disparaître si sa catégorie n'a plus de parcours :
    // on retombe alors sur « Tous » plutôt que d'afficher une liste vide.
    final actif = onglets.contains(_ongletActif) ? _ongletActif : _ongletTous;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          for (final onglet in onglets) _buildTabItem(onglet, onglet == actif),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _ongletActif = title),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueCard() {
    if (_uid == null) return const SizedBox();

    return StreamBuilder<List<MetanoiaLevel>>(
      stream: _firestoreService.getMetanoiaLevels(),
      builder: (context, levelsSnapshot) {
        if (!levelsSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        final levels = levelsSnapshot.data!;

        return StreamBuilder<List<String>>(
          stream: _firestoreService.getUserMetanoiaProgress(_uid!),
          builder: (context, progressSnapshot) {
            if (!progressSnapshot.hasData) return const Center(child: CircularProgressIndicator());
            final completedLessonIds = progressSnapshot.data!;

            int totalLessons = levels.fold(0, (sum, level) => sum + level.totalLessons);
            int completedCount = completedLessonIds.length;
            double globalProgress = totalLessons > 0 ? completedCount / totalLessons : 0.0;
            int percentage = (globalProgress * 100).toInt();

            int currentLevelOrder = 1;
            int lessonsSum = 0;
            for (var level in levels) {
              lessonsSum += level.totalLessons;
              if (completedCount < lessonsSum) {
                currentLevelOrder = level.order;
                break;
              }
              if (level.order == levels.length) {
                currentLevelOrder = level.order;
              }
            }

            // Le niveau en cours porte son propre titre, son sous-titre et son
            // visuel : la carte les affiche au lieu de les redire en dur.
            final niveauActuel = levels.firstWhere(
              (l) => l.order == currentLevelOrder,
              orElse: () => levels.first,
            );
            final titreNiveau = niveauActuel.title.isNotEmpty
                ? niveauActuel.title
                : "Métanoia - Niveau $currentLevelOrder";

            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(niveauActuel.imageAsset, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image))),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titreNiveau, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16)),
                        const SizedBox(height: 5),
                        Text(
                          niveauActuel.subtitle.isNotEmpty ? niveauActuel.subtitle : "Poursuis ton chemin de conversion.",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: globalProgress,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text("$percentage %", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MetanoiaScreen()),
                        ).then((_) => setState(() {})); // trigger rebuild if needed
                      },
                      child: const Text("Reprendre", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildParcoursRecommandes(List<ParcoursContent> tousLesParcours, bool enChargement) {
    if (enChargement) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    final parcours = _applyFilters(tousLesParcours);

    if (parcours.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            _searchQuery.isNotEmpty
                ? "Aucun parcours ne correspond à « $_searchQuery »."
                : "Aucun parcours dans cette catégorie pour le moment.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < parcours.length; i++) ...[
            if (i > 0) const SizedBox(width: 15),
            _buildParcoursCard(
              parcours[i].title,
              parcours[i].subtitle,
              parcours[i].durationLabel,
              _iconFor(parcours[i].iconName),
              _colorFor(parcours[i].colorHex),
              isNew: parcours[i].isNew,
              imageAsset: parcours[i].imageAsset,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParcoursDetailScreen(parcoursId: parcours[i].id),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParcoursCard(String title, String subtitle, String duration, IconData icon, Color iconColor, {bool isNew = false, String? imageAsset, VoidCallback? onTap}) {
    return Container(
      width: 220,
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(imageAsset ?? "assets/mountain_bg.png", height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 120, color: Colors.grey[300])),
              ),
              if (isNew)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.star, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text("Nouveau", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: -20,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 14),
                    const SizedBox(width: 5),
                    Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: onTap ?? () {},
                    child: const Text("Commencer"),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Habillage des thèmes. Un thème absent de cette table reste affiché, avec
  /// une apparence neutre : la liste vient des données, pas de cette map.
  static final Map<String, List<dynamic>> _themeStyles = {
    'amour de dieu': [Icons.favorite_border, Colors.red],
    'prière': [Icons.pan_tool_outlined, Colors.orange],
    'foi': [Icons.menu_book, Colors.purple],
    'fondamentaux': [Icons.menu_book, Colors.purple],
    'vie chrétienne': [Icons.people_outline, Colors.blue],
    'spiritualité': [Icons.self_improvement, Colors.teal],
    'combat spirituel': [Icons.shield_outlined, Colors.green],
  };

  /// Les thèmes proposés sont les catégories réellement portées par les
  /// parcours en base, et non une liste figée.
  Widget _buildThemesPopulaires(List<ParcoursContent> parcours, bool enChargement) {
    if (enChargement) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    // Chaque thème emprunte l'icône et la couleur du premier parcours qui le
    // porte : une catégorie créée en base est stylée sans passer par le code.
    final premierParcoursParTheme = <String, ParcoursContent>{};
    for (final p in parcours) {
      final categorie = p.category.trim();
      if (categorie.isEmpty) continue;
      premierParcoursParTheme.putIfAbsent(categorie, () => p);
    }

    if (premierParcoursParTheme.isEmpty) {
      return const Text(
        "Aucun thème pour le moment.",
        style: TextStyle(color: Colors.grey, fontSize: 13),
      );
    }

    final themes = premierParcoursParTheme.keys.toList()..sort();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: themes.map((theme) {
        final source = premierParcoursParTheme[theme]!;
        final repli = _themeStyles[theme.toLowerCase()];

        final icone = source.iconName.isNotEmpty
            ? _iconFor(source.iconName)
            : (repli != null ? repli[0] as IconData : Icons.local_offer_outlined);
        final couleur = source.colorHex.isNotEmpty
            ? _colorFor(source.colorHex)
            : (repli != null ? repli[1] as Color : Colors.blueGrey);

        return _buildThemeChip(theme, icone, couleur, couleur.withOpacity(0.1));
      }).toList(),
    );
  }

  /// Toucher un thème remplit la recherche : les parcours correspondants
  /// remontent immédiatement dans la liste ci-dessus.
  void _searchTheme(String label) {
    _searchController.text = label;
    setState(() {
      _searchQuery = label;
      _ongletActif = _ongletTous;
    });
  }

  Widget _buildThemeChip(String label, IconData icon, Color iconColor, Color bgColor) {
    final bool isActive = _searchQuery.toLowerCase() == label.toLowerCase();

    return GestureDetector(
      onTap: () => isActive ? _searchTheme('') : _searchTheme(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? Border.all(color: iconColor, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage("assets/sunset_bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white.withOpacity(0.85),
        ),
        child: StreamBuilder<Map<String, String>>(
          stream: _firestoreService.getVersetDuJour(),
          builder: (context, snapshot) {
            final verset = snapshot.data;
            final String verseText = verset?['content'] ?? versetParDefaut.contenu;
            final String reference = verset?['reference'] ?? versetParDefaut.reference;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("“", style: TextStyle(color: Colors.orange, fontSize: 40, fontWeight: FontWeight.bold, height: 1)),
                const SizedBox(height: 5),
                Text(
                  verseText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A), height: 1.4),
                ),
                const SizedBox(height: 15),
                Text(reference, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Carte du bas : tant que l'utilisateur n'a aucun objectif, elle invite à
  /// en fixer un ; dès qu'il en a, elle montre celui qui avance le mieux avec
  /// sa progression réelle.
  Widget _buildObjectifCard() {
    if (_uid == null) return _buildObjectifInvitation();

    return StreamBuilder<List<Objectif>>(
      stream: _firestoreService.getUserObjectifs(_uid!),
      builder: (context, snapshot) {
        final objectifs = snapshot.data ?? const <Objectif>[];
        if (objectifs.isEmpty) return _buildObjectifInvitation();

        final objectif = objectifs.reduce((a, b) => b.progress > a.progress ? b : a);
        final couleur = _colorFor(objectif.colorHex);
        final pourcentage = (objectif.progress.clamp(0.0, 1.0) * 100).round();

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: couleur.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: couleur.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(_iconFor(objectif.icon), color: couleur, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Mon objectif en cours", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Text(
                          objectif.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text("$pourcentage %", style: TextStyle(fontWeight: FontWeight.bold, color: couleur, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: objectif.progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(couleur),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: couleur,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AllObjectifsScreen()),
                  ),
                  child: Text(
                    objectifs.length > 1 ? "Mes ${objectifs.length} objectifs >" : "Voir mon objectif >",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildObjectifInvitation() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Fixe un objectif spirituel", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15)),
                SizedBox(height: 5),
                Text("Choisis un domaine et grandis chaque jour.", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AllObjectifsScreen()),
              ),
              child: const Text("Définir mon objectif >", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/event_model.dart';
import '../models/resource_model.dart';
import '../models/bon_plan_model.dart';
import '../components/app_bottom_nav_bar.dart';
import 'adresses_list_screen.dart';
import 'all_events_screen.dart';

class BonsPlansScreen extends StatefulWidget {
  const BonsPlansScreen({Key? key}) : super(key: key);

  @override
  State<BonsPlansScreen> createState() => _BonsPlansScreenState();
}

class _BonsPlansScreenState extends State<BonsPlansScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _firestoreService.checkAndInitializeBonsPlansAndAddresses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(List<String> fields) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return fields.any((f) => f.toLowerCase().contains(query));
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
                  _buildEvenements(),
                  const SizedBox(height: 25),
                  _buildAdressesUtiles(),
                  const SizedBox(height: 25),
                  _buildRessourcesRecommandees(),
                  const SizedBox(height: 25),
                  _buildBonsPlansMoment(),
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
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 250,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/sunset_bg.jpg"),
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
                          "Bons Plans",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
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
                    "Découvre des lieux, ressources et opportunités pour grandir et vivre ta foi au quotidien.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF0F172A), height: 1.4),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _searchQuery = value.trim()),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      hintText: "Que recherches-tu aujourd'hui ?",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Titre de section. Le lien d'action n'est affiché que si une destination
  /// existe réellement, pour ne pas laisser de faux « Voir tout ».
  Widget _buildSectionTitle(String title, {String actionText = "Voir tout", VoidCallback? onAction}) {
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
        if (onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(actionText, style: const TextStyle(fontSize: 10, color: Color(0xFF0F172A))),
                const Icon(Icons.chevron_right, size: 14, color: Color(0xFF0F172A)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEvenements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          "Événements autour de toi",
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AllEventsScreen()),
          ),
        ),
        const SizedBox(height: 15),
        StreamBuilder<List<AppEvent>>(
          stream: _firestoreService.getEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Aucun événement pour le moment.", style: TextStyle(color: Colors.grey));
            }
            final events = snapshot.data!
                .where((e) => _matchesSearch([e.title, e.location, e.badge]))
                .toList();
            if (events.isEmpty) {
              return const Text("Aucun événement ne correspond à ta recherche.", style: TextStyle(color: Colors.grey, fontSize: 12));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: events.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: _buildEventCard(
                      event.imageUrl.isNotEmpty ? event.imageUrl : "assets/sunset_bg.jpg",
                      event.day,
                      event.month,
                      event.badge,
                      event.title,
                      event.location,
                      event.time,
                    ),
                  );
                }).toList(),
              ),
            );
          }
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF0F172A), shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
          ],
        ),
      ],
    );
  }

  Widget _buildEventCard(String img, String day, String month, String badge, String title, String location, String time) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                child: Image.asset(img, height: 100, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 100, color: Colors.grey[200])),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(5)),
                  child: Column(
                    children: [
                      Text(day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(month, style: const TextStyle(color: Colors.white, fontSize: 8)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(5)),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 10, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location, style: const TextStyle(fontSize: 9, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 10, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(time, style: const TextStyle(fontSize: 9, color: Colors.grey))),
                    const Icon(Icons.bookmark_border, size: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Catégories d'adresses. Le compteur affiché vient du nombre réel de
  /// documents `addresses` portant cette catégorie.
  static const List<Map<String, dynamic>> _categoriesAdresses = [
    {'category': "Paroisses", 'icon': Icons.church_outlined, 'title': "Paroisses\net églises", 'unit': "lieu"},
    {'category': "Communautés", 'icon': Icons.people_outline, 'title': "Communautés\net mouvements", 'unit': "groupe"},
    {'category': "Librairies", 'icon': Icons.menu_book, 'title': "Librairies\nchrétiennes", 'unit': "adresse"},
    {'category': "Œuvres", 'icon': Icons.volunteer_activism_outlined, 'title': "Œuvres\net associations", 'unit': "œuvre"},
    {'category': "Sacrements", 'icon': Icons.add_moderator_outlined, 'title': "Sacrements\net services", 'unit': "service"},
  ];

  Widget _buildAdressesUtiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Adresses utiles", actionText: "Voir toutes"),
        const SizedBox(height: 15),
        StreamBuilder<Map<String, int>>(
          stream: _firestoreService.getAddressCountsByCategory(),
          builder: (context, snapshot) {
            final counts = snapshot.data ?? const <String, int>{};

            final visibles = _categoriesAdresses
                .where((c) => _matchesSearch([c['category'] as String, c['title'] as String]))
                .toList();

            if (visibles.isEmpty) {
              return const Text("Aucune catégorie ne correspond à ta recherche.", style: TextStyle(color: Colors.grey, fontSize: 12));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < visibles.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdressesListScreen(category: visibles[i]['category'] as String),
                        ),
                      ),
                      child: _buildAdresseIcon(
                        visibles[i]['icon'] as IconData,
                        visibles[i]['title'] as String,
                        _countLabel(counts[visibles[i]['category']] ?? 0, visibles[i]['unit'] as String),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _countLabel(int count, String unit) {
    if (count == 0) return "Bientôt";
    return "$count $unit${count > 1 ? 's' : ''}";
  }

  /// Fiche détaillée d'une ressource. Le document `resources` ne porte pas de
  /// lien externe : on présente donc le contenu complet dont on dispose.
  void _showResourceDetail(AppResource resource) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (resource.imageUrl != null && resource.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    resource.imageUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(height: 15),
              Text(
                resource.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              if (resource.price != null && resource.price!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  resource.price!,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                resource.description,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text("Fermer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdresseIcon(IconData icon, String title, String subtitle) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF0F172A)),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRessourcesRecommandees() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Ressources recommandées"),
        const SizedBox(height: 15),
        StreamBuilder<List<AppResource>>(
          stream: _firestoreService.getResources(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
               return const Text("Aucune ressource disponible.", style: TextStyle(color: Colors.grey));
            }

            final resources = snapshot.data!;
            final mainResource = resources.first;
            final miniResources = resources.length > 1 ? resources.sublist(1).take(2).toList() : [];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    // Hauteur minimale et non fixe : un titre ou une description
                    // un peu long faisait déborder la Column qu'elle contient.
                    constraints: const BoxConstraints(minHeight: 160),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(mainResource.imageUrl ?? "assets/sunset_bg.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [const Color(0xFF0F172A), const Color(0xFF0F172A).withOpacity(0.7), Colors.transparent],
                        ),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("À DÉCOUVRIR", style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            mainResource.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            mainResource.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 9),
                          ),
                          const SizedBox(height: 10),
                          if (mainResource.price != null)
                             Text(mainResource.price!, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F172A),
                              minimumSize: const Size(80, 25),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () => _showResourceDetail(mainResource),
                            child: Text(
                              mainResource.actionText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (miniResources.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: miniResources.map((res) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildRessourceMiniCard(Icons.play_circle_outline, res.title, res.description, res.actionText),
                      )).toList(),
                    ),
                  ),
                ],
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _buildRessourceMiniCard(IconData icon, String title, String desc, String linkText) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Colors.grey, height: 1.2)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(linkText, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.orange, size: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonsPlansMoment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Bons plans du moment"),
        const SizedBox(height: 15),
        StreamBuilder<List<BonPlan>>(
          stream: _firestoreService.getBonsPlans(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Aucun bon plan pour l'instant.", style: TextStyle(color: Colors.grey));
            }
            
            final deal = snapshot.data!.first; // On affiche le plus récent

            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.local_offer_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        Text(deal.description, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Text(deal.actionText, style: const TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: Colors.orange, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ],
    );
  }

  // Bons Plans s'ouvre depuis l'accueil : c'est cet onglet qui reste actif.
  Widget _buildBottomNav() => const AppBottomNavBar(currentIndex: 0);
}

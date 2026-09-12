import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/carnet_note_model.dart';
import '../services/firestore_service.dart';
import '../components/app_bottom_nav_bar.dart';
import 'all_favoris_screen.dart';

class CarnetSpirituelScreen extends StatefulWidget {
  /// Onglet ouvert par défaut : 0 = Rhémas, 1 = Prières exaucées, 2 = Méditations.
  final int initialTab;

  const CarnetSpirituelScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<CarnetSpirituelScreen> createState() => _CarnetSpirituelScreenState();
}

class _CarnetSpirituelScreenState extends State<CarnetSpirituelScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late int _selectedTab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Space for floating button and text
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      _buildTabs(),
                      const SizedBox(height: 20),
                      _buildVersetsBanner(),
                      const SizedBox(height: 20),
                      _buildListHeader(),
                      const SizedBox(height: 15),
                      _buildNotesStream(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildFloatingActionArea(),
          ),
        ],
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
            width: MediaQuery.of(context).size.width * 0.7,
            height: 180,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/sunset_bg.jpg"), // Replace with Bible/Candle image
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
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Expanded(
                      child: Text(
                        "Mon Carnet Spirituel",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 55.0),
                  child: const Text(
                    "Ce que Dieu me dit au fil du temps.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 50), // Spacing for background
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem(0, Icons.star, "Rhémas", "Paroles reçues")),
          Expanded(child: _buildTabItem(1, Icons.pan_tool_outlined, "Prières exaucées", "Témoignages")),
          Expanded(child: _buildTabItem(2, Icons.menu_book, "Méditations", "Notes personnelles")),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String title, String subtitle) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: isSelected ? Colors.orange : const Color(0xFF0F172A)),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.orange : const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersetsBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7), // Light yellow/orange
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Icon(Icons.menu_book, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: StreamBuilder<Map<String, String>>(
              stream: _firestoreService.getCitation('citation_carnet'),
              builder: (context, snapshot) {
                final citation = snapshot.data;
                if (citation == null || (citation['content'] ?? '').isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      citation['content']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(citation['reference'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: const Size(0, 30),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AllFavorisScreen()),
              ),
              icon: const Icon(Icons.menu_book, size: 14),
              label: const Text("Voir tous les versets", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  /// Titre de la liste, aligné sur l'onglet sélectionné : il affichait
  /// « Mes Rhémas » même dans les onglets Prières exaucées et Méditations.
  String get _titreOnglet {
    switch (_selectedTab) {
      case 1:
        return "Mes prières exaucées";
      case 2:
        return "Mes méditations";
      default:
        return "Mes Rhémas";
    }
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _titreOnglet,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text("Les plus récents", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.black87)),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: const Icon(Icons.filter_alt_outlined, size: 16, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesStream() {
    if (_uid == null) {
      return const Center(child: Text("Connectez-vous pour voir vos notes."));
    }
    return StreamBuilder<List<CarnetNote>>(
      stream: _firestoreService.getUserCarnetNotes(_uid!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Aucune note pour le moment.", style: TextStyle(color: Colors.grey)),
          ));
        }
        
        final typeFilter = _selectedTab == 0 ? 'rhema' : (_selectedTab == 1 ? 'priere_exaucee' : 'meditation');
        final filteredNotes = snapshot.data!.where((n) => n.type == typeFilter).toList();

        if (filteredNotes.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Aucune note dans cette catégorie.", style: TextStyle(color: Colors.grey)),
          ));
        }

        return Column(
          children: filteredNotes.map((note) {
             String month = "";
             try {
               month = DateFormat('MMM').format(note.date).toUpperCase();
             } catch (e) {
               month = "${note.date.month}";
             }
             final day = DateFormat('dd').format(note.date);
             final year = DateFormat('yyyy').format(note.date);
             final time = DateFormat('HH:mm').format(note.date);
             
             IconData timeIcon = Icons.wb_sunny;
             if (note.date.hour > 18 || note.date.hour < 6) timeIcon = Icons.nightlight_round;
             
             Color stripColor = const Color(0xFF0F172A);
             if (note.type == 'priere_exaucee') stripColor = Colors.orange;
             if (note.type == 'meditation') stripColor = const Color(0xFF5B4FC8);

             return Padding(
               padding: const EdgeInsets.only(bottom: 15),
               child: _buildRhemaCard(
                 month, day, year, timeIcon, time, stripColor, note.title, note.content, note.tags
               ),
             );
          }).toList(),
        );
      }
    );
  }

  Widget _buildRhemaCard(String month, String day, String year, IconData timeIcon, String time, Color stripColor, String title, String content, List<String> tags) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Date Strip
            Container(
              width: 60,
              decoration: BoxDecoration(
                color: stripColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(month, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(day, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(year, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  const SizedBox(height: 10),
                  Icon(timeIcon, color: Colors.white, size: 14),
                  const SizedBox(height: 2),
                  Text(time, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
            // Right Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ),
                        const Icon(Icons.more_horiz, color: Color(0xFF0F172A)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      content,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: tags.map((t) => _buildTag(t)).toList(),
                          ),
                        ),
                        const Icon(Icons.bookmark_border, color: Color(0xFF0F172A)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFloatingActionArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.spa, color: Colors.orangeAccent, size: 20), // Laurel wreath substitute
                SizedBox(width: 10),
                Text(
                  "Dieu te parle chaque jour.\nÉcris, relis, et souviens-toi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF0F172A), fontSize: 12),
                ),
                SizedBox(width: 10),
                Icon(Icons.spa, color: Colors.orangeAccent, size: 20),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _showAddNoteDialog(context);
            },
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 5),
                const Text("Nouvelle note", style: TextStyle(color: Color(0xFF0F172A), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Le carnet s'ouvre depuis Mon espace : c'est cet onglet qui reste actif.
  Widget _buildBottomNav() => const AppBottomNavBar(currentIndex: 4);

  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedType = 'rhema';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Nouvelle Note", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: "Catégorie", border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'rhema', child: Text("Rhéma")),
                        DropdownMenuItem(value: 'priere_exaucee', child: Text("Prière exaucée")),
                        DropdownMenuItem(value: 'meditation', child: Text("Méditation")),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Titre ou phrase clé", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: "Contenu", border: OutlineInputBorder()),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () async {
                    if (titleController.text.isEmpty || contentController.text.isEmpty) return;
                    final navigator = Navigator.of(context);
                    if (_uid != null) {
                      final note = CarnetNote(
                        id: '',
                        type: selectedType,
                        title: titleController.text,
                        content: contentController.text,
                        tags: [], // Simplification pour le MVP
                        date: DateTime.now(),
                      );
                      await _firestoreService.addCarnetNote(_uid!, note);
                    }
                    navigator.pop();
                  },
                  child: const Text("Enregistrer"),
                ),
              ],
            );
          }
        );
      }
    );
  }
}

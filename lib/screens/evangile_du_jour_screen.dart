import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/aelf_api_service.dart';
import '../services/firestore_service.dart';
import '../services/share_service.dart';
import '../models/evangile_model.dart';

class EvangileDuJourScreen extends StatelessWidget {
  EvangileDuJourScreen({Key? key}) : super(key: key);

  final AelfApiService _apiService = AelfApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<List<MesseLecture>>(
        future: _apiService.getMesseDuJour(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC72127)));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("Aucune lecture trouvée pour aujourd'hui."),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Retour"),
                  )
                ],
              ),
            );
          }

          final lectures = snapshot.data!;
          final evangile = lectures.firstWhere((l) => l.type == 'evangile', orElse: () => lectures.first);

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, evangile),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ...lectures.map((lecture) => Column(
                        children: [
                          _buildEvangileText(context, lecture),
                          const SizedBox(height: 20),
                        ],
                      )).toList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MesseLecture evangile) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/sunset_bg.jpg"),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Container(
          // Hauteur minimale et non figée : avec un texte agrandi par les
          // réglages système, le contenu débordait de l'en-tête.
          constraints: const BoxConstraints(minHeight: 300),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.4),
                const Color(0xFFF8F9FA),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      "Messe du Jour",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                    ),
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
                            icon: const Icon(Icons.share_outlined, color: Colors.black54, size: 20),
                            onPressed: () => ShareService.shareVerse(
                              reference: evangile.reference,
                              text: evangile.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evangile.title, 
                      style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        const Text(
                          "Écoute la ",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFC72127), Colors.orangeAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "Parole",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "qui donne la vie",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getLectureStyle(String type) {
    switch (type) {
      case 'lecture_1':
        return {'label': 'PREMIÈRE LECTURE', 'icon': Icons.menu_book, 'color': const Color(0xFF5B4FC8)}; // Violet
      case 'psaume':
        return {'label': 'PSAUME', 'icon': Icons.music_note, 'color': const Color(0xFFD98E2A)}; // Orange/Moutarde
      case 'lecture_2':
        return {'label': 'DEUXIÈME LECTURE', 'icon': Icons.import_contacts, 'color': const Color(0xFF2E7D32)}; // Vert
      case 'evangile':
        return {'label': 'ÉVANGILE', 'icon': Icons.wb_sunny_outlined, 'color': const Color(0xFFC72127)}; // Rouge
      default:
        return {'label': 'LECTURE', 'icon': Icons.bookmark_border, 'color': Colors.blueGrey};
    }
  }

  Widget _buildEvangileText(BuildContext context, MesseLecture lecture) {
    final style = _getLectureStyle(lecture.type);
    final label = style['label'] as String;
    final icon = style['icon'] as IconData;
    final color = style['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 20),
          Text(lecture.title, style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(lecture.reference, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          Text(
            lecture.text.replaceAll(r'\n', '\n'),
            style: const TextStyle(fontSize: 16, color: Color(0xFF334155), height: 1.6, letterSpacing: 0.2),
          ),
          if (lecture.type == 'evangile') ...[
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                  shadowColor: color.withOpacity(0.4),
                ),
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    bool validated = await FirestoreService().validerEvangileDuJour(uid);
                    if (!context.mounted) return;
                    if (validated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Félicitations ! Votre jauge Évangile a progressé. 🎉'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vous avez déjà validé votre lecture aujourd\'hui. À demain ! 🙏'), backgroundColor: Colors.orange),
                      );
                    }
                  }
                  if (context.mounted) Navigator.pop(context); // Retour à l'accueil
                },
                icon: const Icon(Icons.check, color: Colors.white, size: 20),
                label: const Text("J'ai prié la Messe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/quiz_mode_model.dart';
import 'quiz_screen.dart';

class QuizListScreen extends StatelessWidget {
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  /// Règle de jeu à appliquer aux quiz de la catégorie. Sans jeu choisi, la
  /// liste se joue en mode classique.
  final QuizMode mode;

  /// Nom du jeu d'où l'on vient, affiché en tête de liste.
  final String? gameTitle;

  QuizListScreen({
    Key? key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
    this.mode = QuizMode.classique,
    this.gameTitle,
  }) : super(key: key);

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(categoryIcon, color: categoryColor, size: 20),
            const SizedBox(width: 8),
            Text(categoryTitle, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _firestoreService.getQuizzesByCategory(categoryTitle),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur lors du chargement des quiz."));
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(categoryIcon, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  Text("Aucun quiz dans la catégorie $categoryTitle.", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: quizzes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildRegleDuJeu();

              final quiz = quizzes[index - 1];
              final niveau = (quiz['level'] ?? '').toString();
              final points = quiz['points'] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: categoryColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(categoryIcon, color: categoryColor),
                  ),
                  title: Text(
                    quiz['title'] ?? 'Quiz',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        if (niveau.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _couleurNiveau(niveau).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              niveau,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _couleurNiveau(niveau)),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text("$points points à gagner", style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.play_circle_fill, color: Color(0xFF0F172A), size: 30),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          quizId: quiz['id'],
                          pointsToWin: points is int ? points : int.tryParse('$points') ?? 0,
                          title: quiz['title'] ?? 'Quiz',
                          mode: mode,
                          gameTitle: gameTitle,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Rappelle la règle avant de lancer une partie : en mode Chrono ou Mélange,
  /// le joueur doit savoir à quoi il s'engage.
  Widget _buildRegleDuJeu() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconeMode, color: categoryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameTitle ?? "Mode ${mode.nom}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: categoryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  mode.regle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData get _iconeMode {
    switch (mode) {
      case QuizMode.chrono:
        return Icons.timer_outlined;
      case QuizMode.melange:
        return Icons.shuffle;
      case QuizMode.classique:
        return Icons.menu_book_outlined;
    }
  }

  Color _couleurNiveau(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'débutant':
        return const Color(0xFF2E7D32);
      case 'intermédiaire':
        return const Color(0xFFEF6C00);
      case 'expert':
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }
}

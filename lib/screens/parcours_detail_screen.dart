import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/parcours_content_model.dart';
import 'parcours_lesson_screen.dart';
import 'parcours_evaluation_sheet.dart';
import '../models/parcours_avis_model.dart';

/// Écran de détail d'un parcours, entièrement piloté par le document
/// `parcours_content/<parcoursId>` : titre, sous-titre, couleur, visuel et
/// leçons proviennent de Firestore.
class ParcoursDetailScreen extends StatefulWidget {
  final String parcoursId;

  const ParcoursDetailScreen({Key? key, required this.parcoursId}) : super(key: key);

  @override
  State<ParcoursDetailScreen> createState() => _ParcoursDetailScreenState();
}

class _ParcoursDetailScreenState extends State<ParcoursDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  String get _parcoursId => widget.parcoursId;

  Color _primaryColorOf(ParcoursContent? content) {
    if (content == null) return Colors.orange;
    try {
      return Color(int.parse(content.colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<ParcoursContent?>(
        stream: _firestoreService.getParcoursContent(_parcoursId),
        builder: (context, contentSnapshot) {
          if (contentSnapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          final parcoursContent = contentSnapshot.data;
          final int totalDays = parcoursContent?.lessons.length ?? 0;
          final Color primaryColor = _primaryColorOf(parcoursContent);

          return StreamBuilder<int>(
            stream: _uid != null
                ? _firestoreService.getParcoursProgress(_uid!, _parcoursId)
                : Stream.value(0),
            builder: (context, snapshot) {
              int completedDays = snapshot.data ?? 0;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context, parcoursContent, primaryColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildProgressionCard(completedDays, totalDays, primaryColor),
                          const SizedBox(height: 25),
                          Text(
                            "Les $totalDays jours du parcours",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 15),
                          _buildTimeline(completedDays, parcoursContent, primaryColor),
                          const SizedBox(height: 25),
                          _buildContinueBanner(completedDays, parcoursContent, primaryColor),
                          const SizedBox(height: 25),
                          _buildAvis(parcoursContent, totalDays, completedDays, primaryColor),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ParcoursContent? content, Color primaryColor) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          height: 250,
          child: Image.asset(
            content?.imageAsset ?? "assets/sunset_bg.jpg",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: primaryColor.withOpacity(0.5)),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          height: 250,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.1),
                  const Color(0xFFF8F9FA),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 15),
                Text(
                  content?.kicker ?? "Parcours",
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  content?.title ?? "",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  child: Text(
                    content == null
                        ? ""
                        : "${content.subtitle} ${content.lessons.length} étapes pratiques.",
                    style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressionCard(int completedDays, int totalDays, Color primaryColor) {
    double progress = totalDays > 0 ? completedDays / totalDays : 0.0;
    if (progress > 1.0) progress = 1.0;
    
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ta progression", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16)),
              Text("${(progress * 100).toInt()}%", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 15),
          Text("$completedDays / $totalDays jours complétés", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTimeline(int completedDays, ParcoursContent? content, Color primaryColor) {
    if (content == null || content.lessons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("Contenu en cours de préparation...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      );
    }
    
    var levels = content.lessons;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        bool isLocked = index > completedDays;
        bool isCompleted = index < completedDays;
        _LevelStatus status = isCompleted 
            ? _LevelStatus.completed 
            : (isLocked ? _LevelStatus.locked : _LevelStatus.inProgress);
            
        var level = levels[index];

        return _buildLevelCard(
          number: index + 1,
          title: level.title,
          subtitle: level.desc,
          status: status,
          isLast: index == levels.length - 1,
          primaryColor: primaryColor,
          onTap: status == _LevelStatus.locked ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParcoursLessonScreen(
                  parcoursId: _parcoursId,
                  parcoursTitle: content.title,
                  lessonTitle: level.title,
                  dayNumber: index + 1,
                  totalDays: levels.length,
                  currentCompletedDays: completedDays,
                  content: level.content,
                  primaryColor: primaryColor,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLevelCard({
    required int number,
    required String title,
    required String subtitle,
    required _LevelStatus status,
    required bool isLast,
    required Color primaryColor,
    VoidCallback? onTap,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: status == _LevelStatus.completed ? primaryColor : (status == _LevelStatus.inProgress ? primaryColor.withOpacity(0.2) : Colors.grey.shade300),
                    shape: BoxShape.circle,
                    border: status == _LevelStatus.inProgress ? Border.all(color: primaryColor, width: 2) : null,
                  ),
                  child: Center(
                    child: status == _LevelStatus.completed
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            number.toString(),
                            style: TextStyle(
                              color: status == _LevelStatus.inProgress ? primaryColor : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: status == _LevelStatus.completed ? primaryColor : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    if (status != _LevelStatus.locked) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                  border: status == _LevelStatus.inProgress ? Border.all(color: primaryColor.withOpacity(0.5)) : null,
                ),
                child: Opacity(
                  opacity: status == _LevelStatus.locked ? 0.6 : 1.0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    trailing: status == _LevelStatus.locked
                        ? const Icon(Icons.lock, color: Colors.grey)
                        : Icon(Icons.chevron_right, color: primaryColor),
                    onTap: onTap,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Avis des membres sur le parcours.
  ///
  /// Le formulaire n'est proposé qu'une fois le parcours terminé : un avis
  /// donné au troisième jour ne dirait pas grand-chose de l'ensemble.
  Widget _buildAvis(
    ParcoursContent? content,
    int totalDays,
    int completedDays,
    Color primaryColor,
  ) {
    if (content == null) return const SizedBox.shrink();
    final termine = totalDays > 0 && completedDays >= totalDays;

    return StreamBuilder<List<AvisParcours>>(
      stream: _firestoreService.getAvisParcours(_parcoursId),
      builder: (context, snapshot) {
        final avis = snapshot.data ?? <AvisParcours>[];
        final resume = ResumeAvis.depuis(avis);

        return StreamBuilder<AvisParcours?>(
          stream: _uid != null
              ? _firestoreService.getMonAvisParcours(_uid!, _parcoursId)
              : Stream.value(null),
          builder: (context, monAvisSnapshot) {
            final monAvis = monAvisSnapshot.data;

            // Rien à montrer tant que personne n'a donné son avis et que le
            // membre n'a pas fini : la section resterait un cadre vide.
            if (resume.nombre == 0 && !termine) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ce qu'en disent les membres",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  if (resume.nombre > 0)
                    _buildResumeAvis(resume, primaryColor)
                  else
                    const Text(
                      "Aucun avis pour l'instant. Tu peux être le premier.",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ...avis.take(3).map(_buildAvisItem),
                  if (termine) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => showAvisParcours(
                          context,
                          parcoursId: _parcoursId,
                          parcoursTitle: content.title,
                          couleur: primaryColor,
                          avisExistant: monAvis,
                        ),
                        icon: Icon(Icons.rate_review_outlined, color: primaryColor, size: 18),
                        label: Text(
                          monAvis == null ? "Donner mon avis" : "Modifier mon avis",
                          style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResumeAvis(ResumeAvis resume, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            resume.moyenne.toStringAsFixed(1),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < resume.moyenne.round() ? Icons.star : Icons.star_border,
                      size: 16,
                      color: const Color(0xFFD4A017),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${resume.nombre} avis · ${(resume.tauxRecommandation * 100).round()} % le recommandent",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvisItem(AvisParcours avis) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  avis.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < avis.note ? Icons.star : Icons.star_border,
                    size: 12,
                    color: const Color(0xFFD4A017),
                  ),
                ),
              ),
            ],
          ),
          if (avis.pointFort.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              PointsFortsParcours.libelle(avis.pointFort),
              style: const TextStyle(color: Color(0xFF5B4FC8), fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
          if (avis.commentaire.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              avis.commentaire,
              style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContinueBanner(int completedDays, ParcoursContent? content, Color primaryColor) {
    if (content == null || content.lessons.isEmpty) return const SizedBox.shrink();

    var levels = content.lessons;
    int nextDayIndex = completedDays;
    bool isFinished = nextDayIndex >= levels.length;
    var currentLevel = isFinished ? levels.last : levels[nextDayIndex];

    return GestureDetector(
      onTap: isFinished ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParcoursLessonScreen(
              parcoursId: _parcoursId,
              parcoursTitle: content.title,
              lessonTitle: currentLevel.title,
              dayNumber: nextDayIndex + 1,
              totalDays: levels.length,
              currentCompletedDays: completedDays,
              content: currentLevel.content,
              primaryColor: primaryColor,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isFinished ? "Parcours terminé !" : "Prêt à continuer ?", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 5),
                  Text(isFinished ? "Félicitations pour ton assiduité." : "Jour ${nextDayIndex + 1} : ${currentLevel.title}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                ],
              ),
            ),
            if (!isFinished)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: primaryColor),
              ),
            if (isFinished)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}

enum _LevelStatus { completed, inProgress, locked }

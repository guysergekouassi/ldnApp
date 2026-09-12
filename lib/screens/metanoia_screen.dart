import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/metanoia_model.dart';
import 'metanoia_lesson_screen.dart';

class MetanoiaScreen extends StatefulWidget {
  const MetanoiaScreen({Key? key}) : super(key: key);

  @override
  State<MetanoiaScreen> createState() => _MetanoiaScreenState();
}

class _MetanoiaScreenState extends State<MetanoiaScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  List<MetanoiaLevel> _levels = [];
  List<String> _completedLessonIds = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // No seeding here, the seeding is done in the main screen
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color(0xFF5B4FC8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _uid == null
          ? const Center(child: Text("Veuillez vous connecter pour voir votre progression."))
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<MetanoiaLevel>>(
                  stream: _firestoreService.getMetanoiaLevels(),
                  builder: (context, levelsSnapshot) {
                    if (levelsSnapshot.hasError) return Center(child: Text("Erreur: ${levelsSnapshot.error}"));
                    if (!levelsSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                    _levels = levelsSnapshot.data!;

                    return StreamBuilder<List<String>>(
                      stream: _firestoreService.getUserMetanoiaProgress(_uid!),
                      builder: (context, progressSnapshot) {
                        if (progressSnapshot.hasData) {
                          _completedLessonIds = progressSnapshot.data!;
                        }

                        int totalLessons = _levels.fold(0, (sum, level) => sum + level.totalLessons);
                        int completedCount = _completedLessonIds.length; // Approximate, but good enough for demo
                        double globalProgress = totalLessons > 0 ? completedCount / totalLessons : 0.0;
                        if (globalProgress > 1.0) globalProgress = 1.0;

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildHeader(context, primaryColor),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    _buildProgressionCard(globalProgress, completedCount, totalLessons, primaryColor),
                                    const SizedBox(height: 25),
                                    Text(
                                      "Les ${_levels.length} niveaux du Metanoia",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildTimeline(primaryColor),
                                    const SizedBox(height: 25),
                                    _buildContinueBanner(primaryColor),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 220,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/mountain_bg.png"),
                fit: BoxFit.cover,
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
                  "Metanoia",
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "Métanoia",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  child: Text(
                    "Un chemin en 6 niveaux pour transformer ton cœur et marcher chaque jour avec le Christ.",
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

  Widget _buildProgressionCard(double globalProgress, int completedCount, int totalLessons, Color primaryColor) {
    int percentage = (globalProgress * 100).toInt();
    
    int currentLevelOrder = 1;
    int lessonsSum = 0;
    for (var level in _levels) {
      lessonsSum += level.totalLessons;
      if (completedCount < lessonsSum) {
        currentLevelOrder = level.order;
        break;
      }
      if (level.order == _levels.length) {
        currentLevelOrder = level.order; // Max
      }
    }

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
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: globalProgress,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  strokeWidth: 4,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.flag, color: primaryColor, size: 24),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ta progression", style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("$percentage", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const Text(" %", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                Text("Niveau $currentLevelOrder sur ${_levels.length}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$completedCount/$totalLessons leçons", style: const TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Text("Voir mon Metanoia", style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    Icon(Icons.chevron_right, color: primaryColor, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Color primaryColor) {
    int lessonsSum = 0;

    return Column(
      children: _levels.asMap().entries.map((entry) {
        int index = entry.key;
        MetanoiaLevel level = entry.value;

        int levelCompletedLessons = 0;
        int previousLevelsTotal = lessonsSum;
        lessonsSum += level.totalLessons;

        _LevelStatus status = _LevelStatus.locked;
        if (_completedLessonIds.length >= lessonsSum) {
          status = _LevelStatus.completed;
          levelCompletedLessons = level.totalLessons;
        } else if (_completedLessonIds.length >= previousLevelsTotal) {
          status = _LevelStatus.inProgress;
          levelCompletedLessons = _completedLessonIds.length - previousLevelsTotal;
        }

        double progress = level.totalLessons > 0 ? levelCompletedLessons / level.totalLessons : 0.0;
        int pct = (progress * 100).toInt();

        return _buildTimelineItem(
          level: level,
          status: status,
          progress: "$pct %",
          isFirst: index == 0,
          isLast: index == _levels.length - 1,
          primaryColor: primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineItem({
    required MetanoiaLevel level,
    required _LevelStatus status,
    required String progress,
    required Color primaryColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    bool isCompleted = status == _LevelStatus.completed;
    bool isInProgress = status == _LevelStatus.inProgress;
    bool isLocked = status == _LevelStatus.locked;

    Color iconBgColor;
    Widget iconChild;

    if (isCompleted) {
      iconBgColor = Colors.green;
      iconChild = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isInProgress) {
      iconBgColor = primaryColor;
      iconChild = Text("${level.order}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12));
    } else {
      iconBgColor = Colors.grey.shade200;
      iconChild = const Icon(Icons.lock_outline, color: Colors.grey, size: 14);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted || isInProgress ? primaryColor : Colors.grey.shade300,
                    ),
                  ),
                if (isFirst) const SizedBox(height: 25),
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: iconChild,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? primaryColor : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: isLocked ? null : () {
                _showLevelLessons(level, primaryColor);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: isInProgress ? Border.all(color: primaryColor.withOpacity(0.3), width: 1.5) : Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    if (!isLocked) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
                  ],
                ),
                child: Opacity(
                  opacity: isLocked ? 0.6 : 1.0,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(level.imageAsset, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.grey[300])),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(level.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isLocked ? Colors.grey.shade700 : const Color(0xFF0F172A))),
                            const SizedBox(height: 5),
                            Text(level.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.3)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.check, color: Colors.green, size: 12),
                                  SizedBox(width: 4),
                                  Text("Terminé", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          else if (isInProgress)
                            Text(progress, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12))
                          else
                            Column(
                              children: const [
                                Icon(Icons.lock_outline, color: Colors.grey, size: 16),
                                SizedBox(height: 2),
                                Text("Verrouillé", style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          if (!isLocked)
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelLessons(MetanoiaLevel level, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Expanded(
                child: StreamBuilder<List<MetanoiaLesson>>(
                  stream: _firestoreService.getMetanoiaLessons(level.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}", style: const TextStyle(fontSize: 10, color: Colors.red)));
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final lessons = snapshot.data!;
                    
                    if (lessons.isEmpty) {
                      return const Center(child: Text("Les leçons de ce niveau arrivent bientôt !"));
                    }

                    return ListView.builder(
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        final isCompleted = _completedLessonIds.contains(lesson.id);
                        
                        return ListTile(
                          leading: Icon(
                            isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                            color: isCompleted ? Colors.green : primaryColor,
                          ),
                          title: Text(lesson.title, style: TextStyle(fontWeight: FontWeight.bold, color: isCompleted ? Colors.grey : Colors.black)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MetanoiaLessonScreen(lesson: lesson, isCompleted: isCompleted)),
                            ).then((_) => setState(() {}));
                          },
                        );
                      },
                    );
                  }
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildContinueBanner(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_outlined, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Continue ton chemin !", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14)),
                const SizedBox(height: 5),
                const Text("Chaque pas de foi te rapproche de la plénitude en Christ.", style: TextStyle(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _LevelStatus { completed, inProgress, locked }

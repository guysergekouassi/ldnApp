import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/quiz_mode_model.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final int pointsToWin;
  final String title;

  /// Règle appliquée à la partie. Les quiz ouverts hors d'un jeu se jouent en
  /// mode classique.
  final QuizMode mode;

  /// Nom du jeu d'où l'on vient, affiché sous le titre du quiz.
  final String? gameTitle;

  const QuizScreen({
    Key? key,
    required this.quizId,
    required this.pointsToWin,
    required this.title,
    this.mode = QuizMode.classique,
    this.gameTitle,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  int? _selectedIndex;
  bool _showResult = false;

  /// Vrai quand la partie s'est arrêtée sur une erreur, en mode sans droit à
  /// l'erreur : le résultat le dit plutôt que d'afficher un score trompeur.
  bool _arretSurErreur = false;

  Timer? _chrono;
  int _secondesRestantes = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _chrono?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _firestoreService.getQuizQuestions(widget.quizId);
      if (!mounted) return;
      setState(() {
        _questions = _preparer(questions);
        _isLoading = false;
      });
      _demarrerChrono();
    } catch (e) {
      debugPrint("Chargement du quiz impossible : $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// En mode Mélange, l'ordre des questions et celui des réponses sont tirés au
  /// sort ; l'indice de la bonne réponse est reporté sur la nouvelle position.
  List<Map<String, dynamic>> _preparer(List<Map<String, dynamic>> brutes) {
    final questions = brutes.map((q) => Map<String, dynamic>.from(q)).toList();
    if (!widget.mode.melangeLesQuestions) return questions;

    final hasard = Random();
    questions.shuffle(hasard);

    return questions.map((q) {
      final options = (q['options'] as List? ?? []).map((o) => o.toString()).toList();
      final bonneReponse = options.isEmpty
          ? ''
          : options[(int.tryParse('${q['correctIndex']}') ?? 0).clamp(0, options.length - 1)];

      options.shuffle(hasard);

      return {
        ...q,
        'options': options,
        'correctIndex': options.indexOf(bonneReponse),
      };
    }).toList();
  }

  void _demarrerChrono() {
    final duree = widget.mode.secondesParQuestion;
    if (duree == null || _questions.isEmpty) return;

    _chrono?.cancel();
    setState(() => _secondesRestantes = duree);

    _chrono = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondesRestantes <= 1) {
        timer.cancel();
        _tempsEcoule();
      } else {
        setState(() => _secondesRestantes--);
      }
    });
  }

  /// Le temps écoulé vaut une mauvaise réponse : on révèle la bonne, puis on
  /// enchaîne comme après une réponse fausse.
  void _tempsEcoule() {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _selectedIndex = null;
      _secondesRestantes = 0;
    });
    _programmerSuite(bonneReponse: false);
  }

  void _submitAnswer(int index) {
    if (_isAnswered) return;
    _chrono?.cancel();

    final bonneReponse = index == _questions[_currentIndex]['correctIndex'];

    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
      if (bonneReponse) _score++;
    });

    _programmerSuite(bonneReponse: bonneReponse);
  }

  void _programmerSuite({required bool bonneReponse}) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (!bonneReponse && widget.mode.sansDroitALErreur) {
        _arretSurErreur = true;
        _finishQuiz();
        return;
      }

      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _isAnswered = false;
          _selectedIndex = null;
        });
        _demarrerChrono();
      } else {
        _finishQuiz();
      }
    });
  }

  int get _pointsGagnes {
    if (_questions.isEmpty) return 0;
    final part = _score / _questions.length;
    return (widget.pointsToWin * part * widget.mode.multiplicateurPoints).round();
  }

  Future<void> _finishQuiz() async {
    _chrono?.cancel();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.updateGamificationPoints(uid, _pointsGagnes, quizId: widget.quizId);
    }

    if (!mounted) return;
    setState(() => _showResult = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.title, style: const TextStyle(color: Colors.black87)),
        ),
        body: const Center(child: Text("Aucune question disponible.")),
      );
    }

    if (_showResult) {
      return _buildResultScreen();
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(widget.title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
            Text(
              widget.gameTitle ?? "Mode ${widget.mode.nom}",
              style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Question ${_currentIndex + 1}/${_questions.length}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                if (widget.mode.secondesParQuestion != null) ...[
                  const SizedBox(width: 12),
                  _buildChrono(),
                ],
                if (widget.mode.sansDroitALErreur) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.favorite, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  const Text("1 vie", style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
            const SizedBox(height: 30),
            Text(
              question['question'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...List.generate(
              (question['options'] as List).length,
              (index) {
                final option = question['options'][index];
                final isCorrect = index == question['correctIndex'];

                Color getButtonColor() {
                  if (!_isAnswered) return Colors.white;
                  if (index == _selectedIndex) {
                    return isCorrect ? Colors.green.shade100 : Colors.red.shade100;
                  }
                  if (isCorrect) return Colors.green.shade100;
                  return Colors.white;
                }

                Color getBorderColor() {
                  if (!_isAnswered) return Colors.grey.shade300;
                  if (index == _selectedIndex) {
                    return isCorrect ? Colors.green : Colors.red;
                  }
                  if (isCorrect) return Colors.green;
                  return Colors.grey.shade300;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: GestureDetector(
                    onTap: () => _submitAnswer(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: getButtonColor(),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: getBorderColor(), width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Text(
                        option.toString(),
                        style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_isAnswered && _selectedIndex == null)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Temps écoulé !",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChrono() {
    final urgence = _secondesRestantes <= 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: urgence ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: urgence ? Colors.red : Colors.orange),
          const SizedBox(width: 4),
          Text(
            "$_secondesRestantes s",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: urgence ? Colors.red : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _arretSurErreur ? Icons.heart_broken : Icons.emoji_events,
                color: _arretSurErreur ? Colors.redAccent : Colors.amber,
                size: 90,
              ),
              const SizedBox(height: 25),
              Text(
                _arretSurErreur ? "Partie terminée" : "Quiz terminé !",
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _arretSurErreur
                    ? "Une erreur suffit à arrêter le mode ${widget.mode.nom}."
                    : "Votre score : $_score/${_questions.length}",
                style: const TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              if (_arretSurErreur) ...[
                const SizedBox(height: 6),
                Text(
                  "$_score bonne${_score > 1 ? 's' : ''} réponse${_score > 1 ? 's' : ''} sur ${_questions.length}",
                  style: const TextStyle(fontSize: 15, color: Colors.white54),
                ),
              ],
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(30)),
                child: Text(
                  "+ $_pointsGagnes points",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
              if (widget.mode.multiplicateurPoints > 1) ...[
                const SizedBox(height: 10),
                Text(
                  "Mode ${widget.mode.nom} : points × ${widget.mode.multiplicateurPoints}",
                  style: const TextStyle(fontSize: 13, color: Colors.white54),
                ),
              ],
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Retour", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

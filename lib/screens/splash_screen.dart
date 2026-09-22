import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _amorcerContenuEnArrierePlan();
    _naviguer();
  }

  /// Amorçage du contenu Firestore, volontairement **non bloquant**.
  ///
  /// Ces appels attendaient auparavant devant la navigation : hors ligne ou si
  /// les règles de sécurité refusaient l'accès, ils ne rendaient jamais la main
  /// et l'application restait bloquée sur l'écran de démarrage.
  ///
  /// Ils ne partent que si une session est déjà ouverte : les règles Firestore
  /// réservent l'écriture aux membres connectés, et un compte tout neuf
  /// verrait sinon ces trois amorçages refusés en silence. Le relais est pris
  /// par `HomeScreen`, qui les rejoue une fois la connexion faite.
  void _amorcerContenuEnArrierePlan() {
    if (FirebaseAuth.instance.currentUser == null) return;

    Future(() async {
      try {
        await _firestoreService
            .checkAndInitializeBonsPlansAndAddresses()
            .timeout(const Duration(seconds: 15));
        await _firestoreService
            .checkAndInitializeQuizAndGames()
            .timeout(const Duration(seconds: 20));
        // Nettoie les faux joueurs du classement laissés par les versions
        // précédentes ; les vrais joueurs y entrent en gagnant des points.
        await _firestoreService
            .purgeLeaderboardMockPlayers()
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        debugPrint("Amorçage du contenu incomplet : $e");
      }
    });
  }

  Future<void> _naviguer() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => user != null ? const HomeScreen() : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash_bg.jpg"),
            fit: BoxFit.cover,
            // Si l'image manque, le fond blanc et le logo restent visibles :
            // l'écran ne peut plus apparaître entièrement vide.
            onError: _ignorerImageManquante,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                "assets/images/logo_jeunesse.png",
                width: 180,
                errorBuilder: (context, error, stackTrace) => const Text(
                  "JEP",
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.orange),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

void _ignorerImageManquante(Object error, StackTrace? stackTrace) {
  debugPrint("Image de fond du démarrage introuvable : $error");
}

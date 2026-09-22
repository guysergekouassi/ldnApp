import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'responsive.dart';

/// Branche l'application sur les émulateurs Firebase locaux.
///
/// Activé uniquement par `--dart-define=USE_FIREBASE_EMULATOR=true` : sans ce
/// drapeau, rien ne change et l'application parle au vrai projet. Cela permet
/// de lancer et de piloter l'app — se connecter, semer du contenu, parcourir
/// les écrans — sans écrire une seule ligne dans la base de production.
///
///     firebase emulators:start --only auth,firestore
///     flutter run --dart-define=USE_FIREBASE_EMULATOR=true
const bool _utiliserEmulateurs = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

/// Hôte des émulateurs. À passer à `10.0.2.2` pour l'émulateur Android, dont
/// `localhost` désigne le téléphone virtuel et non la machine de développement.
const String _hoteEmulateurs =
    String.fromEnvironment('FIREBASE_EMULATOR_HOST', defaultValue: '127.0.0.1');

Future<void> _brancherEmulateurs() async {
  await FirebaseAuth.instance.useAuthEmulator(_hoteEmulateurs, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(_hoteEmulateurs, 8080);
  debugPrint("Émulateurs Firebase actifs sur $_hoteEmulateurs.");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // L'initialisation ne doit jamais empêcher l'affichage : si une exception
  // remontait ici, `runApp` n'était jamais appelé et l'application restait sur
  // un écran blanc, sans aucun message — invisible en debug, bloquant en release.
  String? erreurDemarrage;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 20));
    if (_utiliserEmulateurs) await _brancherEmulateurs();
  } catch (e) {
    erreurDemarrage = "Connexion à Firebase impossible.\n\n$e";
    debugPrint("Échec de l'initialisation Firebase : $e");
  }

  // Les notifications sont accessoires au démarrage : un échec ne doit pas
  // empêcher l'application de s'ouvrir.
  try {
    await NotificationService().init().timeout(const Duration(seconds: 10));
  } catch (e) {
    debugPrint("Échec de l'initialisation des notifications : $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(erreurDemarrage: erreurDemarrage),
    ),
  );
}

/// Écran affiché quand l'application ne peut pas démarrer, à la place d'une
/// page blanche muette.
class _ErreurDemarrageScreen extends StatelessWidget {
  final String message;

  const _ErreurDemarrageScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "Démarrage impossible",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              const Text(
                "Vérifie ta connexion Internet puis relance l'application.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  /// Renseigné si l'initialisation a échoué : on affiche alors un écran
  /// explicite au lieu de laisser l'utilisateur devant une page vide.
  final String? erreurDemarrage;

  const MyApp({Key? key, this.erreurDemarrage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'JEP',
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
          ),
          // Applique la borne d'agrandissement de police à toute l'application,
          // y compris aux boîtes de dialogue et feuilles modales.
          builder: (context, child) => ClampedTextScale(
            child: child ?? const SizedBox.shrink(),
          ),
          home: erreurDemarrage != null
              ? _ErreurDemarrageScreen(message: erreurDemarrage!)
              : const SplashScreen(),
        );
      },
    );
  }
}

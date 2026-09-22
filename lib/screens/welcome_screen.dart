import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../components/ldn_signature.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la connexion avec Google.")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Ouvre l'application sans créer de compte.
  ///
  /// La session repose sur un compte anonyme Firebase : la progression est
  /// bien enregistrée, et Mon Espace propose ensuite de la rattacher à un
  /// compte définitif.
  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInAnonymously();
      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir une session invité. Réessaie ou crée un compte."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// « Sign in with Apple » n'est pas encore branché : il réclame le package
  /// `sign_in_with_apple`, un identifiant de service côté Apple Developer et
  /// l'activation du fournisseur Apple dans Firebase Auth. Tant que ce n'est
  /// pas fait, on le dit clairement au lieu de laisser un bouton inerte.
  void _handleAppleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("La connexion avec Apple n'est pas encore disponible. Utilise Google ou ton email."),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Image d'arrière plan (Haut)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: Image.asset(
              "assets/images/splash_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          
          // Nouveau Logo en haut à droite
          Positioned(
            top: size.height * 0.08,
            right: 20,
            child: Image.asset(
              "assets/images/logo_jeunesse.png",
              width: 140,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 140, height: 140, 
                  child: Center(child: Text("Logo introuvable", style: TextStyle(color: Colors.white)))
                );
              },
            ),
          ),
          
          // Conteneur Blanc (Bas)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Bienvenue dans",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A), // Bleu foncé
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: const Text(
                          "ton compagnon spirituel",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Séparateur avec losange
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300, endIndent: 15)),
                          const Text("✦", style: TextStyle(color: Color(0xFFF59E0B), fontSize: 20)),
                          Expanded(child: Divider(color: Colors.grey.shade300, indent: 15)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // Texte descriptif
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                          children: [
                            TextSpan(text: "Grandis dans ta foi et\ndeviens une "),
                            TextSpan(text: "Lumière", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                            TextSpan(text: " pour les nations"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      // Boutons Sociaux
                      _buildSocialButton(
                        iconPath: "assets/icons/google-plus.svg", 
                        text: "Continuer avec Google", 
                        isLoading: _isLoading,
                        onPressed: _isLoading ? () {} : _handleGoogleLogin,
                      ),
                      const SizedBox(height: 12),
                      _buildSocialButton(
                        icon: Icons.apple,
                        text: "Continuer avec Apple",
                        onPressed: _handleAppleLogin,
                      ),
                      const SizedBox(height: 15),
                      
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text("OU", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // Bouton Email
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.email_outlined, color: Color(0xFFD97757)),
                          label: const Text("Continuer avec Email", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Entrée sans compte : l'application s'ouvre tout de
                      // suite, la création de compte reste proposée plus tard.
                      TextButton(
                        onPressed: _isLoading ? null : _handleGuestLogin,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Continuer sans compte",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Créer un compte
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Pas encore de compte ? ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignupScreen()),
                              );
                            },
                            child: const Text(
                              "Créer un compte >",
                              style: TextStyle(color: Color(0xFFD97757), fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const LdnSignature(compact: true),
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

  Widget _buildSocialButton({
    String? iconPath, 
    IconData? icon, 
    required String text, 
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconPath != null) 
                  SvgPicture.asset(iconPath, height: 24, width: 24)
                else if (icon != null)
                  Icon(icon, color: Colors.black, size: 24),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

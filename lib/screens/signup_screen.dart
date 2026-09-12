import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignup() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Veuillez entrer votre nom complet.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signUpWithEmailAndPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = "Le mot de passe est trop faible (6 caractères minimum).";
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = "Cet email est déjà utilisé par un autre compte.";
        } else if (e.code == 'invalid-email') {
          _errorMessage = "L'adresse email est invalide.";
        } else {
          _errorMessage = "Erreur d'inscription: ${e.message}";
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur inattendue est survenue.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
      setState(() {
        _errorMessage = "Échec de l'inscription avec Google.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Image.asset(
              "assets/images/splash_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          // Logo
          Positioned(
            top: size.height * 0.08,
            right: 20,
            child: Image.asset(
              "assets/images/logo_jeunesse.png",
              width: 120,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 120, height: 120),
            ),
          ),
          
          // White Container
          Positioned(
            top: size.height * 0.35, // Overlaps the image
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Créer un compte",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "Rejoignez-nous aujourd'hui",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Name Field
                      const Text("Nom complet", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "Entrez votre nom",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Email Field
                      const Text("Adresse Email", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Entrez votre email",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Password Field
                      const Text("Mot de passe", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Créez un mot de passe",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Signup Button
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleEmailSignup,
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("S'inscrire", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Google Sign In
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Ou s'inscrire avec", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isLoading ? null : _handleGoogleSignup,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                                height: 24,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.blue, size: 30),
                              ),
                              const SizedBox(width: 10),
                              const Flexible(
                                child: Text("Google", style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Go to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Déjà un compte ? ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              "Se connecter", 
                              style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
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
}

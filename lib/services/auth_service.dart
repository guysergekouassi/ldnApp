import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream pour écouter les changements d'état (connexion/déconnexion)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inscription avec Email et Mot de passe
  Future<User?> signUpWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Sauvegarder le profil dans la base de données
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': '',
        });
        
        // Mettre à jour le profil Firebase Auth
        await user.updateDisplayName(name);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Connexion avec Email et Mot de passe
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // Connexion avec Google
  Future<User?> signInWithGoogle() async {
    try {
      UserCredential result;
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        result = await _auth.signInWithPopup(provider);
      } else {
        // Flux d'authentification natif pour Android/iOS
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          // L'utilisateur a annulé la connexion
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        result = await _auth.signInWithCredential(credential);
      }
      
      User? user = result.user;

      if (user != null) {
        // Vérifier si c'est la première fois que l'utilisateur se connecte
        final userDoc = await _db.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // Créer le profil dans la base de données
          await _db.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'fullName': user.displayName ?? '',
            'email': user.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'photoUrl': user.photoURL ?? '',
          });
        }
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Envoi d'un email de réinitialisation du mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}

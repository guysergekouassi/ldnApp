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

  /// Vrai quand la session en cours est un compte invité (connexion anonyme).
  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;

  /// Connexion sans compte.
  ///
  /// On ouvre un vrai compte anonyme Firebase plutôt qu'une session locale :
  /// la progression (parcours, régularité, intentions) est enregistrée comme
  /// pour un membre, et peut être rattachée plus tard à un compte définitif
  /// par [lierCompteEmail] ou [lierCompteGoogle] sans rien perdre.
  ///
  /// Prérequis : activer le fournisseur « Anonyme » dans Firebase Auth.
  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      final user = result.user;

      if (user != null) {
        final userDoc = await _db.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _db.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'fullName': 'Invité',
            'email': '',
            'isGuest': true,
            'createdAt': FieldValue.serverTimestamp(),
            'photoUrl': '',
          });
        }
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Transforme le compte invité en compte email définitif.
  ///
  /// L'identifiant Firebase reste le même : tout ce que l'invité a enregistré
  /// lui reste acquis. Si la session n'est pas anonyme, on retombe sur une
  /// inscription classique.
  Future<User?> lierCompteEmail(String name, String email, String password) async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      return signUpWithEmailAndPassword(name, email, password);
    }

    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      final result = await user.linkWithCredential(credential);
      final lie = result.user;

      if (lie != null) {
        await _db.collection('users').doc(lie.uid).set({
          'uid': lie.uid,
          'fullName': name,
          'email': email,
          'isGuest': false,
        }, SetOptions(merge: true));
        await lie.updateDisplayName(name);
      }
      return lie;
    } catch (e) {
      rethrow;
    }
  }

  /// Rattache le compte invité à un compte Google, en conservant sa progression.
  Future<User?> lierCompteGoogle() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) return signInWithGoogle();

    try {
      OAuthCredential credential;

      if (kIsWeb) {
        final result = await user.linkWithPopup(GoogleAuthProvider());
        await _enregistrerProfilGoogle(result.user);
        return result.user;
      }

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // annulé par l'utilisateur

      final googleAuth = await googleUser.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await user.linkWithCredential(credential);
      await _enregistrerProfilGoogle(result.user);
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _enregistrerProfilGoogle(User? user) async {
    if (user == null) return;
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'isGuest': false,
    }, SetOptions(merge: true));
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

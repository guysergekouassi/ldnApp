import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Avatar affiché tant qu'aucune photo n'est disponible.
const String kDefaultAvatarAsset = "assets/profile.jpg";

/// Résout une référence d'avatar qui peut être soit une URL réseau (photo
/// Google, Firebase Storage…), soit un chemin d'asset local. Les documents
/// Firestore mélangent les deux : `photoUrl` vient de Google et est une URL,
/// tandis que les données de démarrage utilisent des assets.
ImageProvider avatarImageProvider(String? reference) {
  if (reference == null || reference.isEmpty) {
    return const AssetImage(kDefaultAvatarAsset);
  }
  if (reference.startsWith('http://') || reference.startsWith('https://')) {
    return NetworkImage(reference);
  }
  return AssetImage(reference);
}

/// Avatar circulaire d'un membre, tolérant aux URL comme aux assets, avec
/// repli sur l'avatar par défaut si le chargement échoue.
class UserAvatar extends StatelessWidget {
  final String? imageReference;
  final double radius;

  const UserAvatar({
    Key? key,
    required this.imageReference,
    this.radius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;

    return ClipOval(
      child: Image(
        image: avatarImageProvider(imageReference),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          kDefaultAvatarAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: size,
            height: size,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: Icon(Icons.person, size: radius, color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }
}

/// Avatar de l'utilisateur connecté. Privilégie le `photoUrl` stocké dans son
/// document Firestore, et retombe sur le `photoURL` du compte Firebase Auth.
class CurrentUserAvatar extends StatelessWidget {
  final double radius;

  const CurrentUserAvatar({Key? key, this.radius = 20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return UserAvatar(imageReference: null, radius: radius);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String? photo = user.photoURL;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final stored = data?['photoUrl']?.toString();
          if (stored != null && stored.isNotEmpty) {
            photo = stored;
          }
        }

        return UserAvatar(imageReference: photo, radius: radius);
      },
    );
  }
}

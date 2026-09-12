import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chapelet_mystery_model.dart';
import '../models/prayer_activity_model.dart';
import '../models/neuvaine_model.dart';
import '../models/event_model.dart';
import '../models/resource_model.dart';
import '../models/post_model.dart';
import '../models/intention_model.dart';
import '../models/annonce_model.dart';
import '../models/office_model.dart';
import '../models/metanoia_model.dart';
import '../models/parcours_content_model.dart';
import '../models/challenge_model.dart';
import '../models/fraternity_model.dart';
import '../models/objectif_model.dart';
import '../models/carnet_note_model.dart';
import '../models/regularite_model.dart';
import '../models/adresse_model.dart';
import '../models/bon_plan_model.dart';
import '../models/examen_item_model.dart';
import '../models/confession_content_model.dart';
import '../models/daily_task_model.dart';
import 'quiz_catalogue.dart';
import 'parcours_catalogue.dart';
import 'versets_catalogue.dart';
import '../models/favori_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ChapeletMystery>> getChapeletMysteries(String type) {
    return _db.collection('rosary_mysteries').where('type', isEqualTo: type).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => ChapeletMystery.fromFirestore(doc.data(), doc.id)).toList();
      list.sort((a, b) => a.step.compareTo(b.step));
      return list;
    });
  }

  /// Types de mystères réellement présents en base (Joyeux, Douloureux…),
  /// pour ne proposer que ceux dont le contenu existe.
  Stream<List<String>> getChapeletMysteryTypes() {
    return _db.collection('rosary_mysteries').snapshots().map((snapshot) {
      final types = <String>{};
      for (final doc in snapshot.docs) {
        final type = (doc.data()['type'] ?? '').toString().trim();
        if (type.isNotEmpty) types.add(type);
      }
      return types.toList()..sort();
    });
  }

  /// Activités proposées dans « Prions ensemble ».
  Stream<List<PrayerActivity>> getPrayerActivities() {
    return _db.collection('prayer_activities').snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PrayerActivity.fromFirestore(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> checkAndInitializePrayerActivities() async {
    final existing = await _db.collection('prayer_activities').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    const activities = [
      {'title': "Chapelet\nguidé", 'duration': "20 min", 'imageAsset': "assets/images/chapelet.png.jpg", 'iconName': "brightness_high", 'colorHex': "#FFA500", 'action': "chapelet", 'order': 1},
      {'title': "Office des\nHeures", 'duration': "15 min", 'imageAsset': "assets/images/bible.png.jpg", 'iconName': "menu_book", 'colorHex': "#F05B3A", 'action': "office", 'order': 2},
      {'title': "Évangile\ndu Jour", 'duration': "10 min", 'imageAsset': "assets/images/bible.png.jpg", 'iconName': "menu_book", 'colorHex': "#C72127", 'action': "evangile", 'order': 3},
      {'title': "Neuvaines", 'duration': "9 jours", 'imageAsset': "assets/images/bible.png.jpg", 'iconName': "local_fire_department_outlined", 'colorHex': "#FFA500", 'action': "neuvaines", 'order': 4},
      {'title': "Préparation à\nla Confession", 'duration': "12 min", 'imageAsset': "assets/sunset_bg.jpg", 'iconName': "add", 'colorHex': "#E99D1A", 'action': "confession", 'order': 5},
      {'title': "Intentions de\nla Semaine", 'duration': "5 min", 'imageAsset': "assets/hands_heart.png", 'iconName': "favorite_border", 'colorHex': "#C72127", 'action': "intentions", 'order': 6},
    ];

    for (final activity in activities) {
      await _db.collection('prayer_activities').add(activity);
    }
  }



  Stream<List<AppEvent>> getEvents() {
    return _db.collection('events').orderBy('createdAt', descending: false).snapshots().map((snapshot) => snapshot.docs.map((doc) => AppEvent.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> checkAndInitializeEvents() async {
    final snapshot = await _db.collection('events').limit(1).get();
    if (snapshot.docs.isEmpty) {
      await _db.collection('events').add({
        "title": "Retraite Spirituelle de Printemps",
        "description": "Un moment de ressourcement spirituel",
        "date": "2024-05-25",
        "time": "09:00",
        "location": "Centre JEP Cocody",
        "imageUrl": "assets/sunset_bg.jpg",
        "day": "25",
        "month": "Mai",
        "createdAt": FieldValue.serverTimestamp(),
      });
      await _db.collection('events').add({
        "title": "Soirée de Louange & Adoration",
        "description": "Venez louer le Seigneur",
        "date": "2024-06-02",
        "time": "19:00",
        "location": "Paroisse Saint Jean",
        "imageUrl": "assets/rosary.png",
        "day": "02",
        "month": "Juin",
        "createdAt": FieldValue.serverTimestamp(),
      });
      await _db.collection('events').add({
        "title": "Formation des Disciples",
        "description": "Étude biblique approfondie",
        "date": "2024-06-15",
        "time": "14:00",
        "location": "En ligne (Zoom)",
        "imageUrl": "assets/bible_reading.jpg",
        "day": "15",
        "month": "Juin",
        "createdAt": FieldValue.serverTimestamp(),
      });
      await _db.collection('events').add({
        "title": "Fête de l'Assomption",
        "description": "Célébration de la Vierge Marie",
        "date": "2024-08-15",
        "time": "10:30",
        "location": "Sanctuaire Marial National",
        "imageUrl": "assets/mary_praying.png",
        "day": "15",
        "month": "Août",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<AppResource>> getResources() {
    return _db.collection('resources').snapshots().map((snapshot) => snapshot.docs.map((doc) => AppResource.fromFirestore(doc.data(), doc.id)).toList());
  }

  Stream<List<Adresse>> getAddresses(String category) {
    return _db.collection('addresses').where('category', isEqualTo: category).snapshots().map((snapshot) => snapshot.docs.map((doc) => Adresse.fromFirestore(doc.data(), doc.id)).toList());
  }

  /// Nombre d'adresses enregistrées par catégorie, pour les compteurs de
  /// l'écran « Bons Plans ».
  Stream<Map<String, int>> getAddressCountsByCategory() {
    return _db.collection('addresses').snapshots().map((snapshot) {
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final category = (doc.data()['category'] ?? '').toString();
        if (category.isEmpty) continue;
        counts[category] = (counts[category] ?? 0) + 1;
      }
      return counts;
    });
  }

  Stream<List<BonPlan>> getBonsPlans() {
    return _db.collection('deals').orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => BonPlan.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> checkAndInitializeBonsPlansAndAddresses() async {
    final addressesSnapshot = await _db.collection('addresses').limit(1).get();
    if (addressesSnapshot.docs.isEmpty) {
      await _db.collection('addresses').add({
        "name": "Paroisse Saint Jean de Cocody",
        "category": "Paroisses",
        "location": "Cocody, Abidjan",
        "schedule": "Messes: Dim 7h, 9h, 11h, 18h30",
        "contact": "01 02 03 04 05",
      });
      await _db.collection('addresses').add({
        "name": "Sanctuaire Marial National",
        "category": "Paroisses",
        "location": "Cité Fairmont, Attécoubé",
        "schedule": "Messes: Dim 8h, 11h",
        "contact": "05 06 07 08 09",
      });
      await _db.collection('addresses').add({
        "name": "Librairie Paulines",
        "category": "Librairies",
        "location": "Plateau, Abidjan",
        "schedule": "Lun-Sam: 8h-18h",
        "contact": "07 08 09 10 11",
      });
    }

    final dealsSnapshot = await _db.collection('deals').limit(1).get();
    if (dealsSnapshot.docs.isEmpty) {
      await _db.collection('deals').add({
        "title": "-20% sur tous les livres",
        "description": "Dans toutes les librairies partenaires jusqu'au 30 juin 2026.",
        "actionText": "PROFITER MAINTENANT",
        "iconName": "local_offer_outlined",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<Post>> getPosts() {
    return _db.collection('posts').orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Post.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> addPost(String content, {String? imageUrl}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get user details
    final userDoc = await _db.collection('users').doc(user.uid).get();
    String authorName = "Utilisateur";
    String authorAvatarUrl = "assets/profile.jpg";
    
    if (userDoc.exists && userDoc.data() != null) {
      final data = userDoc.data()!;
      if (data.containsKey('fullName') && data['fullName'].toString().isNotEmpty) {
        authorName = data['fullName'].toString();
      }
      if (data.containsKey('photoUrl') && data['photoUrl'].toString().isNotEmpty) {
        authorAvatarUrl = data['photoUrl'].toString();
      }
    } else if (user.displayName != null && user.displayName!.isNotEmpty) {
      authorName = user.displayName!;
    }

    await _db.collection('posts').add({
      'authorName': authorName,
      'authorRole': "MEMBRE",
      'authorAvatarUrl': authorAvatarUrl,
      'content': content,
      'imageUrl': imageUrl,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleLikePost(String postId) async {
    // In a real app, we would track which user liked which post to toggle correctly.
    // For simplicity, we just increment here or we can use a subcollection.
    // Let's just increment for now as a simple example.
    await _db.collection('posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  /// Intentions communautaires, de la plus récente à la plus ancienne.
  ///
  /// Le tri est fait côté client : un `orderBy('createdAt')` masquerait les
  /// intentions déposées avant l'ajout de ce champ. Celles-ci sont renvoyées
  /// en fin de liste.
  Stream<List<Intention>> getIntentions() {
    return _db.collection('intentions').snapshots().map((snapshot) {
      final intentions = snapshot.docs
          .map((doc) => Intention.fromFirestore(doc.data(), doc.id))
          .toList();
      intentions.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return intentions;
    });
  }

  Future<void> addIntention(String title, String description) async {
    await _db.collection('intentions').add({
      'title': title,
      'description': description,
      'colorHex': '#C72127', // Default red color for intentions
      'count': 0,
      // Requis par la notification d'intention : `createdAt` sert à repérer les
      // nouveautés, `authorId` à ne pas alerter l'auteur de sa propre intention.
      'authorId': FirebaseAuth.instance.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementIntentionCount(String intentionId) async {
    await _db.collection('intentions').doc(intentionId).update({
      'count': FieldValue.increment(1),
    });
  }

  Stream<List<Annonce>> getAnnonces() {
    return _db.collection('annonces').snapshots().map((snapshot) => snapshot.docs.map((doc) => Annonce.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> checkAndInitializeAnnonces() async {
    final snapshot = await _db.collection('annonces').limit(1).get();
    if (snapshot.docs.isEmpty) {
      await _db.collection('annonces').add({
        "title": "Campagne de don de sang",
        "subtitle": "Ce samedi de 8h à 12h à la paroisse.",
        "colorHex": "#C72127",
      });
      await _db.collection('annonces').add({
        "title": "Nouveau parcours disponible",
        "subtitle": "Découvrez le parcours sur l'Esprit Saint.",
        "colorHex": "#5B4FC8",
      });
      await _db.collection('annonces').add({
        "title": "Réunion des responsables",
        "subtitle": "Jeudi à 18h en salle B.",
        "colorHex": "#D97706",
      });
      await _db.collection('annonces').add({
        "title": "Reprise de prière",
        "subtitle": "Le 26 Juin à 19h à la chapelle d'adoration.",
        "colorHex": "#0F766E", // Teal color
      });
    }
  }

  Stream<List<Office>> getOffices() {
    return _db.collection('offices').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => Office.fromFirestore(doc.data(), doc.id)).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> markOfficeAsCompleted(String officeId, String date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('offices_progress').doc('${officeId}_$date').set({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
      'officeId': officeId,
      'date': date,
    });
  }

  Stream<List<String>> getCompletedOffices(String date) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    
    return _db.collection('users').doc(user.uid).collection('offices_progress')
        .where('date', isEqualTo: date)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()['officeId'] as String).toList();
        });
  }

  // --- Neuvaines Progress ---
  Future<void> updateNeuvaineProgress(String neuvaineId, List<int> completedDays, bool isCompleted) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('neuvaines_progress').doc(neuvaineId).set({
      'completedDays': completedDays,
      'isCompleted': isCompleted,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> getNeuvaineProgress(String neuvaineId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value({'completedDays': <int>[], 'isCompleted': false});
    return _db.collection('users').doc(user.uid).collection('neuvaines_progress').doc(neuvaineId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final daysList = data['completedDays'] as List<dynamic>? ?? [];
        return {
          'completedDays': daysList.map((e) => e as int).toList(),
          'isCompleted': data['isCompleted'] ?? false,
        };
      }
      return {'completedDays': <int>[], 'isCompleted': false};
    });
  }

  // --- Intentions Communautaires Progress ---
  Future<void> addPrayedIntention(String intentionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).set({
      'prayedIntentions': FieldValue.arrayUnion([intentionId])
    }, SetOptions(merge: true));
  }

  Stream<List<String>> getPrayedIntentions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    return _db.collection('users').doc(user.uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final list = data['prayedIntentions'] as List<dynamic>? ?? [];
        return list.map((e) => e as String).toList();
      }
      return [];
    });
  }

  Stream<List<Neuvaine>> getNeuvaines() {
    return _db.collection('neuvaines').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Neuvaine.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<Challenge>> getChallenges() {
    return _db.collection('challenges').snapshots().map((snapshot) => snapshot.docs.map((doc) => Challenge.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> checkAndInitializeChallenges() async {
    final snapshot = await _db.collection('challenges').limit(1).get();
    if (snapshot.docs.isEmpty) {
      final defaultChallenges = [
        {
          "title": "Défi 7 jours de prière",
          "subtitle": "Prière Matinale",
          "description": "7 jours pour commencer ta journée avec Dieu et transformer ta vie.",
          "imageUrl": "assets/sunset_bg.jpg",
          "participants": 0,
          "durationDays": 7,
        },
        {
          "title": "Challenge Lecture Biblique",
          "subtitle": "Un chapitre par jour",
          "description": "Lis un chapitre des Proverbes chaque jour pendant 31 jours pour acquérir la sagesse.",
          "imageUrl": "assets/bible_reading.jpg",
          "participants": 0,
          "durationDays": 31,
        },
        {
          "title": "Jeûne d'Éther",
          "subtitle": "Jeûne et prière",
          "description": "Un défi de 3 jours de jeûne pour la percée spirituelle et la délivrance.",
          "imageUrl": "assets/mary_praying.png",
          "participants": 0,
          "durationDays": 3,
        },
        {
          "title": "Défi Gratitude",
          "subtitle": "Action de grâce",
          "description": "Trouve 3 raisons de rendre grâce à Dieu chaque soir pendant 14 jours.",
          "imageUrl": "assets/saint_therese.png",
          "participants": 0,
          "durationDays": 14,
        },
        {
          "title": "Challenge Chapelet",
          "subtitle": "Rosaire Quotidien",
          "description": "Prier le chapelet tous les jours pendant le mois de Marie.",
          "imageUrl": "assets/rosary.png",
          "participants": 0,
          "durationDays": 30,
        }
      ];

      for (var challenge in defaultChallenges) {
        await _db.collection('challenges').add(challenge);
      }
    }
  }

  Stream<Fraternity?> getFraternity() {
    return _db.collection('fraternities').limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Fraternity.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    });
  }

  Future<void> checkAndInitializeFraternity() async {
    final snapshot = await _db.collection('fraternities').limit(1).get();
    if (snapshot.docs.isEmpty) {
      await _db.collection('fraternities').add({
        "name": "Fratrie Cocody",
        "location": "Abidjan, Côte d'Ivoire",
        "memberCount": 45,
        "nextMeetingDate": "Samedi 25 Mai à 17h00",
        "nextMeetingLocation": "Centre JEP Cocody",
      });
    }
  }

  Future<void> incrementChallengeParticipants(String challengeId) async {
    await _db.collection('challenges').doc(challengeId).update({
      'participants': FieldValue.increment(1),
    });
  }

  /// Amorce les neuvaines livrées avec l'application, une seule fois.
  ///
  /// (Anciennement `createTestNeuvaine`, déclenchée par un bouton de debug :
  /// le contenu est réel, seul le mode de déclenchement était provisoire.)
  Future<void> checkAndInitializeNeuvaines() async {
    final existing = await _db.collection('neuvaines').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final neuvainesData = [
      {
        "title": "Neuvaine à Marie",
        "subtitle": "qui défait les nœuds",
        "description": "Priez cette neuvaine pour confier à la Vierge Marie les situations difficiles, les blocages et les souffrances de votre vie afin qu'elle les dénoue avec son amour maternel.",
        "imageUrl": "assets/mary_praying.png",
        "category": "marian",
        "duration": 9,
        "days": [
          {"dayNumber": 1, "title": "Jour 1 : Le premier nœud", "prayerText": "Sainte Marie, Vierge comblée de la présence de Dieu, pendant toute votre vie vous avez accepté avec une totale humilité la volonté du Père. Je vous remets ce nœud (nommer le problème) qui m'étouffe et me rend malheureux.\n\nVous qui avez contemplé le Cœur de Dieu, aidez-moi à voir au-delà de mes souffrances. Donnez-moi la force. Défiez ce nœud avec votre puissance maternelle. Amen."},
          {"dayNumber": 2, "title": "Jour 2 : L'abandon", "prayerText": "Marie, Mère très aimée, source de toutes les grâces, mon cœur se tourne vers vous aujourd'hui. Je reconnais que je suis pécheur et que j'ai besoin de votre aide. Je vous remets ce nœud (nommer le problème) que je ne peux pas défaire seul.\n\nAidez-moi à accepter ce qui m'arrive. Apprenez-moi à m'abandonner complètement à la volonté de Dieu. Défaites ce nœud avec vos mains douces de Mère. Amen."},
          {"dayNumber": 3, "title": "Jour 3 : La paix du cœur", "prayerText": "Mère médiatrice, Reine du Ciel, tournez vers moi vos yeux miséricordieux. Je dépose dans vos saintes mains ce nœud de ma vie qui trouble ma paix intérieure.\n\nVous êtes le refuge des affligés, la consolatrice des tristes. Accordez-moi une paix véritable. Que votre présence maternelle apaise mon cœur tourmenté. Amen."},
          {"dayNumber": 4, "title": "Jour 4 : La confiance restaurée", "prayerText": "Très Sainte Mère, je viens vous confier ce nœud qui a détruit ma confiance. Pendant trop longtemps, j'ai douté de la bonté de Dieu.\n\nApprenez-moi que rien n'est impossible pour celui qui croit. Vous qui avez cru aux paroles impossibles de l'Ange, enseignez-moi cette foi. Défaites ce nœud de doute et de désespoir. Amen."},
          {"dayNumber": 5, "title": "Jour 5 : La guérison des blessures", "prayerText": "Sainte Marie, vous qui avez souffert au pied de la Croix, vous qui connaissez toute douleur humaine, je vous supplie de guérir les blessures profondes causées par ce nœud.\n\nVersez le baume de votre miséricorde sur mes plaies. Défaites ce nœud de rancœur et de douleur. Que la paix de votre Fils guérisse ce qui en moi a été brisé. Amen."},
          {"dayNumber": 6, "title": "Jour 6 : La libération", "prayerText": "Mère de grâces, je viens à vous avec l'espoir ultime de la libération. Je reconnais que ce nœud m'a enchaîné et m'a empêché de vivre pleinement.\n\nBrisez ces chaînes avec votre puissance. Libérez-moi de ce qui m'oppresse. Défaites ce nœud et rendez-moi ma liberté. Amen."},
          {"dayNumber": 7, "title": "Jour 7 : L'acceptation", "prayerText": "Marie, Vierge Immaculée, modèle de résignation, aidez-moi à accepter ce nœud non comme une punition, mais comme une leçon d'amour.\n\nVous qui avez dit « Que ta volonté soit faite », enseignez-moi à accueillir la volonté de Dieu. Donnez-moi la grâce de l'acceptation sereine. Amen."},
          {"dayNumber": 8, "title": "Jour 8 : La transformation", "prayerText": "Très Sainte Mère, en ce huitième jour, je vous demande non seulement de défaire ce nœud, mais de le transformer en grâce.\n\nQue ma souffrance devienne semence de sainteté. Transformez mon épreuve en témoignage, ma douleur en compassion pour les autres. Amen."},
          {"dayNumber": 9, "title": "Jour 9 : L'action de grâce", "prayerText": "Marie, Mère bien-aimée, nous arrivons au terme de cette neuvaine. Je viens devant vous avec un cœur rempli de reconnaissance.\n\nJe vous remercie d'avoir écouté mes prières. Je vous remets définitivement ce nœud entre vos mains maternelles. Aidez-moi à vivre désormais dans la paix et l'abandon à la volonté divine. Amen."}
        ]
      },
      {
        "title": "Neuvaine au Saint-Esprit",
        "subtitle": "Pour demander les 7 dons",
        "description": "La plus ancienne de toutes les neuvaines. Elle se prie traditionnellement entre l'Ascension et la Pentecôte pour invoquer l'Esprit Consolateur et recevoir les sept dons divins.",
        "imageUrl": "assets/sunset_bg.jpg",
        "category": "pentecostal",
        "duration": 9,
        "days": [
          {"dayNumber": 1, "title": "Jour 1 : Viens, Esprit Créateur", "prayerText": "Esprit Saint, divin Consolateur, je vous adore comme mon Dieu véritable. Vous êtes l'amour infini du Père et du Fils.\n\nVenez en moi, ô Père des pauvres. Venez, dispensateur des grâces. Venez, lumière des cœurs. Remplissez mon âme de votre présence divine. Illuminez mes ténèbres. Échauffez mon cœur froid par l'amour du Christ. Amen."},
          {"dayNumber": 2, "title": "Jour 2 : Le don de Crainte de Dieu", "prayerText": "Viens, ô Esprit de Crainte de Dieu, pénètre tout mon être. Fais que je redoute de t'offenser, non par peur du châtiment, mais par amour pour ta majesté.\n\nCe don de crainte m'éloignera de tout ce qui peut te déplaire. Grave dans mon cœur la sainte crainte de Dieu, qui est le commencement de la sagesse. Amen."},
          {"dayNumber": 3, "title": "Jour 3 : Le don de Piété", "prayerText": "Viens, ô Esprit de Piété, prends possession de mon cœur. Incline-le à une véritable foi en toi, pour que je t'aime de tout mon cœur.\n\nDonne-moi l'esprit de prière sincère. Fais que je vénère Dieu comme un enfant vénère son père aimant. Accorde-moi une tendresse filiale envers le Très-Haut. Amen."},
          {"dayNumber": 4, "title": "Jour 4 : Le don de Science", "prayerText": "Viens, ô Esprit de Science, éclaire mon esprit afin que je comprenne les vérités de la foi. Enseigne-moi à lire les signes de ta présence.\n\nDonne-moi une connaissance profonde de tes lois. Aide-moi à distinguer le bien du mal, le vrai du faux. Amen."},
          {"dayNumber": 5, "title": "Jour 5 : Le don de Force", "prayerText": "Viens, ô Esprit de Force, revêts mon âme de courage. Rends-moi fort face aux tentations et aux épreuves de la vie.\n\nDonne-moi la force de tenir bon dans ma foi. Aide-moi à persévérer dans le bien. Fortifie mon cœur pour supporter les souffrances avec patience. Amen."},
          {"dayNumber": 6, "title": "Jour 6 : Le don de Conseil", "prayerText": "Viens, ô Esprit de Conseil, sois mon guide dans les décisions que je dois prendre. Illumine mon chemin quand je suis perdu dans l'incertitude.\n\nDonne-moi la sagesse de chercher ton aide avant d'agir. Accorde-moi la prudence. Fais que je sois sensible à ta voix intérieure. Amen."},
          {"dayNumber": 7, "title": "Jour 7 : Le don d'Intelligence", "prayerText": "Viens, ô Esprit d'Intelligence, ouvre mon esprit pour percevoir les mystères cachés de ta divine providence.\n\nDonne-moi l'intelligence spirituelle pour comprendre le sens caché des Écritures. Fais que je saisisse comment toutes choses travaillent ensemble pour le bien. Amen."},
          {"dayNumber": 8, "title": "Jour 8 : Le don de Sagesse", "prayerText": "Viens, ô Esprit de Sagesse, le plus élevé de tous tes dons. Gouverne ma vie entière par ta divine sagesse. Fais que je vois toutes les choses comme tu les vois.\n\nDonne-moi la sagesse de savoir que tu es le seul bien. Que ce don suprême fasse de moi un enfant véritablement sage. Amen."},
          {"dayNumber": 9, "title": "Jour 9 : La Pentecôte", "prayerText": "Esprit Saint, Consolateur promis, tu es descendu sur les Apôtres le jour de la Pentecôte. Descends maintenant sur moi avec puissance.\n\nJe vous demande les sept dons du Saint-Esprit. Transformez ma vie entière. Faites de moi un instrument de votre grâce. Que je sois rempli de votre feu divin et que je vive pleinement la vie nouvelle du Christ ressuscité. Amen."}
        ]
      },
      {
        "title": "Neuvaine à Saint Michel",
        "subtitle": "Archange protecteur",
        "description": "Neuvaine pour invoquer la protection de Saint Michel Archange contre les forces du mal et pour obtenir le courage spirituel.",
        "imageUrl": "assets/saint_michael.png",
        "category": "archangel",
        "duration": 9,
        "days": [
          {"dayNumber": 1, "title": "Jour 1 : Le courage spirituel", "prayerText": "Glorieux Archange Michel, chef des armées célestes, je vous invoke pour obtenir le courage spirituel. Vous qui avez vaincu le démon par votre force surhumaine, donnez-moi le courage de combattre mes propres faiblesses.\n\nAidez-moi à résister fermement à l'orgueil, à l'impatience et à toutes les tentations. Que je sois fort et courageux dans ma foi. Amen."},
          {"dayNumber": 2, "title": "Jour 2 : La protection contre le mal", "prayerText": "Glorieux Archange Michel, gardien de la justice divine, protégez-moi contre les pièges du démon. Enveloppez-moi de votre protection céleste.\n\nQue votre épée flamboyante chasse loin de moi tout ce qui pourrait nuire à mon âme. Que votre présence puissante me garde de tout mal spirituel et physique. Amen."},
          {"dayNumber": 3, "title": "Jour 3 : La clairvoyance spirituelle", "prayerText": "Glorieux Archange Michel, révélez-moi les ruses de l'ennemi. Donnez-moi la clairvoyance spirituelle pour discerner le bien du mal.\n\nAidez-moi à voir au-delà des apparences trompeuses. Que mes yeux soient ouverts aux réalités invisibles mais réelles du monde spirituel. Amen."},
          {"dayNumber": 4, "title": "Jour 4 : Obéissance à Dieu", "prayerText": "Glorieux Archange Michel, vous qui avez crié \"Qui est comme Dieu\" en défiant l'orgueil de Lucifer, aidez-moi à reconnaître l'autorité de Dieu.\n\nDonnez-moi le cœur obéissant d'un enfant envers le Père céleste. Que je refuse l'orgueil et que je m'humilie devant le Seigneur. Amen."},
          {"dayNumber": 5, "title": "Jour 5 : La justice divine", "prayerText": "Glorieux Archange Michel, ministre de la justice divine, aidez-moi à aimer la justice et à la défendre.\n\nObtient pour moi la force de toujours choisir ce qui est juste et bon. Aidez-moi à ne pas tolérer l'injustice. Que ma vie soit un témoignage de justesse. Amen."},
          {"dayNumber": 6, "title": "Jour 6 : La paix intérieure", "prayerText": "Glorieux Archange Michel, vous qui apportez la paix en bannissant les esprits mauvais, accordez-moi la paix intérieure.\n\nQue mon cœur soit apaisé de toutes les inquiétudes. Que ma conscience soit tranquille par la confiance en Dieu. Que je jouisse d'une paix profonde même au milieu des tempêtes. Amen."},
          {"dayNumber": 7, "title": "Jour 7 : Force contre les tentations", "prayerText": "Glorieux Archange Michel, vous dont la force invincible a défait Lucifer, donnez-moi la force de vaincre les tentations qui m'assaillent.\n\nPour chaque tentations, soyez mon soutien. Aidez-moi à triompher par la prière et la vertu. Que je sois un conquérant dans le Christ. Amen."},
          {"dayNumber": 8, "title": "Jour 8 : Protection de la famille", "prayerText": "Glorieux Archange Michel, protégez ma famille contre les attaques spirituelles et matérielles du malin.\n\nSoyez le gardien de ma maison. Que votre présence puissante éloigne tout mauvais esprit. Que chaque membre de ma famille soit sous votre protection. Amen."},
          {"dayNumber": 9, "title": "Jour 9 : La victoire finale", "prayerText": "Glorieux Archange Michel, vous qui êtes promis de vaincre définitivement Satan à la fin des temps, assurez-moi que Dieu vaincra complètement le mal.\n\nAidez-moi à avoir confiance que Dieu est plus fort que toute puissance mauvaise. Que je marche avec certitude vers la victoire finale en Christ. Amen."}
        ]
      },
      {
        "title": "Neuvaine à Saint Antoine",
        "subtitle": "Pour retrouver l'amour et les miracles",
        "description": "Neuvaine traditionnelle pour invoquer Saint Antoine de Padoue, saint des miracles, pour retrouver ce qui est perdu et obtenir son intercession.",
        "imageUrl": "assets/saint_anthony.png",
        "category": "saint",
        "duration": 9,
        "days": [
          {"dayNumber": 1, "title": "Jour 1 : La recherche spirituelle", "prayerText": "Glorieux Saint Antoine, luminaire de l'Église, je vous invoke pour m'aider à chercher la vérité et la sainteté. Vous avez consacré votre vie à la recherche de Dieu.\n\nAidez-moi à chercher d'abord le Royaume de Dieu et sa justice. Que je ne sois pas distrait par les choses temporelles. Que ma quête principale soit celle de connaître et d'aimer Dieu. Amen."},
          {"dayNumber": 2, "title": "Jour 2 : Retrouver ce qui est perdu", "prayerText": "Glorieux Saint Antoine, intercédez pour moi afin que je retrouve ce que j'ai perdu. Vous qui êtes le saint des miracles, aidez-moi à récupérer ce qui m'est cher.\n\nQue ce soit un objet, une relation, ou une grâce perdue, obtenez pour moi son retour. Mais surtout, aidez-moi à retrouver ma paix intérieure et ma connexion avec Dieu. Amen."},
          {"dayNumber": 3, "title": "Jour 3 : La chasteté et la pureté", "prayerText": "Glorieux Saint Antoine, modèle de chasteté absolue, aidez-moi à vivre dans la pureté du corps et de l'esprit.\n\nVous avez triomphé des plus grandes tentations. Donnez-moi la force de résister à la concupiscence. Que mon corps soit le temple de l'Esprit Saint. Amen."},
          {"dayNumber": 4, "title": "Jour 4 : L'éloquence et la sagesse", "prayerText": "Glorieux Saint Antoine, docteur de l'Église, grand prédicateur, aidez-moi à parler avec sagesse et éloquence.\n\nDonnez-moi les paroles justes pour défendre la foi, pour consoler les affligés, pour annoncer l'Évangile. Que mon langage soit doux mais ferme, charnu mais vrai. Amen."},
          {"dayNumber": 5, "title": "Jour 5 : La compassion envers les pauvres", "prayerText": "Glorieux Saint Antoine, ami des pauvres, vous qui avez donné tout ce que vous aviez, aidez-moi à avoir compassion des nécessiteux.\n\nDonnez-moi un cœur généreux. Aidez-moi à voir Jésus dans chaque pauvre. Que je sois prodigue dans mon amour pour les malheureux. Amen."},
          {"dayNumber": 6, "title": "Jour 6 : La paix dans les conflits", "prayerText": "Glorieux Saint Antoine, vous qui avez rétabli la paix entre ennemis, aidez-moi à trouver la paix dans les conflits qui m'affectent.\n\nIntercédez pour que les désaccords se résolvent justement. Donnez-moi la sagesse de réconciliation. Que la paix règne où je vais. Amen."},
          {"dayNumber": 7, "title": "Jour 7 : L'humilité et l'obéissance", "prayerText": "Glorieux Saint Antoine, modèle d'humilité, vous qui avez obéi sans question, aidez-moi à cultiver l'humilité véritable.\n\nÔtez de moi tout orgueil. Donnez-moi le cœur d'un enfant obéissant envers Dieu et l'Église. Que je serve avec humilité et douceur. Amen."},
          {"dayNumber": 8, "title": "Jour 8 : Les miracles et les prodiges", "prayerText": "Glorieux Saint Antoine, à travers vous Dieu a accompli de nombreux miracles, aidez-moi à croire à la puissance de Dieu.\n\nObtenez pour moi le miracle dont j'ai besoin, non seulement matériel mais surtout spirituel. Que je sois témoin de la puissance divine. Amen."},
          {"dayNumber": 9, "title": "Jour 9 : L'amour de Dieu et du prochain", "prayerText": "Glorieux Saint Antoine, grand amant de Dieu, aidez-moi à brûler du même amour divin que vous.\n\nQue mon cœur sois embrasé du feu de l'amour de Dieu. Que cet amour se manifeste dans mon service au prochain. Que je sois tout à Dieu et que ma vie soit un hymne de louanges. Amen."}
        ]
      },
      {
        "title": "Neuvaine au Sacré-Cœur",
        "subtitle": "De Jésus",
        "description": "Neuvaine traditionnelle pour vénérer le Sacré-Cœur de Jésus et obtenir les grâces de conversion, d'amour et de rédemption.",
        "imageUrl": "assets/sacred_heart.png",
        "category": "christological",
        "duration": 9,
        "days": [
          {"dayNumber": 1, "title": "Jour 1 : L'amour infini du Cœur de Jésus", "prayerText": "Doux Jésus, Cœur adorable, brûlant d'amour pour nous, je vous adore du plus profond de mon âme. Votre Cœur renferme un amour infini pour chaque créature.\n\nOuvert pour nous à la Croix, coulant du sang et de l'eau, votre Cœur est la source de toute grâce et de tout salut. Que mon cœur s'unisse au vôtre dans un amour sans réserve. Amen."},
          {"dayNumber": 2, "title": "Jour 2 : La réparation des offenses", "prayerText": "Doux Jésus, votre Cœur a été blessé par l'ingratitude et l'indifférence des hommes. Combien l'offensent par le péché et le blasphème!\n\nPour réparer les offenses faites à votre Cœur sacré, je vous offre ma vie entière. Accceptez-la comme une petite compensation pour les péchés du monde. Amen."},
          {"dayNumber": 3, "title": "Jour 3 : L'Eucharistie, cœur du Cœur", "prayerText": "Doux Jésus, dans l'Eucharistie, vous vous donnez à nous de manière toute spéciale. Vous nous offrez votre Cœur, votre Corps, votre Sang.\n\nFaites que je reçoive l'Eucharistie avec la ferveur et le respect qu'elle mérite. Que chaque communion soit pour moi une transformation en amour. Amen."},
          {"dayNumber": 4, "title": "Jour 4 : La consolation du Cœur de Jésus", "prayerText": "Doux Jésus, votre Cœur souffre de l'indifférence des hommes. Combien peu l'aiment vraiment! Combien peu lui rendent hommage!\n\nPour consoler votre Cœur affligé, je vous promise une dévotion plus ardente. Que je sois un instrument de consolation pour vous. Que je aide à transformer des cœurs froids en cœurs aimants. Amen."},
          {"dayNumber": 5, "title": "Jour 5 : La conversion des pécheurs", "prayerText": "Doux Jésus, votre Cœur désire ardemment la conversion de tous les pécheurs. Vous avez versé votre Sang pour leur salut.\n\nObtennez la conversion des âmes égarées. Amenez les pécheurs à la repentance. Que ceux qui vous ont oublié reviennent à vous. Que je sois un apôtre de conversion. Amen."},
          {"dayNumber": 6, "title": "Jour 6 : L'amour envers le prochain", "prayerText": "Doux Jésus, de votre Cœur coule une charité sans limite pour tous les hommes. Vous aimez chacun avec une tendresse infinie.\n\nApprenez-moi à aimer comme vous aimez. Donnez-moi un cœur compatissant envers les souffrants. Que je voie votre visage dans chaque homme. Amen."},
          {"dayNumber": 7, "title": "Jour 7 : La paix véritable", "prayerText": "Doux Jésus, vous êtes la paix véritable. Votre Cœur offre la paix à tous ceux qui viennent à vous.\n\nDonnez-moi la paix qui dépasse tout entendement. Que ma confiance en votre Cœur sacré m'affranchisse de toute crainte. Que je trouve le repos en vous. Amen."},
          {"dayNumber": 8, "title": "Jour 8 : La consécration au Cœur de Jésus", "prayerText": "Doux Jésus, je me consacre entièrement à votre Cœur sacré. Je vous offre ma vie, mes pensées, mes paroles, mes actions.\n\nQue tout ce que je fais soit pour la gloire de votre Cœur. Que ma vie entière soit une manifestation de votre amour. Acceptez ma consécration. Amen."},
          {"dayNumber": 9, "title": "Jour 9 : La triomphe du Cœur de Jésus", "prayerText": "Doux Jésus, je crois que votre Cœur triomphera et que tous les cœurs seront ramenés à vous. Que le monde entier reconnaisse et adore votre Cœur sacré.\n\nHâtez ce grand triomphe. Que votre Cœur règne en souverain sur tous les cœurs humains. Que le Cœur de Marie intercède pour ce triomphe. Amen."}
        ]
      },
      {
        "title": "Neuvaine à Sainte Thérèse",
        "subtitle": "De l'Enfant Jésus",
        "description": "Neuvaine à la petite docteur de l'Église pour obtenir son intercession et la grâce de sa « petite voie » d'amour enfantin.",
        "imageUrl": "assets/saint_therese.png",
        "category": "saint",
        "duration": 9,
        "days": [
          {"dayNumber": 1, "title": "Jour 1 : La petite voie", "prayerText": "Bien-aimée Sainte Thérèse, petite docteur de l'Église, vous qui avez trouvé la sainteté dans les petites choses, aidez-moi à embrasser votre « petite voie ».\n\nJe ne peux pas accomplir de grandes choses, mais je peux faire les petites choses avec un grand amour. Apprenez-moi à devenir petit, confiant, et aimant envers Dieu. Amen."},
          {"dayNumber": 2, "title": "Jour 2 : L'amour enfantin pour Dieu", "prayerText": "Bien-aimée Sainte Thérèse, vous qui avez aimé Dieu avec le cœur confiant d'un enfant, aidez-moi à développer cette confiance absolue.\n\nFaites que je me repose contre le cœur de Dieu comme un enfant dans les bras de sa mère. Que je sois libre de toute anxiété. Amen."},
          {"dayNumber": 3, "title": "Jour 3 : La joie dans les petites épreuves", "prayerText": "Bien-aimée Sainte Thérèse, vous qui avez trouvé la joie même dans les petites souffrances du cloître, aidez-moi à offrir mes petites douleurs.\n\nQue je ne murmure pas contre les contrariétés mineures. Que je les offre avec amour pour le salut des âmes. Amen."},
          {"dayNumber": 4, "title": "Jour 4 : L'abandon à la Providence", "prayerText": "Bien-aimée Sainte Thérèse, vous qui vous êtes abandonnée complètement à la Providence, aidez-moi à faire confiance à Dieu.\n\nFaites que je ne m'inquiète plus pour demain. Que je sache que Dieu sait déjà tout et pourvoit à tout. Amen."},
          {"dayNumber": 5, "title": "Jour 5 : L'amour pour les missions", "prayerText": "Bien-aimée Sainte Thérèse, vous qui avez aimé apportez l'Évangile aux extrémités de la terre, vous qui n'aviez pas quitté le couvent mais qui aviez embrassé toutes les missions, aidez-moi à avoir un cœur missionnaire.\n\nFaites que je travaille pour la conversion du monde. Amen."},
          {"dayNumber": 6, "title": "Jour 6 : La paix dans les sécheresses spirituelles", "prayerText": "Bien-aimée Sainte Thérèse, vous qui avez souffert de l'obscurité de la foi, aidez-moi à rester fidèle même quand je ne ressens pas la présence de Dieu.\n\nQue je crois sans sentir, que j'aime sans consolation. Amen."},
          {"dayNumber": 7, "title": "Jour 7 : L'humilité authentique", "prayerText": "Bien-aimée Sainte Thérèse, vous qui avez reconnu votre petitesse et votre faiblesse, aidez-moi à cultiver une véritable humilité.\n\nFaites que je ne me glorifie jamais de mes œuvres. Que je sache que sans Dieu je ne suis rien. Amen."},
          {"dayNumber": 8, "title": "Jour 8 : L'amour des âmes", "prayerText": "Bien-aimée Sainte Thérèse, vous qui avez aimé les âmes avec une passion brûlante, aidez-moi à partager cette passion.\n\nFaites que je prie pour les conversion des pécheurs. Que je désire ardemment que toutes les âmes connaissent et aiment Jésus. Amen."},
          {"dayNumber": 9, "title": "Jour 9 : L'amour radical", "prayerText": "Bien-aimée Sainte Thérèse, vous qui avez aimé Jésus de tout votre cœur, de toute votre âme, de toute votre force, aidez-moi à aimer ainsi.\n\nFaites que mon amour pour Jésus soit la raison principale de ma vie. Que tout ce que je fais soit pour l'amour de Lui. Amen."}
        ]
      },
      {
        "title": "Neuvaine à Notre-Dame",
        "subtitle": "De Lourdes",
        "description": "Neuvaine à la Vierge Marie telle qu'elle s'est manifestée à Lourdes, pour demander les guérisons spirituelles et physiques.",
        "imageUrl": "assets/notre_dame_lourdes.png",
        "category": "marian",
        "duration": 9,
        "days": [
          {"dayNumber": 1, "title": "Jour 1 : La pureté", "prayerText": "Notre-Dame de Lourdes, Immaculée Conception, vous qui vous êtes manifestée comme celle sans péché, aidez-moi à aspirer à la pureté.\n\nGardez-moi du péché. Préservez-moi de tout ce qui pourrait souiller mon âme. Que je devienne pur comme vous êtes pure. Amen."},
          {"dayNumber": 2, "title": "Jour 2 : La confiance filiale", "prayerText": "Notre-Dame de Lourdes, Mère bien-aimée, vous êtes venue consoler Bernadette dans sa pauvreté. Consolez-moi aussi dans mes misères.\n\nFaites que je vous fasse confiance comme un enfant. Que je sois assuré de votre amour maternel. Amen."},
          {"dayNumber": 3, "title": "Jour 3 : La guérison spirituelle", "prayerText": "Notre-Dame de Lourdes, Mère des guérisons, guérissez-moi de mes blessures spirituelles. Guérissez les maladies de mon âme causées par le péché.\n\nQue je sois restauré dans la grâce. Que mon cœur soit lavé et purifié. Amen."},
          {"dayNumber": 4, "title": "Jour 4 : La prière et la pénitence", "prayerText": "Notre-Dame de Lourdes, vous avez insisté sur la prière et la pénitence. Aidez-moi à augmenter ma vie de prière.\n\nDonnez-moi le désir de faire pénitence pour mes péchés et pour les péchés du monde. Que je ne sois pas las de prier. Amen."},
          {"dayNumber": 5, "title": "Jour 5 : La guérison physique", "prayerText": "Notre-Dame de Lourdes, où tant de guérisons miraculeuses se sont opérées, daignez guérir ma maladie [nommer la maladie] ou celle de [nommer la personne].\n\nCependant, avant tout, guérissez nos âmes. Donnez-nous la foi pour accepter votre volonté si la guérison physique n'est pas accordée. Amen."},
          {"dayNumber": 6, "title": "Jour 6 : La conversion des pécheurs", "prayerText": "Notre-Dame de Lourdes, obtiennez la conversion de tous ceux qui se sont éloignés de Dieu. Ramenez les pécheurs endurcis à la miséricorde de votre Fils.\n\nQue ceux qui blasphèment se repentent. Que ceux qui vivent dans le péché trouvent le chemin du retour. Amen."},
          {"dayNumber": 7, "title": "Jour 7 : La paix et la justice", "prayerText": "Notre-Dame de Lourdes, Reine de la paix, établissez la paix dans le monde et dans les cœurs humains.\n\nQue les guerres cessent. Que la justice règne. Que les nations vivent en harmonie. Que chaque cœur trouve la paix en Dieu. Amen."},
          {"dayNumber": 8, "title": "Jour 8 : La protection maternelle", "prayerText": "Notre-Dame de Lourdes, protégez-moi et ma famille sous votre manteau. Soyez notre refuge et notre forteresse.\n\nÉloignez de nous tout mal. Gardez-nous du danger et du péché. Que nous jouissions toujours de votre protection. Amen."},
          {"dayNumber": 9, "title": "Jour 9 : L'action de grâce", "prayerText": "Notre-Dame de Lourdes, nous arrivons à la fin de cette neuvaine. Je vous remercie de votre intercession. Je vous remercie pour votre amour maternel.\n\nJe vous remets tous mes besoins entre vos mains. Que votre volonté soit faite. Merci de votre aide constante. Amen."}
        ]
      },
      {
        "title": "Neuvaine à Saint Jude",
        "subtitle": "Thaddée - Des causes impossibles",
        "description": "Neuvaine pour invoquer Saint Jude Thaddée, apôtre de Jésus, patron des causes difficiles et désespérées, pour obtenir son aide dans les situations sans espoir.",
        "imageUrl": "assets/saint_jude.png",
        "category": "saint",
        "duration": 9,
        "days": [
          {"dayNumber": 1, "title": "Jour 1 : L'apostolat zélé", "prayerText": "Glorieux Saint Jude, apôtre de Jésus, vous qui avez prêché l'Évangile avec un zèle ardent, aidez-moi à avoir du zèle pour ma foi.\n\nDonnez-moi le courage de témoigner de ma croyance. Que je sois un apôtre pour ceux qui m'entourent. Que mon amour pour Jésus soit visible et contagieux. Amen."},
          {"dayNumber": 2, "title": "Jour 2 : Les causes difficiles", "prayerText": "Glorieux Saint Jude, vous qui êtes invoqué pour les causes impossibles, aidez-moi dans ma situation difficile.\n\nCe problème qui semble insoluble, vous pouvez l'intercéder. Tout ce qui est difficile pour l'homme est possible pour Dieu par votre prière. Accordez-moi le miracle dont j'ai besoin. Amen."},
          {"dayNumber": 3, "title": "Jour 3 : L'espérance même dans le désespoir", "prayerText": "Glorieux Saint Jude, quand tout semble perdu et que le désespoir me menace, aidez-moi à garder espoir.\n\nFaites-moi comprendre qu'il n'y a jamais de cause totalement désespérée. Dieu est toujours capable de faire merveille. Que mon espoir en Lui soit inébranlable. Amen."},
          {"dayNumber": 4, "title": "Jour 4 : L'intercession puissante", "prayerText": "Glorieux Saint Jude, votre prière est puissante auprès du trône de Dieu. Intercédez pour moi auprès de Jésus votre maître.\n\nPrésent au Seigneur ma situation en détail. Plaidez pour moi avec votre autorité d'apôtre. Que votre prière soit entendue. Amen."},
          {"dayNumber": 5, "title": "Jour 5 : La confiance en la miséricorde", "prayerText": "Glorieux Saint Jude, vous qui avez connu la miséricorde infinie de Jésus, aidez-moi à croire à cette miséricorde pour moi-même.\n\nLe Seigneur ne peut refuser aucune demande fondée sur sa miséricorde. Aidez-moi à le lui demander avec confiance. Amen."},
          {"dayNumber": 6, "title": "Jour 6 : La persévérance dans la prière", "prayerText": "Glorieux Saint Jude, aidez-moi à persévérer dans la prière sans me lasser. Que je continue à prier même si je n'ai pas encore reçu ce que je demande.\n\nJésus a enseigné que nous devons frapper et chercher sans cesse. Donnez-moi la persévérance. Amen."},
          {"dayNumber": 7, "title": "Jour 7 : L'acceptation de la volonté divine", "prayerText": "Glorieux Saint Jude, tout en demandant avec confiance, aidez-moi à accepter la volonté de Dieu quelles qu'en soient les conséquences.\n\nQue ma demande soit accordée ou refusée, que ce soit pour mon bien. Donnez-moi la grâce d'accepter avec sérénité. Amen."},
          {"dayNumber": 8, "title": "Jour 8 : La transformation par la foi", "prayerText": "Glorieux Saint Jude, même si je n'obtiens pas ce que je demande matériellement, transformez-moi par ma foi en vous.\n\nQue cette épreuve renforce mon âme. Que cette situation me rapproche de Dieu. Que je sois sanctifié par cette attente. Amen."},
          {"dayNumber": 9, "title": "Jour 9 : Le triomphe de la grâce", "prayerText": "Glorieux Saint Jude, en ce dernier jour de notre neuvaine, je crois que vous et Jésus opérerez le miracle ou l'aide dont j'ai besoin.\n\nQue la grâce de Dieu triomphe dans ma vie. Que je sois transformé par votre intercession. Merci d'être un défenseur des causes impossibles. Amen."}
        ]
      }
    ];
    for (var neuvaine in neuvainesData) {
      await _db.collection('neuvaines').add(neuvaine);
    }
  }

  Future<void> updatePrayerTimes(String uid, Map<String, String> prayerTimes) async {
    try {
      await _db.collection('users').doc(uid).update({
        'prayerTimes': prayerTimes,
      });
    } catch (e) {
      await _db.collection('users').doc(uid).set({
        'prayerTimes': prayerTimes,
      }, SetOptions(merge: true));
    }
  }

  Stream<Map<String, String>> getPrayerTimes(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null && snapshot.data()!.containsKey('prayerTimes')) {
        return Map<String, String>.from(snapshot.data()!['prayerTimes']);
      }
      return {
        'Matin': '06:30',
        'Midi': '12:00',
        'Soir': '21:30',
      };
    });
  }

  // --- Metanoia ---
  Stream<List<MetanoiaLevel>> getMetanoiaLevels() {
    return _db.collection('metanoia_levels').orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MetanoiaLevel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<MetanoiaLesson>> getMetanoiaLessons(String levelId) {
    return _db.collection('metanoia_lessons')
        .where('levelId', isEqualTo: levelId)
        .snapshots()
        .map((snapshot) {
      var lessons = snapshot.docs.map((doc) => MetanoiaLesson.fromFirestore(doc)).toList();
      lessons.sort((a, b) => a.order.compareTo(b.order));
      return lessons;
    });
  }

  Future<void> markLessonAsCompleted(String uid, String lessonId) async {
    await _db.collection('users').doc(uid).collection('metanoia_progress').doc(lessonId).set({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<String>> getUserMetanoiaProgress(String uid) {
    return _db.collection('users').doc(uid).collection('metanoia_progress').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // --- Parcours Recommandés ---
  Future<void> updateParcoursProgress(String uid, String parcoursId, int completedDays) async {
    await _db.collection('users').doc(uid).collection('parcours_progress').doc(parcoursId).set({
      'completedDays': completedDays,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<int> getParcoursProgress(String uid, String parcoursId) {
    return _db.collection('users').doc(uid).collection('parcours_progress').doc(parcoursId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['completedDays'] as int? ?? 0;
      }
      return 0;
    });
  }

  Stream<ParcoursContent?> getParcoursContent(String parcoursId) {
    return _db.collection('parcours_content').doc(parcoursId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return ParcoursContent.fromFirestore(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  /// Tous les parcours proposés dans « Grandir dans la foi », triés par ordre
  /// d'affichage.
  Stream<List<ParcoursContent>> getAllParcours() {
    return _db.collection('parcours_content').snapshots().map((snapshot) {
      final parcours = snapshot.docs
          .map((doc) => ParcoursContent.fromFirestore(doc.data(), doc.id))
          .toList();
      parcours.sort((a, b) => a.order.compareTo(b.order));
      return parcours;
    });
  }

  /// Métadonnées d'affichage des parcours livrés avec l'application.
  ///
  /// Elles sont réappliquées en `merge` à chaque démarrage : les installations
  /// qui possèdent déjà les documents (créés avant l'ajout de ces champs) sont
  /// ainsi complétées, sans jamais écraser les leçons.
  static const Map<String, Map<String, dynamic>> _parcoursMetadata = {
    'ecoute_dieu': {
      'subtitle': "Apprends à discerner sa voix au quotidien.",
      'kicker': "Parcours Recommandé",
      'category': "Spiritualité",
      'iconName': "landscape",
      'colorHex': "#FFA500",
      'imageAsset': "assets/sunset_bg.jpg",
      'isNew': true,
      'order': 1,
    },
    'suivre_jesus': {
      'subtitle': "Les fondamentaux pour marcher avec Lui.",
      'kicker': "Parcours Fondamental",
      'category': "Fondamentaux",
      'iconName': "add",
      'colorHex': "#795548",
      'imageAsset': "assets/sunset_bg.jpg",
      'isNew': false,
      'order': 2,
    },
    'esprit_saint': {
      'subtitle': "Accueillir sa présence et ses dons.",
      'kicker': "Parcours Spirituel",
      'category': "Spiritualité",
      'iconName': "local_fire_department",
      'colorHex': "#F44336",
      'imageAsset': "assets/sunset_bg.jpg",
      'isNew': false,
      'order': 3,
    },
  };

  /// Amorce et répare le contenu des parcours.
  ///
  /// Trois cas : le parcours n'existe pas et il est créé ; il existe avec les
  /// leçons d'attente des premières versions (« Contenu complet de la
  /// méditation… ») et elles sont remplacées par le contenu réel ; il existe
  /// avec un contenu rédigé depuis la console, et on n'y touche pas.
  Future<void> checkAndInitializeParcoursContent() async {
    for (final parcours in parcoursCatalogue) {
      final docRef = _db.collection('parcours_content').doc(parcours.id);
      final doc = await docRef.get();

      final lecons = parcours.lecons
          .map((l) => {
                'dayNumber': l.numero,
                'title': l.titre,
                'desc': l.resume,
                'content': l.contenu,
              })
          .toList();

      final metadonnees = _parcoursMetadata[parcours.id];

      if (!doc.exists) {
        await docRef.set({
          'title': parcours.titre,
          if (metadonnees != null) ...metadonnees,
          'lessons': lecons,
        });
        continue;
      }

      // Métadonnées d'affichage (icône, couleur, catégorie, ordre).
      if (metadonnees != null) {
        await docRef.set(metadonnees, SetOptions(merge: true));
      }

      final lessonsExistantes = (doc.data()?['lessons'] as List?) ?? const [];
      final aReparer = lessonsExistantes.isEmpty ||
          lessonsExistantes.any((l) =>
              l is Map && (l['content'] ?? '').toString().contains(texteDAttenteParcours));

      if (aReparer) {
        await docRef.set({'lessons': lecons}, SetOptions(merge: true));
      }
    }
  }

  /// Amorce le chemin Métanoïa.
  ///
  /// Le contenu de Métanoïa n'était semé nulle part : les niveaux et surtout
  /// leurs leçons devaient être créés à la main, faute de quoi l'écran
  /// Métanoïa et la carte « Continuer mon parcours » restaient vides.
  ///
  /// La base peut déjà porter ses propres niveaux. Dans ce cas on ne crée rien
  /// à côté : on se contente de garnir en leçons ceux qui n'en ont aucune.
  Future<void> checkAndInitializeMetanoia() async {
    final snapshot = await _db.collection('metanoia_levels').get();

    final idsCatalogue = metanoiaCatalogue.map((n) => n.id).toSet();
    final niveauxSemes = snapshot.docs.where((d) => idsCatalogue.contains(d.id)).toList();
    final niveauxDeLaBase = snapshot.docs.where((d) => !idsCatalogue.contains(d.id)).toList();

    // Réparation : une version antérieure de cet amorçage a pu ajouter les
    // niveaux du catalogue à côté de ceux de la base. On les retire.
    if (niveauxDeLaBase.isNotEmpty && niveauxSemes.isNotEmpty) {
      for (final doc in niveauxSemes) {
        final lecons =
            await _db.collection('metanoia_lessons').where('levelId', isEqualTo: doc.id).get();
        for (final lecon in lecons.docs) {
          await lecon.reference.delete();
        }
        await doc.reference.delete();
      }
    }

    // Aucun niveau propre à la base : on installe le chemin complet.
    if (niveauxDeLaBase.isEmpty) {
      for (final niveau in metanoiaCatalogue) {
        final refNiveau = _db.collection('metanoia_levels').doc(niveau.id);
        await refNiveau.set({
          'title': niveau.titre,
          'subtitle': niveau.sousTitre,
          'order': niveau.ordre,
          'imageAsset': niveau.imageAsset,
          'MetanoiaId': niveau.id,
          'totalLessons': niveau.lecons.length,
        }, SetOptions(merge: true));

        await _semerLeconsMetanoia(refNiveau.id, niveau.lecons);
      }
      return;
    }

    // Des niveaux existent : on ne touche qu'à ceux qui sont vides, en leur
    // donnant les leçons du catalogue de même rang.
    niveauxDeLaBase.sort((a, b) {
      final ordreA = int.tryParse('${a.data()['order'] ?? 99}') ?? 99;
      final ordreB = int.tryParse('${b.data()['order'] ?? 99}') ?? 99;
      return ordreA.compareTo(ordreB);
    });

    for (int i = 0; i < niveauxDeLaBase.length && i < metanoiaCatalogue.length; i++) {
      final doc = niveauxDeLaBase[i];

      final dejaDesLecons = await _db
          .collection('metanoia_lessons')
          .where('levelId', isEqualTo: doc.id)
          .limit(1)
          .get();
      if (dejaDesLecons.docs.isNotEmpty) continue;

      final lecons = metanoiaCatalogue[i].lecons;
      await _semerLeconsMetanoia(doc.id, lecons);
      await doc.reference.set({'totalLessons': lecons.length}, SetOptions(merge: true));
    }
  }

  Future<void> _semerLeconsMetanoia(String levelId, List<LeconCatalogue> lecons) async {
    for (final lecon in lecons) {
      final refLecon = _db.collection('metanoia_lessons').doc('${levelId}_l${lecon.numero}');
      if ((await refLecon.get()).exists) continue;

      await refLecon.set({
        'levelId': levelId,
        'title': lecon.titre,
        'subtitle': lecon.resume,
        'content': lecon.contenu,
        'order': lecon.numero,
      });
    }
  }

  /// Sème le catalogue de versets. Chaque verset a un identifiant stable :
  /// l'amorçage ne crée que ce qui manque et ne réécrit jamais un verset
  /// modifié depuis la console.
  Future<void> checkAndInitializeVersets() async {
    for (final verset in versetsCatalogue) {
      final docRef = _db.collection('daily_verses').doc(verset.id);
      if ((await docRef.get()).exists) continue;

      await docRef.set({
        'content': verset.contenu,
        'reference': verset.reference,
        'order': verset.ordre,
      });
    }
  }

  /// Rang du jour dans le catalogue.
  ///
  /// Le calcul repose sur le nombre de jours écoulés depuis une date de
  /// référence : le verset change à minuit, il est le même pour tout le monde,
  /// et il ne dépend d'aucun appel réseau — donc il fonctionne hors ligne.
  static int indexDuJour(int total, {DateTime? jour}) {
    if (total <= 0) return 0;

    final aujourdHui = jour ?? DateTime.now();
    final jours = DateTime(aujourdHui.year, aujourdHui.month, aujourdHui.day)
        .difference(DateTime(2024, 1, 1))
        .inDays;

    return ((jours % total) + total) % total;
  }

  /// Verset du jour : un verset différent chaque jour, pris dans
  /// `daily_verses`. Tant que la collection n'est pas semée, on retombe sur
  /// l'ancien document unique `daily_content/verset_du_jour`.
  Stream<Map<String, String>> getVersetDuJour() {
    return _db.collection('daily_verses').snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        final doc = await _db.collection('daily_content').doc('verset_du_jour').get();
        final data = doc.data();
        return {
          'content': (data?['content']?.toString().isNotEmpty ?? false)
              ? data!['content'].toString()
              : versetParDefaut.contenu,
          'reference': (data?['reference']?.toString().isNotEmpty ?? false)
              ? data!['reference'].toString()
              : versetParDefaut.reference,
        };
      }

      final versets = snapshot.docs.toList()
        ..sort((a, b) {
          final ordreA = int.tryParse('${a.data()['order'] ?? 0}') ?? 0;
          final ordreB = int.tryParse('${b.data()['order'] ?? 0}') ?? 0;
          if (ordreA != ordreB) return ordreA.compareTo(ordreB);
          return a.id.compareTo(b.id);
        });

      final data = versets[indexDuJour(versets.length)].data();
      return {
        'content': (data['content'] ?? versetParDefaut.contenu).toString(),
        'reference': (data['reference'] ?? versetParDefaut.reference).toString(),
      };
    });
  }

  Future<void> checkAndInitializeDailyContent() async {
    final doc = await _db.collection('daily_content').doc('verset_du_jour').get();
    if (!doc.exists) {
      await _db.collection('daily_content').doc('verset_du_jour').set({
        "content": "Je suis le pain de vie. Celui qui vient à moi n'aura jamais faim, et celui qui croit en moi n'aura jamais soif.",
        "reference": "Jean 6:35",
      });
    }

    final intentionDoc = await _db.collection('daily_content').doc('intention_communautaire').get();
    if (!intentionDoc.exists) {
      await _db.collection('daily_content').doc('intention_communautaire').set({
        "title": "Pour les jeunes en examen",
        "count": 0,
        "imageUrl": "assets/hands.png",
      });
    }

    // Citations d'ambiance des écrans Office des Heures et Carnet spirituel,
    // éditables sans redéploiement.
    const citations = {
      'citation_office': {
        "content": "Sept fois le jour je te loue pour\ntes justes jugements.",
        "reference": "Psaume 119, 164",
      },
      'citation_carnet': {
        "content": "Ta parole est une lampe à mes pieds,\net une lumière sur mon sentier.",
        "reference": "Psaume 119, 105",
      },
    };

    for (final entry in citations.entries) {
      final citationDoc = await _db.collection('daily_content').doc(entry.key).get();
      if (!citationDoc.exists) {
        await _db.collection('daily_content').doc(entry.key).set(entry.value);
      }
    }
  }

  /// Citation d'ambiance d'un écran (`citation_office`, `citation_carnet`…).
  Stream<Map<String, String>> getCitation(String docId) {
    return _db.collection('daily_content').doc(docId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return {
        'content': data?['content']?.toString() ?? '',
        'reference': data?['reference']?.toString() ?? '',
      };
    });
  }

  /// Parcours réellement en cours : celui dont la progression a été mise à
  /// jour le plus récemment. Remplace l'ancien document
  /// `progress/current_parcours`, qui n'était jamais écrit et laissait donc la
  /// carte « Continuer mon parcours » vide en permanence.
  Stream<Map<String, dynamic>?> getCurrentParcours(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('parcours_progress')
        .orderBy('lastUpdated', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return {
        'parcoursId': doc.id,
        'completedDays': doc.data()['completedDays'] ?? 0,
      };
    });
  }

  Future<DocumentSnapshot> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  // === NOUVELLES METHODES STATISTIQUES ===

  Stream<Map<String, int>> getUserStats(String uid) {
    return _db.collection('users').doc(uid).collection('stats').doc('global').snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        // Initialiser ou retourner 0 par défaut
        return {
          'chapelets': 0,
          'versets': 0,
          'parcours': 0,
          'prieres': 0,
        };
      }
      final data = snapshot.data()!;
      return {
        'chapelets': data['chapelets'] ?? 0,
        'versets': data['versets'] ?? 0,
        'parcours': data['parcours'] ?? 0,
        'prieres': data['prieres'] ?? 0,
      };
    });
  }

  Stream<Map<String, int>> getUserIntentionsStats(String uid) {
    return _db.collection('users').doc(uid).collection('intentions').snapshots().map((snapshot) {
      int actives = 0;
      int exaucees = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'active';
        if (status == 'exaucee') {
          exaucees++;
        } else {
          actives++;
        }
      }
      return {
        'actives': actives,
        'exaucees': exaucees,
      };
    });
  }

  Stream<Map<String, int>> getUserCarnetStats(String uid) {
    return _db.collection('users').doc(uid).collection('carnet').snapshots().map((snapshot) {
      int rhemas = 0;
      int exaucees = 0;
      int meditations = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] ?? '';
        if (type == 'rhema') rhemas++;
        else if (type == 'priere_exaucee') exaucees++;
        else if (type == 'meditation') meditations++;
      }
      return {
        'rhemas': rhemas,
        'exaucees': exaucees,
        'meditations': meditations,
      };
    });
  }

  // --- FIN METHODES STATISTIQUES ---

  // === GAMIFICATION & QUIZ ===

  Stream<Map<String, dynamic>> getUserGamificationStats(String uid) {
    return _db.collection('users').doc(uid).collection('stats').doc('gamification').snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return {
          'level': 1,
          'title': 'Chercheur',
          'points': 0,
          'streak': 0,
        };
      }
      final data = snapshot.data()!;
      return {
        'level': data['level'] ?? 1,
        'title': data['title'] ?? 'Chercheur',
        'points': data['points'] ?? 0,
        'streak': data['streak'] ?? 0,
        'lastDailyChallengeDate': data['lastDailyChallengeDate'] ?? '',
      };
    });
  }

  Stream<List<Map<String, dynamic>>> getLeaderboard() {
    return _db.collection('gamification_leaderboard')
      .orderBy('points', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      });
  }

  /// Supprime les faux joueurs semés par les anciennes versions de l'app
  /// (« Marie Grace », « Thomas K. »…). Ils se reconnaissent à l'absence de
  /// champ `uid` : toute entrée légitime est créée par [updateGamificationPoints]
  /// et porte l'identifiant du joueur.
  Future<void> purgeLeaderboardMockPlayers() async {
    final snapshot = await _db.collection('gamification_leaderboard').get();
    for (final doc in snapshot.docs) {
      if (!doc.data().containsKey('uid')) {
        await doc.reference.delete();
      }
    }
  }

  /// Nombre de quiz réellement disponibles par catégorie.
  Stream<Map<String, int>> getQuizCountsByCategory() {
    return _db.collection('gamification_quizzes').snapshots().map((snapshot) {
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final category = (doc.data()['category'] ?? '').toString();
        if (category.isEmpty) continue;
        counts[category] = (counts[category] ?? 0) + 1;
      }
      return counts;
    });
  }

  Stream<Map<String, dynamic>?> getDailyChallenge() {
    return _db.collection('gamification_daily_challenge').doc('today').snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data();
    });
  }

  Stream<List<Map<String, dynamic>>> getQuizCategories() {
    return _db.collection('gamification_quiz_categories').orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getGamesList() {
    return _db.collection('gamification_games').orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Amorce le contenu Quiz & Jeux (défi du jour, catégories, quiz et leurs
/// questions) au premier lancement. Ce contenu est réel, pas fictif.
  Future<void> checkAndInitializeQuizAndGames() async {
    // Challenge
    final challenge = await _db.collection('gamification_daily_challenge').doc('today').get();
    if (!challenge.exists) {
      await _db.collection('gamification_daily_challenge').doc('today').set({
        'title': "Connais-tu bien\nl'Évangile de Jean ?",
        'description': "Réponds à 5 questions\net gagne 50 points !",
        'points': 50,
      });
    }

    // Catégories : documents à identifiant stable, et icône désignée par son
    // nom — une catégorie ajoutée en base affiche ainsi la bonne icône sans
    // qu'il faille toucher au code.
    const categories = [
      {'id': 'bible', 'title': 'Bible', 'icon': 'menu_book', 'color': 0xFF5B4FC8, 'order': 1},
      {'id': 'catechisme', 'title': 'Catéchisme', 'icon': 'church_outlined', 'color': 0xFFFF9800, 'order': 2},
      {'id': 'saints', 'title': 'Saints', 'icon': 'person_outline', 'color': 0xFF2196F3, 'order': 3},
      {'id': 'vie_chretienne', 'title': 'Vie chrétienne', 'icon': 'eco_outlined', 'color': 0xFF4CAF50, 'order': 4},
    ];

    final categoriesExistantes = await _db.collection('gamification_quiz_categories').get();
    final titresExistants = {
      for (final doc in categoriesExistantes.docs) (doc.data()['title'] ?? '').toString(): doc.reference
    };

    for (final cat in categories) {
      final titre = cat['title'] as String;
      final donnees = Map<String, dynamic>.from(cat)..remove('id');

      // Les catégories semées par les versions précédentes portent un
      // identifiant aléatoire : on les complète sur place plutôt que d'en
      // créer un doublon.
      final existante = titresExistants[titre];
      if (existante != null) {
        await existante.set({'icon': donnees['icon'], 'order': donnees['order']}, SetOptions(merge: true));
      } else {
        await _db.collection('gamification_quiz_categories').doc(cat['id'] as String).set(donnees);
      }
    }

    // Jeux : trois règles appliquées à la même banque de quiz. Le champ `mode`
    // est ce qui rend la carte jouable ; il est aussi posé sur les jeux semés
    // par les versions précédentes.
    const jeux = [
      {
        'id': 'chemin_de_la_foi',
        'title': 'Chemin de la Foi',
        'desc': 'Avance à ton rythme, sans limite de temps.',
        'badge': 'Classique',
        'badgeColor': 0xFF5B4FC8,
        'img': 'assets/sunset_bg.jpg',
        'mode': 'classique',
        'order': 1,
      },
      {
        'id': 'tresor_biblique',
        'title': 'Trésor Biblique',
        'desc': '15 secondes par question, points majorés.',
        'badge': 'Chrono',
        'badgeColor': 0xFFFF9800,
        'img': 'assets/mountain_bg.png',
        'mode': 'chrono',
        'order': 2,
      },
      {
        'id': 'puzzle_des_versets',
        'title': 'Puzzle des Versets',
        'desc': 'Tout est mélangé, aucune erreur permise, points doublés.',
        'badge': 'Mélange',
        'badgeColor': 0xFF4CAF50,
        'img': 'assets/mountain_bg.png',
        'mode': 'melange',
        'order': 3,
      },
    ];

    final jeuxExistants = await _db.collection('gamification_games').get();
    final jeuxParTitre = {
      for (final doc in jeuxExistants.docs) (doc.data()['title'] ?? '').toString(): doc.reference
    };

    for (final jeu in jeux) {
      final titre = jeu['title'] as String;
      final donnees = Map<String, dynamic>.from(jeu)..remove('id');

      final existant = jeuxParTitre[titre];
      if (existant != null) {
        await existant.set({
          'mode': donnees['mode'],
          'desc': donnees['desc'],
          'badge': donnees['badge'],
          'badgeColor': donnees['badgeColor'],
        }, SetOptions(merge: true));
      } else {
        await _db.collection('gamification_games').doc(jeu['id'] as String).set(donnees);
      }
    }

    // Questions pour le défi du jour
    final questions = await _db.collection('gamification_quizzes').doc('defi_du_jour').collection('questions').limit(1).get();
    if (questions.docs.isEmpty) {
      final mockQuestions = [
        {
          'question': 'Qui a écrit l\'Évangile selon Saint Jean ?',
          'options': ['L\'Apôtre Pierre', 'L\'Apôtre Jean', 'Luc le Médecin', 'Paul de Tarse'],
          'correctIndex': 1,
          'order': 1
        },
        {
          'question': 'Quel est le premier miracle de Jésus selon l\'Évangile de Jean ?',
          'options': ['La multiplication des pains', 'La guérison de l\'aveugle', 'L\'eau changée en vin', 'La marche sur l\'eau'],
          'correctIndex': 2,
          'order': 2
        },
        {
          'question': 'Comment s\'appelle l\'homme ressuscité par Jésus dans Jean 11 ?',
          'options': ['Nicodème', 'Lazare', 'Zachée', 'Bartimée'],
          'correctIndex': 1,
          'order': 3
        },
        {
          'question': 'Que dit Jésus être dans Jean 8:12 ?',
          'options': ['Le Bon Berger', 'Le Pain de Vie', 'La Lumière du monde', 'La Porte'],
          'correctIndex': 2,
          'order': 4
        },
        {
          'question': 'Qui était le souverain sacrificateur l\'année de la mort de Jésus ?',
          'options': ['Hérode', 'Pilate', 'Anne', 'Caïphe'],
          'correctIndex': 3,
          'order': 5
        },
      ];
      for (var q in mockQuestions) {
        await _db.collection('gamification_quizzes').doc('defi_du_jour').collection('questions').add(q);
      }
    }

    // Quiz : chaque entrée du catalogue a un identifiant stable, on ne crée
    // donc que ce qui manque. Une catégorie restée vide se remplit d'elle-même
    // au prochain lancement, sans toucher aux quiz déjà en base.
    for (final quiz in quizCatalogue) {
      final docRef = _db.collection('gamification_quizzes').doc(quiz.id);
      if ((await docRef.get()).exists) continue;

      await docRef.set({
        'title': quiz.title,
        'category': quiz.category,
        'level': quiz.level,
        'points': quiz.points,
        'order': quiz.order,
      });

      for (int i = 0; i < quiz.questions.length; i++) {
        final question = quiz.questions[i];
        await docRef.collection('questions').doc('q${i + 1}').set({
          'question': question.question,
          'options': question.options,
          'correctIndex': question.correctIndex,
          'order': i + 1,
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> getQuizQuestions(String quizId) async {
    final snapshot = await _db.collection('gamification_quizzes').doc(quizId).collection('questions').orderBy('order').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Quiz d'une catégorie, du plus accessible au plus exigeant. Le tri est
  /// fait ici plutôt que par Firestore : les quiz semés par les anciennes
  /// versions n'ont pas de champ `order` et seraient sinon écartés du résultat.
  Future<List<Map<String, dynamic>>> getQuizzesByCategory(String categoryTitle) async {
    final snapshot = await _db.collection('gamification_quizzes').where('category', isEqualTo: categoryTitle).get();
    final quizzes = snapshot.docs.map((doc) => doc.data()..addAll({'id': doc.id})).toList();

    quizzes.sort((a, b) {
      final ordreA = int.tryParse('${a['order'] ?? 99}') ?? 99;
      final ordreB = int.tryParse('${b['order'] ?? 99}') ?? 99;
      if (ordreA != ordreB) return ordreA.compareTo(ordreB);
      return '${a['title']}'.compareTo('${b['title']}');
    });

    return quizzes;
  }

  Future<void> updateGamificationPoints(String uid, int pointsWon, {String? quizId}) async {
    final docRef = _db.collection('users').doc(uid).collection('stats').doc('gamification');
    final docSnap = await docRef.get();
    
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (docSnap.exists) {
      final data = docSnap.data()!;
      final newPoints = (data['points'] ?? 0) + pointsWon;
      final newLevel = (newPoints ~/ 100) + 1;
      
      Map<String, dynamic> updates = {
        'points': newPoints,
        'level': newLevel,
      };
      
      if (quizId == 'defi_du_jour') {
        updates['lastDailyChallengeDate'] = todayStr;
      }
      
      await docRef.update(updates);
    } else {
      Map<String, dynamic> newData = {
        'points': pointsWon,
        'level': (pointsWon ~/ 100) + 1,
        'streak': 1,
        'title': 'Chercheur',
      };
      
      if (quizId == 'defi_du_jour') {
        newData['lastDailyChallengeDate'] = todayStr;
      }
      
      await docRef.set(newData);
    }

    // Classement : on crée l'entrée si elle n'existe pas encore, sinon aucun
    // joueur réel n'y apparaîtrait jamais.
    final leaderRef = await _db.collection('gamification_leaderboard').where('uid', isEqualTo: uid).get();
    if (leaderRef.docs.isNotEmpty) {
      await leaderRef.docs.first.reference.update({'points': FieldValue.increment(pointsWon)});
    } else {
      final profile = await _db.collection('users').doc(uid).get();
      final profileData = profile.data();

      await _db.collection('gamification_leaderboard').add({
        'uid': uid,
        'name': (profileData?['fullName']?.toString().isNotEmpty ?? false)
            ? profileData!['fullName']
            : 'Un membre',
        'avatar': profileData?['photoUrl'] ?? '',
        'points': pointsWon,
      });
    }
  }

  // --- FIN GAMIFICATION ---

  Future<void> checkAndInitializeUserObjectifs(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).collection('objectifs').limit(1).get();
    if (snapshot.docs.isEmpty) {
      await _db.collection('users').doc(uid).collection('objectifs').doc('priere_jour').set({
        'title': 'Prier chaque jour',
        'icon': 'pan_tool_outlined',
        'colorHex': '#FFA500', // Orange
        'currentCount': 0,
        'targetCount': 365,
        'lastCompletedDate': null,
      });
      await _db.collection('users').doc(uid).collection('objectifs').doc('evangile_jour').set({
        'title': "Lire l'Évangile quotidiennement",
        'icon': 'menu_book',
        'colorHex': '#5B4FC8', // Violet
        'currentCount': 0,
        'targetCount': 365,
        'lastCompletedDate': null,
      });
      await _db.collection('users').doc(uid).collection('objectifs').doc('terminer_metanoia').set({
        'title': 'Terminer Métanoia',
        'icon': 'menu_book_outlined',
        'colorHex': '#4CAF50', // Vert
        'currentCount': 0,
        'targetCount': 100, // Ajuster selon le nombre de leçons totales
        'lastCompletedDate': null,
      });
    }
  }

  Stream<List<Objectif>> getUserObjectifs(String uid) {
    return _db.collection('users').doc(uid).collection('objectifs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Objectif.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  Future<bool> validerEvangileDuJour(String uid) async {
    final docRef = _db.collection('users').doc(uid).collection('objectifs').doc('evangile_jour');
    final doc = await docRef.get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final Timestamp? lastTimestamp = data['lastCompletedDate'] as Timestamp?;
      
      final now = DateTime.now();
      
      // Si la dernière validation n'existe pas, ou n'est pas aujourd'hui
      if (lastTimestamp == null || 
          lastTimestamp.toDate().year != now.year || 
          lastTimestamp.toDate().month != now.month || 
          lastTimestamp.toDate().day != now.day) {
        
        await docRef.update({
          'currentCount': FieldValue.increment(1),
          'lastCompletedDate': FieldValue.serverTimestamp(),
        });
        return true; // Validé avec succès pour aujourd'hui
      } else {
        return false; // Déjà validé aujourd'hui
      }
    }
    return false;
  }

  Stream<List<CarnetNote>> getUserCarnetNotes(String uid) {
    return _db.collection('users').doc(uid).collection('carnet')
        .orderBy('date', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CarnetNote.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addCarnetNote(String uid, CarnetNote note) async {
    await _db.collection('users').doc(uid).collection('carnet').add(note.toMap());
  }

  Stream<Regularite> getRegularite(String uid) {
    return _db.collection('users').doc(uid).collection('stats').doc('regularite').snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Regularite.fromFirestore(snapshot.data()!);
      } else {
        return Regularite(streak: 0, weekDays: {'L': false, 'M1': false, 'M2': false, 'J': false, 'V': false, 'S': false, 'D': false});
      }
    });
  }

  Future<bool> validerJourDePriere(String uid) async {
    final docRef = _db.collection('users').doc(uid).collection('stats').doc('regularite');
    final doc = await docRef.get();
    
    final now = DateTime.now();
    final weekdayMap = {1: 'L', 2: 'M1', 3: 'M2', 4: 'J', 5: 'V', 6: 'S', 7: 'D'};
    final currentDayStr = weekdayMap[now.weekday]!;

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final Timestamp? lastTimestamp = data['lastActiveDate'] as Timestamp?;
      int streak = data['streak'] ?? 0;
      Map<String, bool> weekDays = Map<String, bool>.from(data['weekDays'] ?? {
        'L': false, 'M1': false, 'M2': false, 'J': false, 'V': false, 'S': false, 'D': false
      });

      if (lastTimestamp != null) {
        final lastDate = lastTimestamp.toDate();
        final difference = DateTime(now.year, now.month, now.day).difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;

        if (difference == 0) {
          return false; // Déjà validé aujourd'hui
        } else if (difference == 1) {
          streak += 1; // Streak maintenu
        } else {
          // Streak perdu
          streak = 1;
          // Si on est dans une nouvelle semaine (ex: lundi), ou plus de 7 jours, on reset la semaine
          weekDays = {'L': false, 'M1': false, 'M2': false, 'J': false, 'V': false, 'S': false, 'D': false};
        }
      } else {
        streak = 1;
      }
      
      // Si c'est lundi, et qu'on a un streak, mais qu'on change de semaine calendaire, on devrait logiquement reset weekDays.
      // Pour simplifier, si now.weekday == 1 (Lundi), on clear les autres jours.
      if (now.weekday == 1 && (lastTimestamp == null || lastTimestamp.toDate().weekday != 1)) {
         weekDays = {'L': false, 'M1': false, 'M2': false, 'J': false, 'V': false, 'S': false, 'D': false};
      }

      weekDays[currentDayStr] = true;

      await docRef.set({
        'streak': streak,
        'lastActiveDate': FieldValue.serverTimestamp(),
        'weekDays': weekDays,
      }, SetOptions(merge: true));
      
      return true;
    } else {
      // Première validation
      await docRef.set({
        'streak': 1,
        'lastActiveDate': FieldValue.serverTimestamp(),
        'weekDays': {
          'L': now.weekday == 1, 
          'M1': now.weekday == 2, 
          'M2': now.weekday == 3, 
          'J': now.weekday == 4, 
          'V': now.weekday == 5, 
          'S': now.weekday == 6, 
          'D': now.weekday == 7
        },
      });
      return true;
    }
  }

  // === PRÉPARATION À LA CONFESSION ===

  Stream<List<ExamenItem>> getExamenConscience() {
    return _db.collection('examen_conscience').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => ExamenItem.fromFirestore(doc.data(), doc.id)).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> checkAndInitializeExamenConscience() async {
    final snapshot = await _db.collection('examen_conscience').limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final items = [
      {"category": "dieu", "order": 1, "text": "Ai-je douté de l'amour ou de l'existence de Dieu ?"},
      {"category": "dieu", "order": 2, "text": "Ai-je négligé ma prière quotidienne ? Ai-je prié sans attention ?"},
      {"category": "dieu", "order": 3, "text": "Ai-je manqué la messe le dimanche par ma propre faute ?"},
      {"category": "dieu", "order": 4, "text": "Ai-je prononcé le nom de Dieu en vain ou sans respect ?"},
      {"category": "dieu", "order": 5, "text": "Ai-je mis ma confiance dans des superstitions, voyants ou horoscopes ?"},
      {"category": "prochain", "order": 1, "text": "Ai-je manqué de respect ou d'obéissance envers mes parents ?"},
      {"category": "prochain", "order": 2, "text": "Ai-je entretenu de la haine, de la colère ou un désir de vengeance ?"},
      {"category": "prochain", "order": 3, "text": "Ai-je refusé de pardonner à quelqu'un qui m'a offensé ?"},
      {"category": "prochain", "order": 4, "text": "Ai-je menti, calomnié, ou détruit la réputation d'une autre personne ?"},
      {"category": "prochain", "order": 5, "text": "Ai-je volé ou endommagé le bien d'autrui sans chercher à le réparer ?"},
      {"category": "prochain", "order": 6, "text": "Ai-je incité quelqu'un d'autre à pécher ?"},
      {"category": "soi", "order": 1, "text": "Ai-je consenti à des pensées, regards ou actes impurs ?"},
      {"category": "soi", "order": 2, "text": "Ai-je abusé de nourriture, d'alcool, de drogue ou d'écrans ?"},
      {"category": "soi", "order": 3, "text": "Ai-je été orgueilleux, vaniteux ou égoïste ?"},
      {"category": "soi", "order": 4, "text": "Ai-je été paresseux dans mes devoirs (travail, études, famille) ?"},
    ];

    for (var item in items) {
      await _db.collection('examen_conscience').add(item);
    }
  }

  Stream<ConfessionContent?> getConfessionContent() {
    return _db.collection('app_content').doc('confession').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return ConfessionContent.fromFirestore(snapshot.data()!);
      }
      return null;
    });
  }

  Future<void> checkAndInitializeConfessionContent() async {
    final doc = await _db.collection('app_content').doc('confession').get();
    if (doc.exists) return;

    await _db.collection('app_content').doc('confession').set({
      "introText": "Prends un moment de silence. L'examen de conscience t'aide à reconnaître tes péchés pour mieux les confier à la miséricorde de Dieu.",
      "acteTitle": "Acte de Contrition",
      "acteIntro": "À réciter avant de recevoir l'absolution, quand le prêtre vous y invite :",
      "acteText": "« Mon Dieu, j'ai un très grand regret de vous avoir offensé, parce que vous êtes infiniment bon, infiniment aimable, et que le péché vous déplaît. Je prends la ferme résolution, avec le secours de votre sainte grâce, de ne plus vous offenser et de faire pénitence. Amen. »",
      "steps": [
        {"number": "1", "title": "Signe de croix", "description": "Au nom du Père, du Fils et du Saint-Esprit. Amen."},
        {"number": "2", "title": "Demande de bénédiction", "description": "« Bénissez-moi mon Père, parce que j'ai péché. Ma dernière confession remonte à... »"},
        {"number": "3", "title": "Aveu des péchés", "description": "Citez les péchés que vous avez relevés lors de votre examen de conscience."},
        {"number": "4", "title": "Conseil et Pénitence", "description": "Le prêtre vous donne quelques mots de conseil et une pénitence (prière ou action)."},
        {"number": "5", "title": "L'Absolution", "description": "Le prêtre vous donne l'absolution, qui pardonne tous vos péchés."},
      ],
    });
  }

  Stream<List<String>> getExamenSelection(String uid) {
    return _db.collection('users').doc(uid).collection('confession_prep').doc('current').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final list = snapshot.data()!['checkedItems'] as List<dynamic>? ?? [];
        return list.map((e) => e.toString()).toList();
      }
      return <String>[];
    });
  }

  Future<void> toggleExamenItem(String uid, String itemId, bool isChecked) async {
    await _db.collection('users').doc(uid).collection('confession_prep').doc('current').set({
      'checkedItems': isChecked
          ? FieldValue.arrayUnion([itemId])
          : FieldValue.arrayRemove([itemId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Enregistre la confession dans l'historique de l'utilisateur et remet l'examen à zéro.
  Future<void> enregistrerConfession(String uid) async {
    final prepRef = _db.collection('users').doc(uid).collection('confession_prep').doc('current');
    final prep = await prepRef.get();
    final checked = prep.exists ? (prep.data()?['checkedItems'] as List<dynamic>? ?? []) : [];

    await _db.collection('users').doc(uid).collection('confessions').add({
      'date': FieldValue.serverTimestamp(),
      'itemsCount': checked.length,
    });

    await prepRef.set({
      'checkedItems': <String>[],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // === PARCOURS DU JOUR (tâches quotidiennes) ===

  Stream<List<DailyTask>> getDailyTasks() {
    return _db.collection('daily_tasks').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => DailyTask.fromFirestore(doc.data(), doc.id)).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> checkAndInitializeDailyTasks() async {
    final snapshot = await _db.collection('daily_tasks').limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final tasks = [
      {"title": "Prière du matin", "icon": "wb_sunny_outlined", "action": "", "order": 1},
      {"title": "Lecture de l'Évangile", "icon": "menu_book", "action": "evangile", "order": 2},
      {"title": "Chapelet", "icon": "circle_outlined", "action": "chapelet", "order": 3},
      {"title": "Méditation", "icon": "favorite_border", "action": "", "order": 4},
      {"title": "Examen du soir", "icon": "nightlight_round", "action": "", "order": 5},
    ];

    for (var task in tasks) {
      await _db.collection('daily_tasks').add(task);
    }
  }

  // --- Intentions personnelles ajoutées à la carte « Mon parcours aujourd'hui » ---

  /// Étapes personnelles de l'utilisateur, affichées à la suite des étapes
  /// communes dans la carte du parcours du jour.
  Stream<List<DailyTask>> getCustomDailyTasks(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('custom_daily_tasks')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => DailyTask.fromFirestore(doc.data(), doc.id, isCustom: true))
          .toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  /// Ajoute une intention personnelle au parcours du jour. L'ordre est calculé
  /// à partir de la dernière étape existante pour conserver l'ordre d'ajout.
  Future<void> addCustomDailyTask(String uid, String title, {String icon = 'favorite_border'}) async {
    final collection = _db.collection('users').doc(uid).collection('custom_daily_tasks');
    final existing = await collection.get();
    final maxOrder = existing.docs.fold<int>(0, (max, doc) {
      final order = int.tryParse(doc.data()['order'].toString()) ?? 0;
      return order > max ? order : max;
    });

    await collection.add({
      'title': title.trim(),
      'icon': icon,
      'action': '',
      'order': maxOrder + 1,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCustomDailyTask(String uid, String taskId, String title, {String? icon}) async {
    await _db.collection('users').doc(uid).collection('custom_daily_tasks').doc(taskId).set({
      'title': title.trim(),
      if (icon != null) 'icon': icon,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Supprime l'intention et retire au passage sa trace du suivi du jour pour
  /// que la progression reste cohérente.
  Future<void> deleteCustomDailyTask(String uid, String taskId, String date) async {
    await _db.collection('users').doc(uid).collection('custom_daily_tasks').doc(taskId).delete();
    await _db.collection('users').doc(uid).collection('daily_tasks_progress').doc(date).set({
      'completedTasks': FieldValue.arrayRemove([taskId]),
    }, SetOptions(merge: true));
  }

  /// Identifiant du document de progression pour un jour donné (format yyyy-MM-dd).
  static String dayKey(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  Stream<List<String>> getDailyTasksProgress(String uid, String date) {
    return _db.collection('users').doc(uid).collection('daily_tasks_progress').doc(date).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final list = snapshot.data()!['completedTasks'] as List<dynamic>? ?? [];
        return list.map((e) => e.toString()).toList();
      }
      return <String>[];
    });
  }

  Future<void> toggleDailyTask(String uid, String date, String taskId, bool isCompleted) async {
    await _db.collection('users').doc(uid).collection('daily_tasks_progress').doc(date).set({
      'completedTasks': isCompleted
          ? FieldValue.arrayUnion([taskId])
          : FieldValue.arrayRemove([taskId]),
      'date': date,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // === FAVORIS ===

  Stream<List<Favori>> getUserFavoris(String uid) {
    return _db.collection('users').doc(uid).collection('favoris')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Favori.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> addFavori(String uid, Favori favori) async {
    await _db.collection('users').doc(uid).collection('favoris').add(favori.toMap());
  }

  Future<void> removeFavori(String uid, String favoriId) async {
    await _db.collection('users').doc(uid).collection('favoris').doc(favoriId).delete();
  }

  /// Ajoute le favori s'il n'existe pas encore, le retire sinon. Renvoie true si ajouté.
  Future<bool> toggleFavori(String uid, Favori favori) async {
    final existing = await _db.collection('users').doc(uid).collection('favoris')
        .where('type', isEqualTo: favori.type)
        .where('title', isEqualTo: favori.title)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.delete();
      return false;
    }

    await addFavori(uid, favori);
    return true;
  }
}

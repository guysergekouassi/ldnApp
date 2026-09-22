import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/post_model.dart';
import '../models/event_model.dart';
import '../models/annonce_model.dart';
import '../models/challenge_model.dart';
import '../models/fraternity_model.dart';
import '../components/user_avatar.dart';
import '../services/share_service.dart';
import 'create_post_screen.dart';
import 'all_posts_screen.dart';
import 'all_events_screen.dart';
import 'temoignages_screen.dart';
import 'groupes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sondage_model.dart';

class CommunauteScreen extends StatelessWidget {
  CommunauteScreen({Key? key}) : super(key: key);

  final FirestoreService _firestoreService = FirestoreService();

  /// Grappe d'avatars illustrant un effectif. Les documents `challenges` et
  /// `fraternities` ne stockent qu'un compteur, pas la liste des membres : on
  /// affiche donc autant de pastilles génériques que de membres, plafonnées à 4.
  Widget _buildAvatarCluster(int count) {
    final int bubbles = count.clamp(0, 4);
    if (bubbles == 0) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        bubbles,
        (index) => const Align(
          widthFactor: 0.6,
          child: UserAvatar(imageReference: null, radius: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildFilDActualite(context),
                  const SizedBox(height: 15),
                  _buildSondage(context),
                  const SizedBox(height: 15),
                  _buildDefisChallenges(),
                  const SizedBox(height: 15),
                  _buildEvenementsAvenir(context),
                  const SizedBox(height: 15),
                  _buildMaFratrie(context),
                  const SizedBox(height: 15),
                  _buildAnnonces(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/sunset_bg.jpg"), 
                fit: BoxFit.cover,
                alignment: Alignment.topRight,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFF8F9FA).withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_alt, color: Colors.orange, size: 28),
                        const SizedBox(width: 10),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.orange, Colors.red],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            "Communauté",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  "Nous avançons ensemble dans la foi.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 70), 
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String number, String title, String subtitle, {Widget? action}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 8),
              action,
            ],
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ),
      ],
    );
  }

  Widget _buildFilDActualite(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            "1",
            "Fil d'actualité",
            "Partage une exhortation ou ton témoignage.",
            action: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.edit, color: Colors.orange, size: 12),
                    SizedBox(width: 4),
                    Text("Publier", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          StreamBuilder<Set<String>>(
            stream: _firestoreService.getLikedPostIds(),
            builder: (context, aimesSnapshot) {
          final aimes = aimesSnapshot.data ?? <String>{};
          return StreamBuilder<List<Post>>(
            stream: _firestoreService.getPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("Aucun post disponible.", style: TextStyle(color: Colors.grey));
              }

              final post = snapshot.data!.first;
              final estAime = aimes.contains(post.id);
              final dateFormat = DateFormat('dd/MM HH:mm');

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: avatarImageProvider(post.authorAvatarUrl),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFF3F0FF), borderRadius: BorderRadius.circular(5)),
                                          child: Text(post.authorRole, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF5B4FC8), fontSize: 8, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.more_horiz, color: Colors.grey, size: 16),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(dateFormat.format(post.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(width: 4),
                                const Icon(Icons.public, color: Colors.grey, size: 10),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    post.content,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), height: 1.3),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(post.imageUrl!, width: 80, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 80, height: 60, color: Colors.grey[200])),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                LikeButton(
                                  estAime: estAime,
                                  compteur: post.likes,
                                  onTap: () => _firestoreService.toggleLikePost(post.id),
                                ),
                                const Spacer(),
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => ShareService.sharePost(
                                    authorName: post.authorName,
                                    content: post.content,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.reply, color: Colors.grey, size: 16),
                                        SizedBox(width: 5),
                                        Text("Partager", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllPostsScreen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Voir tous les partages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              );
            }
          );
            },
          ),
        ],
      ),
    );
  }

  /// Sondage de la semaine : une question courte, un résultat immédiat.
  ///
  /// Le vote est le geste d'engagement le moins coûteux qui existe — un appui,
  /// et l'on voit aussitôt où se situe la communauté. La carte disparaît tant
  /// qu'aucun sondage n'est publié, plutôt que d'afficher un cadre vide.
  /// Dates de rencontre d'une fratie, l'ancien champ unique servant de
  /// repli pour les documents semés avant que la liste n'existe.
  List<String> _prochainesRencontres(Fraternity fraternite) {
    if (fraternite.rencontres.isNotEmpty) return fraternite.rencontres;
    if (fraternite.nextMeetingDate.isNotEmpty) return [fraternite.nextMeetingDate];
    return const [];
  }

  Widget _buildSondage(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<Sondage?>(
      stream: _firestoreService.getSondageEnCours(),
      builder: (context, sondageSnapshot) {
        final sondage = sondageSnapshot.data;
        if (sondage == null) return const SizedBox.shrink();

        return StreamBuilder<int?>(
          stream: uid != null
              ? _firestoreService.getMonVote(uid, sondage.id)
              : Stream.value(null),
          builder: (context, voteSnapshot) {
            final monVote = voteSnapshot.data;

            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("2", "La question de la semaine", sondage.contexte),
                  const SizedBox(height: 15),
                  Text(
                    sondage.question,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A), height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(
                    sondage.options.length,
                    (i) => _buildOptionSondage(context, sondage, i, monVote, uid),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sondage.totalVoix == 0
                        ? "Personne n'a encore répondu. Ouvre le bal."
                        : "${sondage.totalVoix} réponse${sondage.totalVoix > 1 ? 's' : ''}"
                            "${monVote == null ? ' · ton avis manque' : ''}",
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionSondage(
    BuildContext context,
    Sondage sondage,
    int index,
    int? monVote,
    String? uid,
  ) {
    final aVote = monVote != null;
    final estMonChoix = monVote == index;
    final part = sondage.partDe(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: aVote ? null : () => _voter(context, sondage, index, uid),
        child: Stack(
          children: [
            // Barre de résultat : affichée seulement après le vote, pour ne pas
            // influencer la réponse de celui qui n'a pas encore choisi.
            if (aVote)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: part,
                  child: Container(
                    decoration: BoxDecoration(
                      color: estMonChoix
                          ? const Color(0xFF5B4FC8).withOpacity(0.18)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: estMonChoix ? const Color(0xFF5B4FC8) : const Color(0xFFE5E7EB),
                  width: estMonChoix ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    estMonChoix
                        ? Icons.check_circle
                        : (aVote ? Icons.circle_outlined : Icons.radio_button_unchecked),
                    size: 16,
                    color: estMonChoix ? const Color(0xFF5B4FC8) : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sondage.options[index],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF0F172A),
                        fontWeight: estMonChoix ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (aVote) ...[
                    const SizedBox(width: 8),
                    Text(
                      "${(part * 100).round()} %",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: estMonChoix ? const Color(0xFF5B4FC8) : Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _voter(BuildContext context, Sondage sondage, int index, String? uid) async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connecte-toi pour donner ton avis."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final compte = await _firestoreService.voterSondage(uid, sondage, index);
    messenger.showSnackBar(
      SnackBar(
        content: Text(compte ? "Merci, ton avis est pris en compte." : "Tu as déjà répondu."),
        backgroundColor: compte ? Colors.green : Colors.orange,
      ),
    );
  }

  Widget _buildDefisChallenges() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("3", "Défis & challenges", "Relève des défis et grandis\nspirituellement !"),
          const SizedBox(height: 15),
          StreamBuilder<List<Challenge>>(
            stream: _firestoreService.getChallenges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("Aucun défi pour l'instant.", style: TextStyle(color: Colors.grey, fontSize: 10));
              }

              final challenges = snapshot.data!;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: challenges.map((challenge) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.red, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(challenge.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                                      Text(challenge.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Flexible(
                                child: Text("${challenge.participants} participants", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              _buildAvatarCluster(challenge.participants),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(challenge.description, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () {
                                _firestoreService.incrementChallengeParticipants(challenge.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Vous participez maintenant au ${challenge.title} !'), backgroundColor: Colors.green),
                                );
                              },
                              child: const Text("Participer au défi", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildEvenementsAvenir(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("4", "Événements à venir", "Ne manque aucun rendez-vous\nimportant."),
          const SizedBox(height: 15),
          StreamBuilder<List<AppEvent>>(
            stream: _firestoreService.getEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("Aucun événement prévu.", style: TextStyle(color: Colors.grey, fontSize: 10));
              }

              final events = snapshot.data!.take(2).toList(); // Show max 2

              return Column(
                children: events.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildEventItem(event.imageUrl.isNotEmpty ? event.imageUrl : "assets/sunset_bg.jpg", event.title, "${event.day} ${event.month} à ${event.time}", event.location),
                  );
                }).toList(),
              );
            }
          ),
          const SizedBox(height: 5),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllEventsScreen()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: Text("Voir tout le calendrier", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                Icon(Icons.chevron_right, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(String img, String title, String date, String location) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(img, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 40, height: 40, color: Colors.grey[200])),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 8, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(date, style: const TextStyle(fontSize: 8, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 8, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(location, style: const TextStyle(fontSize: 8, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
      ],
    );
  }

  Widget _buildMaFratrie(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("5", "Mon groupe", "Connecte-toi avec ton groupe local."),
          const SizedBox(height: 15),
          // Le groupe affiché est celui que le membre a lui-même rejoint, et
          // non plus la première fratrie de la base : personne n'était
          // réellement inscrit dans celle qu'on lui montrait.
          StreamBuilder<String?>(
            stream: FirebaseAuth.instance.currentUser != null
                ? _firestoreService.getMonGroupeId(FirebaseAuth.instance.currentUser!.uid)
                : Stream.value(null),
            builder: (context, monGroupeSnapshot) {
              return StreamBuilder<List<Fraternity>>(
            stream: _firestoreService.getGroupes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }

              final groupes = snapshot.data ?? <Fraternity>[];
              final monGroupeId = monGroupeSnapshot.data;
              final miens = groupes.where((g) => g.id == monGroupeId);

              if (miens.isEmpty) return _buildInvitationGroupe(context, groupes.length);

              final fraternity = miens.first;

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_outline, color: Color(0xFF5B4FC8), size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fraternity.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                              Text(fraternity.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Text("${fraternity.memberCount} membres", style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(width: 5),
                          _buildAvatarCluster(fraternity.memberCount),
                          if (fraternity.memberCount > 4) ...[
                            const SizedBox(width: 5),
                            Text("+${fraternity.memberCount - 4}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Prochaines rencontres", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    // Deux rencontres par mois, saisies par un responsable :
                    // sans date renseignée, on le dit plutôt que d'afficher
                    // une ligne vide.
                    if (_prochainesRencontres(fraternity).isEmpty)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              "Deux fois par mois · dates à venir",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    for (final date in _prochainesRencontres(fraternity)) ...[
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: Color(0xFF5B4FC8)),
                          const SizedBox(width: 5),
                          Expanded(child: Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (fraternity.nextMeetingLocation.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF5B4FC8)),
                          const SizedBox(width: 5),
                          Expanded(child: Text(fraternity.nextMeetingLocation, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                        ],
                      ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5B4FC8),
                          side: const BorderSide(color: Color(0xFF5B4FC8)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GroupesScreen()),
                        ),
                        child: const Text("Voir tous les groupes", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            }
          );
            },
          ),
        ],
      ),
    );
  }

  /// Affiché tant que le membre n'a rejoint aucun groupe : l'invitation vaut
  /// mieux qu'un « Aucune fratrie assignée » qui n'appelle aucune action.
  Widget _buildInvitationGroupe(BuildContext context, int nombreDeGroupes) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, color: Color(0xFF5B4FC8), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nombreDeGroupes == 0
                      ? "L'annuaire des groupes se remplit."
                      : "Tu n'as pas encore de groupe",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nombreDeGroupes == 0
                ? "Reviens dans un instant pour trouver une communauté près de chez toi."
                : "$nombreDeGroupes groupes t'attendent : fratrie de quartier, groupe de prière, jeunes, familles…",
            style: const TextStyle(color: Colors.black54, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B4FC8),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroupesScreen()),
              ),
              child: const Text(
                "Rejoindre un groupe",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnonces() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("6", "Annonces & informations", "Reste informé des nouvelles de la communauté."),
          const SizedBox(height: 15),
          StreamBuilder<List<Annonce>>(
            stream: _firestoreService.getAnnonces(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
              final annonces = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: annonces.map((annonce) {
                    final color = Color(int.parse(annonce.colorHex.replaceFirst('#', '0xFF')));
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: _buildAnnonceCard(Icons.campaign, color, color.withOpacity(0.1), annonce.title, annonce.subtitle),
                    );
                  }).toList(),
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildAnnonceCard(IconData icon, Color color, Color bgColor, String title, String subtitle) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A), height: 1.2)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

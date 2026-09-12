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
          StreamBuilder<List<Post>>(
            stream: _firestoreService.getPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("Aucun post disponible.", style: TextStyle(color: Colors.grey));
              }

              final post = snapshot.data!.first;
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
                                Text(dateFormat.format(post.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 10)),
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
                                InkWell(
                                  onTap: () {
                                    _firestoreService.toggleLikePost(post.id);
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                                      const SizedBox(width: 5),
                                      Text("${post.likes}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () => ShareService.sharePost(
                                    authorName: post.authorName,
                                    content: post.content,
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.reply, color: Colors.grey, size: 16),
                                      SizedBox(width: 5),
                                      Text("Partager", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
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
          ),
        ],
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
          _buildSectionHeader("2", "Défis & challenges", "Relève des défis et grandis\nspirituellement !"),
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
          _buildSectionHeader("3", "Événements à venir", "Ne manque aucun rendez-vous\nimportant."),
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
          _buildSectionHeader("4", "Ma Fratrie", "Connecte-toi avec ton groupe local."),
          const SizedBox(height: 15),
          StreamBuilder<Fraternity?>(
            stream: _firestoreService.getFraternity(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Text("Aucune fratrie assignée.", style: TextStyle(color: Colors.grey, fontSize: 10));
              }

              final fraternity = snapshot.data!;

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
                          Text("${fraternity.memberCount} membres", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                    const Text("Prochaine rencontre", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Color(0xFF5B4FC8)),
                        const SizedBox(width: 5),
                        Expanded(child: Text(fraternity.nextMeetingDate, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 4),
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Le chat de la fratrie sera bientôt disponible !'), backgroundColor: Colors.blue),
                          );
                        },
                        child: const Text("Rejoindre la discussion", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            }
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
          _buildSectionHeader("5", "Annonces & informations", "Reste informé des nouvelles de la communauté."),
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

import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';

class MediaDetailScreen extends StatefulWidget {
  final String title;
  final String author;
  final String duration;
  final bool isVideo;
  final String image;
  final String? audioUrl;
  final String? videoUrl;

  const MediaDetailScreen({
    Key? key,
    required this.title,
    required this.author,
    required this.duration,
    required this.isVideo,
    required this.image,
    this.audioUrl,
    this.videoUrl,
  }) : super(key: key);

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isAudioLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    final videoPath = widget.videoUrl ?? 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
    
    if (videoPath.startsWith('http')) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
    } else {
      _videoPlayerController = VideoPlayerController.asset(videoPath);
    }
    
    await _videoPlayerController!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: kPrimaryColor,
        handleColor: kPrimaryColor,
        backgroundColor: Colors.grey,
        bufferedColor: kPrimaryColor.withOpacity(0.3),
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      ),
    );
    
    setState(() {});
  }

  Future<void> _playAudio() async {
    if (widget.audioUrl != null) {
      setState(() {
        _isAudioLoading = true;
      });
      try {
        await _audioPlayer.play(UrlSource(widget.audioUrl!));
        setState(() {
          _isAudioLoading = false;
          _isPlaying = true;
        });
      } catch (e) {
        setState(() {
          _isAudioLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la lecture audio: $e")),
        );
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isVideo ? 'Lecture Vidéo' : 'Lecture Audio',
          style: const TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: widget.isVideo && _isPlaying && _chewieController != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(defaultBorderRadius),
                        child: Chewie(controller: _chewieController!),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(defaultBorderRadius),
                            child: Image.asset(
                              widget.image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(defaultBorderRadius),
                            ),
                          ),
                          if (_isAudioLoading)
                            const CircularProgressIndicator(color: Colors.white)
                          else if (_isPlaying && !widget.isVideo)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.music_note, color: Colors.white, size: 60),
                                const SizedBox(height: 10),
                                IconButton(
                                  icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 60),
                                  onPressed: _pauseAudio,
                                ),
                              ],
                            )
                          else
                            IconButton(
                              icon: Icon(
                                widget.isVideo ? Icons.play_circle_outline : Icons.speaker_group_outlined,
                                color: Colors.white,
                                size: 80,
                              ),
                              onPressed: () {
                                if (widget.isVideo) {
                                  setState(() {
                                    _isPlaying = true;
                                  });
                                  _chewieController?.play();
                                } else {
                                  _playAudio();
                                }
                              },
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.isVideo ? kPrimaryColor.withOpacity(0.1) : kAccentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.isVideo ? 'VIDÉO' : 'AUDIO',
                    style: TextStyle(
                      color: widget.isVideo ? kPrimaryColor : kAccentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.timer_outlined, size: 16, color: kTextSecondaryColor),
                const SizedBox(width: 4),
                Text(widget.duration, style: const TextStyle(color: kTextSecondaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kTextColor,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Par ${widget.author}',
              style: const TextStyle(fontSize: 16, color: kTextSecondaryColor),
            ),
            const SizedBox(height: 32),
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isVideo 
                ? 'Découvrez cet enseignement puissant extrait de nos archives. Cette vidéo vous guide à travers les principes fondamentaux de la foi avec des exemples concrets et modernes.'
                : 'Écoutez cet audio inspirant pour nourrir votre âme et fortifier votre foi. Un message de paix et de sagesse pour votre journée.',
              style: const TextStyle(fontSize: 15, color: kTextColor, height: 1.6),
            ),
            const SizedBox(height: 48),
            if (!_isPlaying || !widget.isVideo)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.isVideo) {
                      setState(() {
                        _isPlaying = true;
                      });
                      _chewieController?.play();
                    } else {
                      if (_isPlaying) {
                        _pauseAudio();
                      } else {
                        _playAudio();
                      }
                    }
                  },
                  icon: Icon(widget.isVideo 
                    ? Icons.play_arrow 
                    : (_isPlaying ? Icons.pause : Icons.headset)),
                  label: Text(widget.isVideo 
                    ? 'Lancer la Vidéo' 
                    : (_isPlaying ? 'Pause' : 'Écouter l\'Audio')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isVideo ? kPrimaryColor : kAccentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

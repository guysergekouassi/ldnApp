import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/office_model.dart';
import '../services/firestore_service.dart';

class OfficeDetailScreen extends StatelessWidget {
  final Office office;

  const OfficeDetailScreen({Key? key, required this.office}) : super(key: key);

  Color _getColor() {
    try {
      return Color(int.parse(office.colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFF05B3A); // Default orange
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getColor();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, primaryColor),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection("Hymne", office.hymn, primaryColor),
                  _buildSection("Antienne", office.antiphon, primaryColor, isItalic: true),
                  _buildSection("Psaumes", office.psalms, primaryColor),
                  _buildSection("Parole de Dieu", office.lecture, primaryColor),
                  _buildSection("Prière", office.prayer, primaryColor),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: primaryColor.withOpacity(0.5),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                        await prefs.setBool('office_completed_${office.id}_$today', true);
                        
                        try {
                          await FirestoreService().markOfficeAsCompleted(office.id, today);
                        } catch (e) {
                          debugPrint('Error marking office as completed in Firestore: $e');
                        }
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "Terminer l'Office",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/sunset_bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          // Hauteur minimale et non figée : avec un texte agrandi par les
          // réglages système, le contenu débordait de l'en-tête.
          constraints: const BoxConstraints(minHeight: 300),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.8),
                primaryColor.withOpacity(0.95),
                const Color(0xFFF8F9FA),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance pour centrer le contenu en dessous
                  ],
                ),
                const SizedBox(height: 10),
                Icon(
                  _getIconData(office.iconName),
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 15),
                Text(
                  office.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  office.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, Color color, {bool isItalic = false}) {
    if (content.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content.replaceAll(r'\n', '\n'), // Handle escaped newlines from Firestore
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: const Color(0xFF334155),
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny_outlined;
      case 'brightness_high':
        return Icons.brightness_high;
      case 'wb_twilight':
        return Icons.wb_twilight;
      case 'nightlight_round':
        return Icons.nightlight_round;
      default:
        return Icons.menu_book;
    }
  }
}

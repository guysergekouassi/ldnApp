import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

/// Barre de navigation principale de l'application.
///
/// Les cinq onglets vivent dans l'`IndexedStack` de [HomeScreen]. Depuis un
/// écran secondaire poussé sur la pile (Bons Plans, Quiz & Jeux, Carnet
/// spirituel…), toucher un onglet revient donc au shell en sélectionnant
/// l'onglet demandé et vide la pile, comme le ferait une vraie tab bar.
class AppBottomNavBar extends StatelessWidget {
  /// Onglet mis en avant. Pour un écran secondaire, c'est l'onglet depuis
  /// lequel il a été ouvert.
  final int currentIndex;

  const AppBottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  static const List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
    BottomNavigationBarItem(icon: Icon(Icons.pan_tool_outlined), label: "Prions ensemble"),
    BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Grandir dans la foi"),
    BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Communauté"),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Mon espace"),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: index)),
          (route) => false,
        );
      },
      items: items,
    );
  }
}

import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Etudiant> _etudiants = [
    Etudiant(
      id: '1', nom: 'Ben Ali', prenom: 'Ahmed',
      dateNaiss: DateTime(2001, 5, 12),
      tel: '+21698765432', groupe: 'G1',
    ),
    Etudiant(
      id: '2', nom: 'Trabelsi', prenom: 'Sarra',
      dateNaiss: DateTime(2002, 3, 20),
      tel: '+21692345678', groupe: 'G2',
    ),
    Etudiant(
      id: '3', nom: 'Mansour', prenom: 'Karim',
      dateNaiss: DateTime(2000, 11, 8),
      tel: '+21655123456', groupe: 'G1',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(
        etudiants: _etudiants,
        onAdd: (e) => setState(() => _etudiants.add(e)),
        onDelete: (id) => setState(() => _etudiants.removeWhere((e) => e.id == id)),
        onUpdate: (updated) {
          setState(() {
            final i = _etudiants.indexWhere((e) => e.id == updated.id);
            if (i != -1) _etudiants[i] = updated;
          });
        },
      ),
      StatsScreen(etudiants: _etudiants),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Étudiants',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Statistiques',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
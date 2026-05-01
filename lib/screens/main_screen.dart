import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../database/db_helper.dart';
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
  List<Etudiant> _etudiants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEtudiants();
  }

  Future<void> _loadEtudiants() async {
    final data = await DbHelper.instance.getAllEtudiants();
    setState(() {
      _etudiants = data;
      _loading = false;
    });
  }

  Future<void> _addEtudiant(Etudiant e) async {
    await DbHelper.instance.insertEtudiant(e);
    setState(() => _etudiants.add(e));
  }

  Future<void> _deleteEtudiant(String id) async {
    await DbHelper.instance.deleteEtudiant(id);
    setState(() => _etudiants.removeWhere((e) => e.id == id));
  }

  Future<void> _updateEtudiant(Etudiant updated) async {
    await DbHelper.instance.updateEtudiant(updated);
    setState(() {
      final i = _etudiants.indexWhere((e) => e.id == updated.id);
      if (i != -1) _etudiants[i] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.mainGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text('Chargement...',
                  style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
        etudiants: _etudiants,
        onAdd: _addEtudiant,
        onDelete: _deleteEtudiant,
        onUpdate: _updateEtudiant,
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
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold),
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
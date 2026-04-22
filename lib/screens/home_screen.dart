import 'dart:async';
import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../widgets/student_card.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Etudiant> etudiants;
  final Function(Etudiant) onAdd;
  final Function(String) onDelete;
  final Function(Etudiant) onUpdate;

  const HomeScreen({
    super.key,
    required this.etudiants,
    required this.onAdd,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Etudiant> _filtered = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.etudiants;
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _search(_searchCtrl.text);
  }

  void _search(String query) {
    setState(() {
      _filtered = widget.etudiants.where((e) {
        final q = query.toLowerCase();
        return e.nom.toLowerCase().contains(q) ||
            e.prenom.toLowerCase().contains(q) ||
            e.groupe.toLowerCase().contains(q) ||
            e.tel.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            expandedHeight: 210,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.mainGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('🎓 Scolarite App',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode : Icons.dark_mode,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  MyApp.of(context)?.toggleTheme(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: ['G1', 'G2', 'G3', 'Total'].map((g) {
                            final count = g == 'Total'
                                ? widget.etudiants.length
                                : widget.etudiants
                                    .where((e) => e.groupe == g)
                                    .length;
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text('$count',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    Text(g,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10)
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _search,
                  decoration: InputDecoration(
                    hintText: 'Chercher nom, prénom, groupe, tél...',
                    hintStyle:
                        TextStyle(color: Colors.grey[400], fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Colors.grey, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _search('');
                            })
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // ── Carousel ──
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: _WelcomeCarousel(),
            ),
          ),

          // ── Liste étudiants ──
          _filtered.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Aucun étudiant trouvé',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final etudiant = _filtered[i];
                        return Hero(
                          tag: 'etudiant_${etudiant.id}',
                          child: StudentCard(
                            etudiant: etudiant,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      StudentDetailScreen(
                                    etudiant: etudiant,
                                    onDelete: widget.onDelete,
                                    onUpdate: widget.onUpdate,
                                  ),
                                  transitionsBuilder:
                                      (_, anim, __, child) =>
                                          SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.easeOut)),
                                    child: child,
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                            onDelete: () => widget.onDelete(etudiant.id),
                          ),
                        );
                      },
                      childCount: _filtered.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newStudent = await Navigator.push<Etudiant>(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AddStudentScreen(),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOut)),
                child: child,
              ),
            ),
          );
          if (newStudent != null) widget.onAdd(newStudent);
        },
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Ajouter',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// ════════════════════════════════════════
//  WELCOME CAROUSEL
// ════════════════════════════════════════

class _WelcomeCarousel extends StatefulWidget {
  const _WelcomeCarousel();

  @override
  State<_WelcomeCarousel> createState() => _WelcomeCarouselState();
}

class _WelcomeCarouselState extends State<_WelcomeCarousel>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  int _current = 0;
  Timer? _timer;

  final List<_SlideData> _slides = [
    _SlideData(
      emoji: '🎓',
      title: 'Bienvenue !',
      subtitle: 'Gérez vos étudiants\nfacilement',
      color1: const Color(0xFF7B2FF7),
      color2: const Color(0xFFF107A3),
      icon: Icons.school_rounded,
    ),
    _SlideData(
      emoji: '📊',
      title: 'Statistiques',
      subtitle: 'Suivez les performances\net les absences',
      color1: const Color(0xFF0077B6),
      color2: const Color(0xFF00C9FF),
      icon: Icons.bar_chart_rounded,
    ),
    _SlideData(
      emoji: '📅',
      title: 'Présences',
      subtitle: 'Gérez les absences\nen temps réel',
      color1: const Color(0xFF00C853),
      color2: const Color(0xFF00897B),
      icon: Icons.event_available_rounded,
    ),
    _SlideData(
      emoji: '🔐',
      title: 'Sécurisé',
      subtitle: 'Vos données protégées\npar un code PIN',
      color1: const Color(0xFFFF6B35),
      color2: const Color(0xFFF107A3),
      icon: Icons.lock_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_current + 1) % _slides.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          // Carousel slides
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _current = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => _buildSlide(_slides[i]),
            ),
          ),
          const SizedBox(height: 12),

          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              final active = i == _current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF7B2FF7), Color(0xFFF107A3)],
                        )
                      : null,
                  color: active ? null : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(_SlideData slide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [slide.color1, slide.color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: slide.color1.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // دوائر ديكور
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // محتوى
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // نص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(slide.emoji,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        slide.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        slide.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Icône
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(slide.icon, size: 48, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide Data Model ──
class _SlideData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final IconData icon;

  const _SlideData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.icon,
  });
}
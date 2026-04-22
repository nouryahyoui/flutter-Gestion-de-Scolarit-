import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../widgets/student_card.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  List<Etudiant> _filtered = [];
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _filtered = _etudiants;
  }

  void _search(String query) {
    setState(() {
      _filtered = _etudiants.where((e) {
        final q = query.toLowerCase();
        return e.nom.toLowerCase().contains(q) ||
            e.prenom.toLowerCase().contains(q) ||
            e.groupe.toLowerCase().contains(q) ||
            e.tel.contains(q);
      }).toList();
    });
  }

  void _addEtudiant(Etudiant e) =>
      setState(() { _etudiants.add(e); _filtered = List.from(_etudiants); });

  void _deleteEtudiant(String id) =>
      setState(() { _etudiants.removeWhere((e) => e.id == id); _filtered = List.from(_etudiants); });

  void _updateEtudiant(Etudiant updated) {
    setState(() {
      final i = _etudiants.indexWhere((e) => e.id == updated.id);
      if (i != -1) _etudiants[i] = updated;
      _filtered = List.from(_etudiants);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // AppBar gradient
          SliverAppBar(
            expandedHeight: 200,
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
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isDark ? Icons.light_mode : Icons.dark_mode,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    MyApp.of(context)?.toggleTheme();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bar_chart,
                                      color: Colors.white),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StatsScreen(
                                          etudiants: _etudiants),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Stats cards
                        Row(
                          children: ['G1', 'G2', 'G3', 'Total'].map((g) {
                            final count = g == 'Total'
                                ? _etudiants.length
                                : _etudiants
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
                      blurRadius: 10,
                    )
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
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // Liste
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
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => StudentCard(
                        etudiant: _filtered[i],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentDetailScreen(
                                etudiant: _filtered[i],
                                onDelete: _deleteEtudiant,
                                onUpdate: _updateEtudiant,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        onDelete: () => _deleteEtudiant(_filtered[i].id),
                      ),
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
            MaterialPageRoute(builder: (_) => const AddStudentScreen()),
          );
          if (newStudent != null) _addEtudiant(newStudent);
        },
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Ajouter',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
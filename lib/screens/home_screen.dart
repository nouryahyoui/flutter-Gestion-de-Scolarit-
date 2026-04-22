import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../widgets/student_card.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Etudiant> _etudiants = [
    Etudiant(
      id: '1',
      nom: 'Ben Ali',
      prenom: 'Ahmed',
      dateNaiss: DateTime(2001, 5, 12),
      tel: '+21698765432',
      groupe: 'G1',
    ),
    Etudiant(
      id: '2',
      nom: 'Trabelsi',
      prenom: 'Sarra',
      dateNaiss: DateTime(2002, 3, 20),
      tel: '+21692345678',
      groupe: 'G2',
    ),
    Etudiant(
      id: '3',
      nom: 'Mansour',
      prenom: 'Karim',
      dateNaiss: DateTime(2000, 11, 8),
      tel: '+21655123456',
      groupe: 'G1',
    ),
  ];

  List<Etudiant> _filtered = [];
  final TextEditingController _searchCtrl = TextEditingController();

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

  void _addEtudiant(Etudiant e) {
    setState(() {
      _etudiants.add(e);
      _filtered = List.from(_etudiants);
    });
  }

  void _deleteEtudiant(String id) {
    setState(() {
      _etudiants.removeWhere((e) => e.id == id);
      _filtered = List.from(_etudiants);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          '🎓 Scolarite App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_etudiants.length} étudiants',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _statCard('G1',
                        _etudiants.where((e) => e.groupe == 'G1').length.toString(),
                        Icons.group),
                    const SizedBox(width: 12),
                    _statCard('G2',
                        _etudiants.where((e) => e.groupe == 'G2').length.toString(),
                        Icons.group),
                    const SizedBox(width: 12),
                    _statCard('Total', _etudiants.length.toString(), Icons.school),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: 'Chercher par nom, prénom, groupe, tél...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchCtrl.clear();
                                _search('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Aucun étudiant trouvé',
                            style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => StudentCard(
                      etudiant: _filtered[i],
                      onTap: () async {
                        await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentDetailScreen(
                              etudiant: _filtered[i],
                              onDelete: _deleteEtudiant,
                            ),
                          ),
                        );
                      },
                      onDelete: () => _deleteEtudiant(_filtered[i].id),
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
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(label,
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/etudiant.dart';

class StudentDetailScreen extends StatelessWidget {
  final Etudiant etudiant;
  final Function(String) onDelete;

  const StudentDetailScreen({
    super.key,
    required this.etudiant,
    required this.onDelete,
  });

  Future<void> _callStudent(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: etudiant.tel);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'effectuer l\'appel')),
      );
    }
  }

  Color _groupColor(String groupe) {
    switch (groupe) {
      case 'G1': return const Color(0xFF1565C0);
      case 'G2': return const Color(0xFF00897B);
      case 'G3': return const Color(0xFF6A1B9A);
      default:   return const Color(0xFFE65100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('Fiche Étudiant',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Supprimer'),
                  content: Text('Supprimer ${etudiant.nomComplet} ?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler')),
                    TextButton(
                      onPressed: () {
                        onDelete(etudiant.id);
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      },
                      child: const Text('Supprimer',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Color(0xFF1565C0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white24,
                    child: Text(
                      etudiant.prenom[0] + etudiant.nom[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(etudiant.nomComplet,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(etudiant.groupe,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _infoCard(Icons.badge_outlined, 'Nom', etudiant.nom),
                  _infoCard(Icons.person_outline, 'Prénom', etudiant.prenom),
                  _infoCard(Icons.cake_outlined, 'Date de naissance',
                      DateFormat('dd/MM/yyyy').format(etudiant.dateNaiss)),
                  _infoCard(Icons.today_outlined, 'Âge', '${etudiant.age} ans'),
                  _infoCard(Icons.group_outlined, 'Groupe', etudiant.groupe),
                  _infoCard(Icons.phone_outlined, 'Téléphone', etudiant.tel),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _callStudent(context),
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: Text('Appeler ${etudiant.prenom}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/etudiant.dart';

class StudentCard extends StatelessWidget {
  final Etudiant etudiant;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const StudentCard({
    super.key,
    required this.etudiant,
    required this.onTap,
    required this.onDelete,
  });

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: _groupColor(etudiant.groupe).withOpacity(0.15),
          child: Text(
            etudiant.prenom[0] + etudiant.nom[0],
            style: TextStyle(
              color: _groupColor(etudiant.groupe),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          etudiant.nomComplet,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(etudiant.tel,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.cake, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${etudiant.age} ans',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _groupColor(etudiant.groupe).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                etudiant.groupe,
                style: TextStyle(
                  color: _groupColor(etudiant.groupe),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/etudiant.dart';
import '../theme/app_colors.dart';
import '../database/db_helper.dart';

class AbsenceScreen extends StatefulWidget {
  final Etudiant etudiant;

  const AbsenceScreen({super.key, required this.etudiant});

  @override
  State<AbsenceScreen> createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  late Etudiant _etudiant;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _etudiant = widget.etudiant;
  }

  Future<void> _toggleAbsence() async {
    setState(() => _isLoading = true);

    final wasAbsent = _etudiant.isAbsentToday();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (wasAbsent) {
      await DbHelper.instance.deleteAbsence(_etudiant.id, today);
    } else {
      await DbHelper.instance.insertAbsence(_etudiant.id, today);
    }

    _etudiant.toggleAbsenceToday();
    setState(() => _isLoading = false);
  }

  Future<void> _deleteAbsence(DateTime date) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer l\'absence'),
        content: Text(
          'Supprimer l\'absence du ${DateFormat('dd/MM/yyyy').format(date)} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DbHelper.instance.deleteAbsence(_etudiant.id, date);
      setState(() {
        _etudiant.absences.removeWhere((d) =>
            d.year == date.year &&
            d.month == date.month &&
            d.day == date.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final absences = [..._etudiant.absences]..sort((a, b) => b.compareTo(a));
    final isAbsent = _etudiant.isAbsentToday();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        title: Text(
          'Absences — ${_etudiant.prenom}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // ── Header Card ──
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total absences',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    Text(
                      '${absences.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      absences.isEmpty
                          ? 'Aucune absence 🎉'
                          : '${absences.length} jour(s) manqué(s)',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),

                // Toggle bouton
                GestureDetector(
                  onTap: _isLoading ? null : _toggleAbsence,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isAbsent ? Colors.redAccent : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isAbsent
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Icon(
                                isAbsent
                                    ? Icons.cancel
                                    : Icons.check_circle,
                                color: isAbsent
                                    ? Colors.white
                                    : AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isAbsent ? 'Absent' : 'Présent',
                                style: TextStyle(
                                  color: isAbsent
                                      ? Colors.white
                                      : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ── Titre liste ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: AppColors.mainGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Historique des absences',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${absences.length} jour(s)',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Liste ──
          Expanded(
            child: absences.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.celebration,
                              size: 56, color: Colors.green[400]),
                        ),
                        const SizedBox(height: 16),
                        const Text('Aucune absence !',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          'Cet étudiant est toujours présent 👏',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: absences.length,
                    itemBuilder: (_, i) {
                      final date = absences[i];
                      final isToday =
                          date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;

                      return Dismissible(
                        key: Key(date.toIso8601String()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          await _deleteAbsence(date);
                          return false;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: isToday
                                ? Border.all(
                                    color: Colors.redAccent, width: 1.5)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Colors.redAccent.withOpacity(0.15)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.event_busy,
                                  color: isToday
                                      ? Colors.redAccent
                                      : Colors.orange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat(
                                              'EEEE dd MMMM yyyy', 'fr')
                                          .format(date),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                    if (isToday)
                                      Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "Aujourd'hui",
                                          style: TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Numéro + delete
                              Column(
                                children: [
                                  Text(
                                    '#${absences.length - i}',
                                    style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 11),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _deleteAbsence(date),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
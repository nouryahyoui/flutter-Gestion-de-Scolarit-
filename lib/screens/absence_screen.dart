import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/etudiant.dart';
import '../theme/app_colors.dart';

class AbsenceScreen extends StatefulWidget {
  final Etudiant etudiant;

  const AbsenceScreen({super.key, required this.etudiant});

  @override
  State<AbsenceScreen> createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  late Etudiant _etudiant;

  @override
  void initState() {
    super.initState();
    _etudiant = widget.etudiant;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final absences = _etudiant.absences
      ..sort((a, b) => b.compareTo(a));
    final isAbsent = _etudiant.isAbsentToday();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppColors.mainGradient)),
        title: Text('Absences — ${_etudiant.prenom}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header card
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total absences',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('${absences.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                // Toggle aujourd'hui
                GestureDetector(
                  onTap: () {
                    setState(() => _etudiant.toggleAbsenceToday());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isAbsent ? Colors.redAccent : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAbsent ? Icons.cancel : Icons.check_circle,
                          color: isAbsent
                              ? Colors.white
                              : AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAbsent ? 'Absent' : 'Présent',
                          style: TextStyle(
                            color: isAbsent
                                ? Colors.white
                                : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Historique des absences',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text('${absences.length} jour(s)',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: absences.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.celebration,
                            size: 64, color: Colors.green[300]),
                        const SizedBox(height: 12),
                        Text('Aucune absence ! 🎉',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: absences.length,
                    itemBuilder: (_, i) {
                      final date = absences[i];
                      final isToday = date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: isToday
                              ? Border.all(
                                  color: Colors.redAccent, width: 1.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.event_busy,
                                  color: Colors.redAccent, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEEE dd MMMM yyyy', 'fr')
                                      .format(date),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                if (isToday)
                                  const Text("Aujourd'hui",
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 11)),
                              ],
                            ),
                            const Spacer(),
                            Text('#${absences.length - i}',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12)),
                          ],
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
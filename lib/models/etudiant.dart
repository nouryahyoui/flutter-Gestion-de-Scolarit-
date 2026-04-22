class Etudiant {
  final String id;
  String nom;
  String prenom;
  DateTime dateNaiss;
  String tel;
  String groupe;
  String? photoPath;
  List<DateTime> absences;

  Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaiss,
    required this.tel,
    required this.groupe,
    this.photoPath,
    List<DateTime>? absences,
  }) : absences = absences ?? [];

  String get nomComplet => '$prenom $nom';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateNaiss.year;
    if (now.month < dateNaiss.month ||
        (now.month == dateNaiss.month && now.day < dateNaiss.day)) age--;
    return age;
  }

  bool isAbsentToday() {
    final now = DateTime.now();
    return absences.any((d) =>
        d.year == now.year && d.month == now.month && d.day == now.day);
  }

  void toggleAbsenceToday() {
    final now = DateTime.now();
    if (isAbsentToday()) {
      absences.removeWhere((d) =>
          d.year == now.year && d.month == now.month && d.day == now.day);
    } else {
      absences.add(now);
    }
  }
}
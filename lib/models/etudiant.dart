class Etudiant {
  final String id;
  String nom;
  String prenom;
  DateTime dateNaiss;
  String tel;
  String groupe;
  String? photo;

  Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaiss,
    required this.tel,
    required this.groupe,
    this.photo,
  });

  String get nomComplet => '$prenom $nom';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateNaiss.year;
    if (now.month < dateNaiss.month ||
        (now.month == dateNaiss.month && now.day < dateNaiss.day)) {
      age--;
    }
    return age;
  }
}
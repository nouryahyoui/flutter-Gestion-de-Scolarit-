class Etudiant {
  final String id;
  String nom;
  String prenom;
  DateTime dateNaiss;
  String tel;
  String groupe;
  String? photoPath;

  Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaiss,
    required this.tel,
    required this.groupe,
    this.photoPath,
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'dateNaiss': dateNaiss.toIso8601String(),
    'tel': tel,
    'groupe': groupe,
    'photoPath': photoPath,
  };

  factory Etudiant.fromMap(Map<String, dynamic> map) => Etudiant(
    id: map['id'],
    nom: map['nom'],
    prenom: map['prenom'],
    dateNaiss: DateTime.parse(map['dateNaiss']),
    tel: map['tel'],
    groupe: map['groupe'],
    photoPath: map['photoPath'],
  );
}                          
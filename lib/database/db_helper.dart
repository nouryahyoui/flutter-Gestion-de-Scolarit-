import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/etudiant.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('scolarite.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE etudiants (
        id TEXT PRIMARY KEY,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        dateNaiss TEXT NOT NULL,
        tel TEXT NOT NULL,
        groupe TEXT NOT NULL,
        photoPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE absences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        etudiantId TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (etudiantId) REFERENCES etudiants(id)
      )
    ''');
  }

  // ── CRUD Etudiants ──

  Future<void> insertEtudiant(Etudiant e) async {
    final db = await database;
    await db.insert(
      'etudiants',
      {
        'id': e.id,
        'nom': e.nom,
        'prenom': e.prenom,
        'dateNaiss': e.dateNaiss.toIso8601String(),
        'tel': e.tel,
        'groupe': e.groupe,
        'photoPath': e.photoPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateEtudiant(Etudiant e) async {
    final db = await database;
    await db.update(
      'etudiants',
      {
        'nom': e.nom,
        'prenom': e.prenom,
        'dateNaiss': e.dateNaiss.toIso8601String(),
        'tel': e.tel,
        'groupe': e.groupe,
        'photoPath': e.photoPath,
      },
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }

  Future<void> deleteEtudiant(String id) async {
    final db = await database;
    await db.delete('etudiants', where: 'id = ?', whereArgs: [id]);
    await db.delete('absences', where: 'etudiantId = ?', whereArgs: [id]);
  }

  Future<List<Etudiant>> getAllEtudiants() async {
    final db = await database;
    final rows = await db.query('etudiants', orderBy: 'nom ASC');
    final List<Etudiant> etudiants = [];

    for (final row in rows) {
      final e = Etudiant(
        id: row['id'] as String,
        nom: row['nom'] as String,
        prenom: row['prenom'] as String,
        dateNaiss: DateTime.parse(row['dateNaiss'] as String),
        tel: row['tel'] as String,
        groupe: row['groupe'] as String,
        photoPath: row['photoPath'] as String?,
      );

      // charger les absences
      final absRows = await db.query(
        'absences',
        where: 'etudiantId = ?',
        whereArgs: [e.id],
      );
      e.absences.addAll(
        absRows.map((r) => DateTime.parse(r['date'] as String)),
      );

      etudiants.add(e);
    }

    return etudiants;
  }

  // ── CRUD Absences ──

  Future<void> insertAbsence(String etudiantId, DateTime date) async {
    final db = await database;
    await db.insert('absences', {
      'etudiantId': etudiantId,
      'date': date.toIso8601String(),
    });
  }

  Future<void> deleteAbsence(String etudiantId, DateTime date) async {
    final db = await database;
    await db.delete(
      'absences',
      where: 'etudiantId = ? AND date = ?',
      whereArgs: [etudiantId, date.toIso8601String()],
    );
  }

  Future<void> closeDB() async {
    final db = await database;
    db.close();
  }
}
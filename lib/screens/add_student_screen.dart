import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/etudiant.dart';
import '../theme/app_colors.dart';

class AddStudentScreen extends StatefulWidget {
  final Etudiant? etudiant; // pour l'édition
  const AddStudentScreen({super.key, this.etudiant});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _nomCtrl  = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl  = TextEditingController();
  DateTime? _dateNaiss;
  String _groupe  = 'G1';
  String? _photoPath;
  final _picker   = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.etudiant != null) {
      final e = widget.etudiant!;
      _nomCtrl.text    = e.nom;
      _prenomCtrl.text = e.prenom;
      _telCtrl.text    = e.tel;
      _dateNaiss       = e.dateNaiss;
      _groupe          = e.groupe;
      _photoPath       = e.photoPath;
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Choisir une photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _photoOption(Icons.camera_alt, 'Caméra', () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 80);
                  if (img != null) setState(() => _photoPath = img.path);
                }),
                _photoOption(Icons.photo_library, 'Galerie', () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 80);
                  if (img != null) setState(() => _photoPath = img.path);
                }),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaiss ?? DateTime(2002),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateNaiss = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _dateNaiss != null) {
      final e = Etudiant(
        id: widget.etudiant?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        nom:       _nomCtrl.text.trim(),
        prenom:    _prenomCtrl.text.trim(),
        dateNaiss: _dateNaiss!,
        tel:       _telCtrl.text.trim(),
        groupe:    _groupe,
        photoPath: _photoPath,
      );
      Navigator.pop(context, e);
    } else if (_dateNaiss == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner la date de naissance')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.etudiant != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.mainGradient)),
        title: Text(isEdit ? 'Modifier Étudiant' : 'Ajouter Étudiant',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _photoPath == null
                              ? AppColors.mainGradient
                              : null,
                          border: Border.all(
                              color: AppColors.primary, width: 3),
                        ),
                        child: ClipOval(
                          child: _photoPath != null &&
                                  File(_photoPath!).existsSync()
                              ? Image.file(File(_photoPath!),
                                  fit: BoxFit.cover)
                              : const Icon(Icons.person,
                                  size: 55, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            gradient: AppColors.mainGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Appuyer pour ajouter une photo',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),

              _buildField(_prenomCtrl, 'Prénom', Icons.person_outline),
              const SizedBox(height: 14),
              _buildField(_nomCtrl, 'Nom', Icons.badge_outlined),
              const SizedBox(height: 14),
              _buildField(_telCtrl, 'Téléphone', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),

              // Date
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _dateNaiss == null
                            ? 'Date de naissance'
                            : DateFormat('dd/MM/yyyy').format(_dateNaiss!),
                        style: TextStyle(
                          color: _dateNaiss == null
                              ? Colors.grey[400]
                              : null,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Groupe
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _groupe,
                    isExpanded: true,
                    dropdownColor:
                        isDark ? AppColors.cardDark : Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primary),
                    items: ['G1', 'G2', 'G3', 'G4']
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12, height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.groupColor(g),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Groupe $g'),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _groupe = v!),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Bouton
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.mainGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(isEdit ? 'Modifier' : 'Enregistrer',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl, String label, IconData icon,
    {TextInputType keyboardType = TextInputType.text}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: isDark ? AppColors.cardDark : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
    );
  }
}
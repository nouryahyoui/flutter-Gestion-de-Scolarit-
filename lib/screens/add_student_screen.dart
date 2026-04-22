import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/etudiant.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  DateTime? _dateNaiss;
  String _groupe = 'G1';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2002),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateNaiss = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _dateNaiss != null) {
      final e = Etudiant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        dateNaiss: _dateNaiss!,
        tel: _telCtrl.text.trim(),
        groupe: _groupe,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('Ajouter un Étudiant',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1565C0), width: 2),
                  ),
                  child: const Icon(Icons.person, size: 50, color: Color(0xFF1565C0)),
                ),
              ),
              const SizedBox(height: 24),
              _buildField(_prenomCtrl, 'Prénom', Icons.person_outline),
              const SizedBox(height: 14),
              _buildField(_nomCtrl, 'Nom', Icons.badge_outlined),
              const SizedBox(height: 14),
              _buildField(_telCtrl, 'Téléphone', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Color(0xFF1565C0), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _dateNaiss == null
                            ? 'Date de naissance'
                            : DateFormat('dd/MM/yyyy').format(_dateNaiss!),
                        style: TextStyle(
                          color: _dateNaiss == null
                              ? Colors.grey[400]
                              : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _groupe,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF1565C0)),
                    items: ['G1', 'G2', 'G3', 'G4']
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Row(
                                children: [
                                  const Icon(Icons.group_outlined,
                                      color: Color(0xFF1565C0), size: 20),
                                  const SizedBox(width: 12),
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Enregistrer',
                      style: TextStyle(
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
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
    );
  }
}
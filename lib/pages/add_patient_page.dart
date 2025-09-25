import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import '../models/patient_entity.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({Key? key}) : super(key: key);

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();

  String _name = '';
  String _email = '';
  DateTime? _dateOfBirth;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(1900),
      lastDate: today,
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona fecha de nacimiento")),
      );
      return;
    }

    _formKey.currentState!.save();

    final newPatient = PatientEntity(
      name: _name,
      email: _email,
      dateOfBirth: _dateOfBirth!,
    );

    try {
      await SupabaseConfig.client
          .from('patients')
          .insert(newPatient.toMapForInsert());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paciente agregado exitosamente")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Agregar Paciente"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Nombre",
                  hintText: "Ej: Juan Pérez",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Ingrese nombre" : null,
                onSaved: (value) => _name = value!.trim(),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Ej: juan@example.com",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Ingrese email";
                  if (!value.contains('@')) return "Email inválido";
                  return null;
                },
                onSaved: (value) => _email = value!.trim(),
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Fecha de Nacimiento",
                  hintText: "Selecciona fecha",
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onTap: _pickDate,
                validator: (_) =>
                    _dateOfBirth == null ? "Selecciona una fecha" : null,
              ),
              const SizedBox(height: 24),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar"),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

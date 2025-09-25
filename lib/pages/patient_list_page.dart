import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import '../models/patient_entity.dart';
import 'add_patient_page.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({Key? key}) : super(key: key);

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List<PatientEntity> _patients = [];
  List<PatientEntity> _filteredPatients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    final data = await SupabaseConfig.client
        .from('patients')
        .select()
        .order('id')
        .limit(50);

    setState(() {
      _patients = (data as List)
          .map((e) => PatientEntity.fromMap(e as Map<String, dynamic>))
          .toList();
      _filteredPatients = _patients;
      _isLoading = false;
    });
  }

  void _goToAddPatient() async {
    final didAdd = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPatientPage()),
    );
    if (didAdd == true) {
      fetchPatients();
    }
  }

  void _filterPatients(String query) {
    final filtered = _patients.where((p) {
      final nameLower = p.name.toLowerCase();
      final emailLower = p.email.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) || emailLower.contains(searchLower);
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredPatients = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text("Pacientes"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: _goToAddPatient,
        icon: const Icon(Icons.add),
        label: const Text("Nuevo"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o email',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterPatients,
                  ),
                ),
                Expanded(
                  child: _filteredPatients.isEmpty
                      ? const Center(child: Text("No hay pacientes"))
                      : ListView.separated(
                          itemCount: _filteredPatients.length,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (context, index) {
                            final p = _filteredPatients[index];
                            final initials = p.name.isNotEmpty
                                ? p.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                                : '?';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  initials,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                p.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                "${p.email} • ${p.dateOfBirth.toLocal().toIso8601String().split('T').first}",
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Puedes navegar a un detalle más adelante aquí
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

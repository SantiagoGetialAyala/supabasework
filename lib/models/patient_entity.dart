class PatientEntity {
  final int? id;
  final String name;
  final String email;
  final DateTime dateOfBirth;

  PatientEntity({
    this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
  });

  factory PatientEntity.fromMap(Map<String, dynamic> map) {
    return PatientEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      dateOfBirth: DateTime.parse(map['date_of_birth'] as String),
    );
  }

  Map<String, dynamic> toMapForInsert() {
    return {
      'name': name,
      'email': email,
      'date_of_birth': dateOfBirth.toIso8601String(),
    };
  }
}

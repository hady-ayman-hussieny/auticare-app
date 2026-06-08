// models/child.dart
class ChildModel {
  final String id;
  final String parentId;
  final String name;
  final int age;
  final String gender;
  final String dateOfBirth;
  final String? profileImage;
  final String? medicalHistory;
  final bool familyAutismHistory;
  final bool jaundiceHistory;
  final String? notes;
  final String createdAt;

  const ChildModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.gender,
    required this.dateOfBirth,
    this.profileImage,
    this.medicalHistory,
    this.familyAutismHistory = false,
    this.jaundiceHistory = false,
    this.notes,
    required this.createdAt,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();
    final fullName = (json['name'] ?? '$firstName $lastName').toString().trim();

    return ChildModel(
      id: (json['id'] ?? json['_id'] ?? json['childId'] ?? '').toString(),
      parentId: (json['parentId'] ?? json['parent_id'] ?? 'parent-123').toString(),
      name: fullName.isEmpty ? 'Child' : fullName,
      age: int.tryParse((json['age'] ?? json['ageInYears'] ?? 0).toString()) ?? 0,
      gender: (json['gender'] ?? json['sex'] ?? 'Unknown').toString(),
      dateOfBirth: (json['dateOfBirth'] ?? json['date_of_birth'] ?? json['dob'] ?? '').toString(),
      profileImage: json['profileImage']?.toString() ?? json['profile_image']?.toString(),
      medicalHistory: json['medicalHistory']?.toString() ?? json['medical_history']?.toString(),
      familyAutismHistory: json['familyAutismHistory'] == true || json['family_autism_history'] == true,
      jaundiceHistory: json['jaundiceHistory'] == true || json['jaundice_history'] == true,
      notes: json['notes']?.toString(),
      createdAt: (json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'medicalHistory': medicalHistory,
        'familyAutismHistory': familyAutismHistory,
        'jaundiceHistory': jaundiceHistory,
        'notes': notes,
      };
}

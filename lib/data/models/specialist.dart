// models/specialist.dart
class SpecialistModel {
  final String id;
  final String name;
  final String type; // 'doctor' | 'therapist'
  final String specialization;
  final int yearsOfExperience;
  final double rating;
  final int reviewCount;
  final List<dynamic> availableSlots;
  final String? profileImage;
  final String? licenseNumber;
  final List<String> certifications;
  final String? email;
  final String? bio;

  const SpecialistModel({
    required this.id,
    required this.name,
    required this.type,
    required this.specialization,
    required this.yearsOfExperience,
    required this.rating,
    required this.reviewCount,
    required this.availableSlots,
    this.profileImage,
    this.licenseNumber,
    this.certifications = const [],
    this.email,
    this.bio,
  });

  factory SpecialistModel.fromJson(Map<String, dynamic> json) {
    final spec = (json['specialization'] ?? '').toString().toLowerCase();
    String calcType = 'doctor';
    if (spec.contains('therapist') ||
        spec.contains('therapy') ||
        spec.contains('speech') ||
        spec.contains('aba') ||
        spec.contains('sensory') ||
        spec.contains('occupational')) {
      calcType = 'therapist';
    }
    final typeVal = json['type'] == 'doctor' || json['type'] == 'therapist'
        ? json['type'].toString()
        : calcType;

    return SpecialistModel(
      id: (json['id'] ?? json['specialistId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: typeVal,
      specialization: (json['specialization'] ?? '').toString(),
      yearsOfExperience:
          int.tryParse((json['yearsOfExperience'] ?? json['yearsExperience'] ?? 0).toString()) ?? 0,
      rating: double.tryParse((json['rating'] ?? 0).toString()) ?? 0.0,
      reviewCount:
          int.tryParse((json['reviewCount'] ?? json['reviews'] ?? 0).toString()) ?? 0,
      availableSlots:
          json['availableSlots'] is List ? (json['availableSlots'] as List) : [],
      profileImage: json['profileImage']?.toString(),
      licenseNumber: json['licenseNumber']?.toString(),
      certifications: json['certifications'] is List
          ? List<String>.from(json['certifications'] as List)
          : [],
      email: json['email']?.toString(),
      bio: (json['bio'] ?? json['about'] ?? '').toString(),
    );
  }
}

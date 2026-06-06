// models/screening.dart

class ScreeningOption {
  final String id;
  final String label;
  final int value;
  const ScreeningOption({required this.id, required this.label, required this.value});
}

class ScreeningQuestion {
  final String id;
  final String question;
  final String? description;
  final int pageNumber;
  final List<ScreeningOption> options;
  const ScreeningQuestion({
    required this.id,
    required this.question,
    this.description,
    required this.pageNumber,
    required this.options,
  });
}

class ScreeningResult {
  final String childName;
  final String predictionClass;
  final double confidenceScore;
  final int aqScore;
  final String riskLevel;
  final String probability;
  final double socialAttention;
  final double jointAttention;
  final double socialCommunication;
  final double language;
  final double imagination;
  final double repetitiveBehavior;
  final String createdAt;

  const ScreeningResult({
    required this.childName,
    required this.predictionClass,
    required this.confidenceScore,
    required this.aqScore,
    required this.riskLevel,
    required this.probability,
    required this.socialAttention,
    required this.jointAttention,
    required this.socialCommunication,
    required this.language,
    required this.imagination,
    required this.repetitiveBehavior,
    required this.createdAt,
  });

  factory ScreeningResult.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;
    return ScreeningResult(
      childName: (json['childName'] ?? '').toString(),
      predictionClass: (json['predictionClass'] ?? '').toString(),
      confidenceScore: _d(json['confidenceScore']),
      aqScore: int.tryParse((json['aqScore'] ?? 0).toString()) ?? 0,
      riskLevel: (json['riskLevel'] ?? '').toString(),
      probability: (json['probability'] ?? '').toString(),
      socialAttention: _d(json['socialAttention']),
      jointAttention: _d(json['jointAttention']),
      socialCommunication: _d(json['socialCommunication']),
      language: _d(json['language']),
      imagination: _d(json['imagination']),
      repetitiveBehavior: _d(json['repetitiveBehavior']),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}

// 10 hardcoded questions matching the web app exactly
const List<ScreeningQuestion> kLocalScreeningQuestions = [
  ScreeningQuestion(
    id: 'q1',
    question: 'Does your child look at you when you call his/her name?',
    pageNumber: 1,
    options: [
      ScreeningOption(id: 'q1_yes', label: 'Yes', value: 1),
      ScreeningOption(id: 'q1_no', label: 'No', value: 0),
    ],
  ),
  ScreeningQuestion(
    id: 'q2',
    question: 'How easy is it for you to get eye contact with your child?',
    pageNumber: 2,
    options: [
      ScreeningOption(id: 'q2_yes', label: 'Yes', value: 1),
      ScreeningOption(id: 'q2_no', label: 'No', value: 0),
    ],
  ),
  ScreeningQuestion(
    id: 'q3',
    question: 'Does your child point to indicate that s/he wants something? (e.g. a toy that is out of reach)',
    pageNumber: 3,
    options: [
      ScreeningOption(id: 'q3_yes', label: 'Yes', value: 1),
      ScreeningOption(id: 'q3_no', label: 'No', value: 0),
    ],
  ),
  ScreeningQuestion(
    id: 'q4',
    question: 'Does your child point to share interest with you? (e.g. pointing at an interesting sight)',
    pageNumber: 4,
    options: [
      ScreeningOption(id: 'q4_yes', label: 'Yes', value: 1),
      ScreeningOption(id: 'q4_no', label: 'No', value: 0),
    ],
  ),
  ScreeningQuestion(
    id: 'q5',
    question: 'Does your child pretend? (e.g. care for dolls, talk on a toy phone)',
    pageNumber: 5,
    options: [
      ScreeningOption(id: 'q5_yes', label: 'Yes', value: 1),
      ScreeningOption(id: 'q5_no', label: 'No', value: 0),
    ],
  ),
  ScreeningQuestion(
    id: 'q6',
    question: 'Does your child follow where you are looking?',
    pageNumber: 6,
    options: [
      ScreeningOption(id: 'q6_yes', label: 'Yes', value: 1),
      ScreeningOption(id: 'q6_no', label: 'No', value: 0),
    ],
  ),
  ScreeningQuestion(
    id: 'q7',
    question: 'If you or someone else in the family is visibly upset, does your child show signs of wanting to comfort them?',
    pageNumber: 7,
    options: [
      ScreeningOption(id: 'q7_yes', label: 'Yes', value: 1),
      ScreeningOption(id: 'q7_no', label: 'No', value: 0),
    ],
  ),
  ScreeningQuestion(
    id: 'q8',
    question: 'Would you describe your child\'s first words as:',
    pageNumber: 8,
    options: [
      ScreeningOption(id: 'q8_yes', label: 'YES — simple words like "mama", "bye"', value: 1),
      ScreeningOption(id: 'q8_no', label: 'NO — more complex phrases and sentence-like speech', value: 0),
    ],
  ),
  ScreeningQuestion(
    id: 'q9',
    question: 'Does your child use simple gestures? (e.g. wave goodbye)',
    pageNumber: 9,
    options: [
      ScreeningOption(id: 'q9_yes', label: 'Yes', value: 1),
      ScreeningOption(id: 'q9_no', label: 'No', value: 0),
    ],
  ),
  ScreeningQuestion(
    id: 'q10',
    question: 'Does your child stare at nothing with no apparent purpose?',
    pageNumber: 10,
    options: [
      ScreeningOption(id: 'q10_yes', label: 'Yes', value: 1),
      ScreeningOption(id: 'q10_no', label: 'No', value: 0),
    ],
  ),
];

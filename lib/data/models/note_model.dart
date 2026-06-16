/// Note model — mirrors Note interface from React notes.ts
class NoteModel {
  final String id;
  final String title;
  final String content;
  final String childId;
  final String createdBy;
  final String createdAt;
  final String updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.childId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: (json['id'] ?? json['noteId'] ?? '').toString(),
      title: (json['title'] ?? 'Note').toString(),
      content: (json['content'] ?? json['body'] ?? '').toString(),
      childId: (json['childId'] ?? json['child_id'] ?? '').toString(),
      createdBy: (json['createdBy'] ?? json['specialistId'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt: (json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'childId': childId,
      };

  NoteModel copyWith({String? title, String? content}) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      childId: childId,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

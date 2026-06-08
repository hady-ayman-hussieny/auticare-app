import 'package:auticare/data/models/note_model.dart';
import 'package:auticare/data/services/api_client.dart';

class NotesService {
  /// GET /notes/my-notes — returns all notes by the current specialist
  Future<List<NoteModel>> getMyNotes() async {
    try {
      final res = await api.get<dynamic>('/notes/my-notes');
      final list = res.data is List ? res.data as List : [];
      return list.whereType<Map<String, dynamic>>().map(NoteModel.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  /// GET /notes/child/:childId — returns all notes for a specific child
  Future<List<NoteModel>> getChildNotes(String childId) async {
    try {
      final res = await api.get<dynamic>('/notes/child/$childId');
      final list = res.data is List ? res.data as List : [];
      return list.whereType<Map<String, dynamic>>().map(NoteModel.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  /// POST /notes — create a new note
  Future<NoteModel?> createNote({
    required String title,
    required String content,
    required String childId,
  }) async {
    try {
      final res = await api.post<Map<String, dynamic>>(
        '/notes',
        data: {'title': title, 'content': content, 'childId': childId},
      );
      return NoteModel.fromJson(res.data!);
    } catch (_) {
      return null;
    }
  }

  /// PUT /notes/:id — update an existing note
  Future<NoteModel?> updateNote(String id, {String? title, String? content}) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      final res = await api.put<Map<String, dynamic>>('/notes/$id', data: data);
      return NoteModel.fromJson(res.data!);
    } catch (_) {
      return null;
    }
  }

  /// DELETE /notes/:id — delete a note
  Future<bool> deleteNote(String id) async {
    try {
      await api.delete<dynamic>('/notes/$id');
      return true;
    } catch (_) {
      return false;
    }
  }
}

final notesService = NotesService();

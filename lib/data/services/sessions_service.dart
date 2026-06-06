import 'package:auticare/data/models/notification_model.dart';
import 'package:auticare/data/services/api_client.dart';

class SessionsService {
  Future<List<TherapySessionModel>> getUpcomingSessions() async {
    try {
      final res = await api.get<dynamic>('/sessions/upcoming');
      final list = res.data is List ? res.data as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(TherapySessionModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}

final sessionsService = SessionsService();

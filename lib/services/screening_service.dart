import '../models/screening.dart';
import 'api_client.dart';

class ScreeningService {
  Future<Map<String, dynamic>> startScreening(String childId) async {
    final res = await api.post<Map<String, dynamic>>(
      '/screening/start',
      data: {'childId': childId},
    );
    return res.data ?? {};
  }

  Future<ScreeningResult> submitScreening(
    String childId,
    List<Map<String, dynamic>> answers,
  ) async {
    final res = await api.post<Map<String, dynamic>>(
      '/screening/submit',
      data: {
        'childId': int.tryParse(childId) ?? childId,
        'answers': answers,
      },
    );
    return ScreeningResult.fromJson(res.data!);
  }

  Future<List<ScreeningResult>> getResults(String childId) async {
    final res = await api.get<dynamic>('/screening/results/$childId');
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ScreeningResult.fromJson)
          .toList();
    } else if (data is Map<String, dynamic>) {
      return [ScreeningResult.fromJson(data)];
    }
    return [];
  }
}

final screeningService = ScreeningService();

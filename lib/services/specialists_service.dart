import '../models/specialist.dart';
import 'api_client.dart';

class SpecialistsService {
  Future<List<SpecialistModel>> getSpecialists({String? type}) async {
    final res = await api.get<dynamic>('/specialists');
    final data = res.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      list = (data['data'] ?? data['specialists'] ?? []) as List<dynamic>;
    } else {
      list = [];
    }
    final all = list
        .whereType<Map<String, dynamic>>()
        .map(SpecialistModel.fromJson)
        .toList();
    if (type != null) return all.where((s) => s.type == type).toList();
    return all;
  }

  Future<SpecialistModel> getSpecialist(String id) async {
    final res = await api.get<dynamic>('/specialists/$id');
    final raw = (res.data is Map && (res.data as Map).containsKey('data'))
        ? (res.data as Map)['data'] as Map<String, dynamic>
        : res.data as Map<String, dynamic>;
    return SpecialistModel.fromJson(raw);
  }

  Future<List<SpecialistModel>> getDoctors() => getSpecialists(type: 'doctor');
  Future<List<SpecialistModel>> getTherapists() => getSpecialists(type: 'therapist');
}

final specialistsService = SpecialistsService();

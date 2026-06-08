import 'package:auticare/data/models/child.dart';
import 'package:auticare/data/services/api_client.dart';

class ChildrenService {
  Future<List<ChildModel>> getChildren() async {
    try {
      final res = await api.get<dynamic>('/children');
      final data = res.data;
      List<dynamic> list = data is List ? data : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ChildModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ChildModel> getChild(String id) async {
    final res = await api.get<Map<String, dynamic>>('/children/$id');
    return ChildModel.fromJson(res.data!);
  }

  Future<ChildModel> createChild(Map<String, dynamic> data) async {
    final res = await api.post<Map<String, dynamic>>('/children', data: data);
    return ChildModel.fromJson(res.data!);
  }

  Future<ChildModel> updateChild(String id, Map<String, dynamic> data) async {
    final res = await api.put<Map<String, dynamic>>('/children/$id', data: data);
    return ChildModel.fromJson(res.data!);
  }

  Future<void> deleteChild(String id) async {
    await api.delete('/children/$id');
  }
}

final childrenService = ChildrenService();

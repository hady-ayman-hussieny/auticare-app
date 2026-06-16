import 'package:auticare/data/models/treatment_plan_model.dart';
import 'package:auticare/data/services/api_client.dart';

class TreatmentPlansService {
  /// POST /treatment-plans — create a new treatment plan
  Future<TreatmentPlanModel?> createPlan({
    required String childId,
    required String specialistId,
    required String startDate,
    required String goal,
    required String notes,
    String? endDate,
  }) async {
    try {
      final res = await api.post<Map<String, dynamic>>(
        '/treatment-plans',
        data: {
          'childId': childId,
          'specialistId': specialistId,
          'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          'goal': goal,
          'notes': notes,
        },
      );
      return TreatmentPlanModel.fromJson(res.data!);
    } catch (_) {
      return null;
    }
  }

  /// GET /treatment-plans/child/:childId — get all plans for a child
  Future<List<TreatmentPlanModel>> getChildPlans(String childId) async {
    try {
      final res = await api.get<dynamic>('/treatment-plans/child/$childId');
      final list = res.data is List ? res.data as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(TreatmentPlanModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// GET /treatment-plans/my-plans — all plans assigned to the current specialist
  /// Falls back to fetching by child IDs from bookings if endpoint fails
  Future<List<TreatmentPlanModel>> getMyPlans() async {
    try {
      final res = await api.get<dynamic>('/treatment-plans/my-plans');
      final list = res.data is List ? res.data as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(TreatmentPlanModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// GET /treatment-plans/:id — get a single plan by ID
  Future<TreatmentPlanModel?> getPlan(String id) async {
    try {
      final res = await api.get<dynamic>('/treatment-plans/$id');
      if (res.data is Map<String, dynamic>) {
        return TreatmentPlanModel.fromJson(res.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// PUT /treatment-plans/:id — update a plan
  Future<TreatmentPlanModel?> updatePlan(String id, Map<String, dynamic> data) async {
    try {
      final res = await api.put<Map<String, dynamic>>('/treatment-plans/$id', data: data);
      return TreatmentPlanModel.fromJson(res.data!);
    } catch (_) {
      return null;
    }
  }
}

final treatmentPlansService = TreatmentPlansService();

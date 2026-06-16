import 'package:auticare/data/models/dashboard_model.dart';
import 'package:auticare/data/services/api_client.dart';

class DashboardService {
  /// Fetches specialist dashboard stats — GET /dashboard/specialist
  Future<DashboardSpecialistModel> getSpecialistDashboard() async {
    try {
      final res = await api.get<dynamic>('/dashboard/specialist');
      if (res.data is Map<String, dynamic>) {
        return DashboardSpecialistModel.fromJson(res.data as Map<String, dynamic>);
      }
      return DashboardSpecialistModel.empty;
    } catch (_) {
      return DashboardSpecialistModel.empty;
    }
  }

  /// Fetches parent dashboard stats — GET /dashboard/parent
  Future<DashboardParentModel> getParentDashboard() async {
    try {
      final res = await api.get<dynamic>('/dashboard/parent');
      if (res.data is Map<String, dynamic>) {
        return DashboardParentModel.fromJson(res.data as Map<String, dynamic>);
      }
      return DashboardParentModel.empty;
    } catch (_) {
      return DashboardParentModel.empty;
    }
  }
}

final dashboardService = DashboardService();

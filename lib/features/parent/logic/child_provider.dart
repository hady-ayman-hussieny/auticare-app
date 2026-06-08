import 'package:flutter/foundation.dart';
import 'package:auticare/data/models/child.dart';
import 'package:auticare/data/services/children_service.dart';

/// Centralized provider for the current user's children list.
/// Consumed by ParentHomeScreen and any screen that needs the child list.
class ChildProvider extends ChangeNotifier {
  List<ChildModel> _children = [];
  bool _loading = false;
  String? _error;

  List<ChildModel> get children => _children;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _children = await childrenService.getMyChildren();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void addChild(ChildModel child) {
    _children = [..._children, child];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

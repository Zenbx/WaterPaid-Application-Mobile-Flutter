import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/models.dart';
import 'auth_provider.dart';

class DashboardState {
  final DashboardDataModel? data;
  final bool isLoading;
  final String? error;

  DashboardState({this.data, this.isLoading = false, this.error});

  DashboardState copyWith({
    DashboardDataModel? data,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    // Trigger initial fetch
    Future.microtask(() => fetchDashboard());
    return DashboardState(isLoading: true);
  }

  Future<void> fetchDashboard() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      debugPrint('DEBUG: fetchDashboard - No User ID found');
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      debugPrint('DEBUG: Calling getDashboard($userId)...');
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getDashboard(userId);
      debugPrint('DEBUG: getDashboard response received');
      final data = DashboardDataModel.fromJson(response.data);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e, stack) {
      debugPrint('DEBUG: Dashboard Fetch Error: $e');
      debugPrint('DEBUG: StackTrace: $stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard',
      );
    }
  }

  Future<void> unlinkMeter(String meterId) async {
    state = state.copyWith(isLoading: true);
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.unlinkMeter(meterId);
      await fetchDashboard();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to unlink meter');
    }
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/models.dart';
import 'auth_provider.dart';
import '../core/notification_service.dart';

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
  Timer? _refreshTimer;
  double? _previousBalance;
  bool _lowCreditNotifSent = false;

  @override
  DashboardState build() {
    // Initial fetch
    Future.microtask(() => fetchDashboard());

    // Setup periodic refresh (every 15 seconds) for real-time telemetry
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchDashboard(isBackground: true);
    });

    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return DashboardState(isLoading: true);
  }

  Future<void> fetchDashboard({bool isBackground = false}) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      debugPrint('DEBUG: fetchDashboard - No User ID found');
      state = state.copyWith(isLoading: false);
      return;
    }

    if (!isBackground) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      debugPrint('DEBUG: Calling getDashboard($userId)...');
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getDashboard(userId);
      debugPrint('DEBUG: getDashboard response received');
      final data = DashboardDataModel.fromJson(response.data);
      state = state.copyWith(data: data, isLoading: false);

      // Trigger notifications based on state
      _checkNotifications(data);
    } catch (e) {
      debugPrint('DEBUG: Dashboard Fetch Error: $e');
      if (!isBackground) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load dashboard',
        );
      }
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

  void _checkNotifications(DashboardDataModel data) {
    final notificationService = NotificationService();
    final current = data.currentBalance;

    // Credit just hit zero for the first time (transition from >0 to <=0)
    if (_previousBalance != null && _previousBalance! > 0 && current <= 0) {
      notificationService.alertCreditExhausted();
    }

    // Low credit: only notify once per session when crossing the threshold
    if (!_lowCreditNotifSent && current > 0 && current < 500) {
      _lowCreditNotifSent = true;
      notificationService.showNotification(
        id: 10,
        title: 'Crédit Faible',
        body: 'Crédit Faible, Veuillez recharger.',
      );
    }

    // Reset low-credit flag if balance is topped up
    if (current >= 500) {
      _lowCreditNotifSent = false;
    }

    _previousBalance = current;
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../core/api_service.dart';

class AdminDashboardState {
  final List<AdminMeterModel> recentMeters;
  final List<AdminUserModel> recentUsers;
  final List<TransactionModel> recentTransactions;
  final double totalRevenue;
  final double totalWaterDistributed;
  final int activeMetersCount;
  final int totalUsersCount;
  final bool isLoading;
  final String? error;

  AdminDashboardState({
    this.recentMeters = const [],
    this.recentUsers = const [],
    this.recentTransactions = const [],
    this.totalRevenue = 0,
    this.totalWaterDistributed = 0,
    this.activeMetersCount = 0,
    this.totalUsersCount = 0,
    this.isLoading = false,
    this.error,
  });

  AdminDashboardState copyWith({
    List<AdminMeterModel>? recentMeters,
    List<AdminUserModel>? recentUsers,
    List<TransactionModel>? recentTransactions,
    double? totalRevenue,
    double? totalWaterDistributed,
    int? activeMetersCount,
    int? totalUsersCount,
    bool? isLoading,
    String? error,
  }) {
    return AdminDashboardState(
      recentMeters: recentMeters ?? this.recentMeters,
      recentUsers: recentUsers ?? this.recentUsers,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalWaterDistributed:
          totalWaterDistributed ?? this.totalWaterDistributed,
      activeMetersCount: activeMetersCount ?? this.activeMetersCount,
      totalUsersCount: totalUsersCount ?? this.totalUsersCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminDashboardNotifier extends Notifier<AdminDashboardState> {
  @override
  AdminDashboardState build() {
    _fetchData();
    return AdminDashboardState(isLoading: true);
  }

  Future<void> _fetchData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);
      debugPrint('DEBUG: _fetchData - Calling unified getAdminDashboard');

      final response = await api.getAdminDashboard().timeout(
        const Duration(seconds: 40),
      );

      final data = response.data as Map<String, dynamic>;

      final List<AdminMeterModel> recentMeters = (data['recent_meters'] as List)
          .map((m) => AdminMeterModel.fromJson(m))
          .toList();

      final List<AdminUserModel> recentUsers = (data['recent_users'] as List)
          .map((u) => AdminUserModel.fromJson(u))
          .toList();

      final List<TransactionModel> recentTransactions =
          (data['recent_transactions'] as List)
              .map((t) => TransactionModel.fromJson(t))
              .toList();

      state = state.copyWith(
        recentMeters: recentMeters,
        recentUsers: recentUsers,
        recentTransactions: recentTransactions,
        totalRevenue: (data['total_revenue'] ?? 0).toDouble(),
        totalWaterDistributed: (data['total_water'] ?? 0).toDouble(),
        activeMetersCount: data['active_meters_count'] ?? 0,
        totalUsersCount: data['total_users_count'] ?? 0,
        isLoading: false,
      );
      debugPrint('DEBUG: _fetchData - State updated with unified stats');
    } catch (e, stack) {
      debugPrint('DEBUG: _fetchData Error: $e');
      debugPrint('DEBUG: StackTrace: $stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard data',
      );
    }
  }

  Future<void> refresh() => _fetchData();
}

final adminDashboardProvider =
    NotifierProvider<AdminDashboardNotifier, AdminDashboardState>(
      AdminDashboardNotifier.new,
    );

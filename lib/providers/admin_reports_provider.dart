import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../core/api_service.dart';

class AdminReportsState {
  final List<ReportModel> reports;
  final bool isLoading;
  final String? error;

  AdminReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
  });

  AdminReportsState copyWith({
    List<ReportModel>? reports,
    bool? isLoading,
    String? error,
  }) {
    return AdminReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminReportsNotifier extends Notifier<AdminReportsState> {
  @override
  AdminReportsState build() {
    _fetchReports();
    return AdminReportsState(isLoading: true);
  }

  Future<void> _fetchReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.getAdminReports();
      final List<ReportModel> reports = (response.data as List)
          .map((r) => ReportModel.fromJson(r))
          .toList();
      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load reports');
    }
  }

  Future<void> refresh() => _fetchReports();

  Future<void> createReport(DateTime start, DateTime end, String format) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.createAdminReport(
        startedAt: start.toIso8601String(),
        endedAt: end.toIso8601String(),
        format: format,
      );
      await _fetchReports();
    } catch (e) {
      rethrow;
    }
  }
}

final adminReportsProvider =
    NotifierProvider<AdminReportsNotifier, AdminReportsState>(
      AdminReportsNotifier.new,
    );

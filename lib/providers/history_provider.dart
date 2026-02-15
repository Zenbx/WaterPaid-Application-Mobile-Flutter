import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../models/models.dart';
import 'auth_provider.dart';

class HistoryState {
  final List<RefillModel> refills;
  final bool isLoading;
  final String? error;

  HistoryState({this.refills = const [], this.isLoading = false, this.error});

  HistoryState copyWith({
    List<RefillModel>? refills,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      refills: refills ?? this.refills,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    return HistoryState();
  }

  Future<void> fetchHistory() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ref.read(apiServiceProvider).getHistory(userId);
      final List<dynamic> historyData = response.data;
      final refills = historyData
          .map((json) => RefillModel.fromJson(json))
          .toList();

      // Sort by date descending
      refills.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(refills: refills, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load history');
    }
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);

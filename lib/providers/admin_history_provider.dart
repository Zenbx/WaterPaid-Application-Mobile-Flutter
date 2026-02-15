import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../core/api_service.dart';

class AdminHistoryState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;

  AdminHistoryState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  AdminHistoryState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return AdminHistoryState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminHistoryNotifier extends Notifier<AdminHistoryState> {
  @override
  AdminHistoryState build() => AdminHistoryState();

  Future<void> fetchHistory(String targetId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.getAdminHistory(targetId);
      final List<TransactionModel> transactions = (response.data as List)
          .map((t) => TransactionModel.fromJson(t))
          .toList();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load history');
    }
  }
}

final adminHistoryProvider =
    NotifierProvider<AdminHistoryNotifier, AdminHistoryState>(
      AdminHistoryNotifier.new,
    );

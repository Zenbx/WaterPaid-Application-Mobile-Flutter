import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../core/api_service.dart';

class AdminUsersState {
  final List<AdminUserModel> users;
  final bool isLoading;
  final String? error;

  AdminUsersState({this.users = const [], this.isLoading = false, this.error});

  AdminUsersState copyWith({
    List<AdminUserModel>? users,
    bool? isLoading,
    String? error,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminUsersNotifier extends Notifier<AdminUsersState> {
  @override
  AdminUsersState build() {
    _fetchUsers();
    return AdminUsersState(isLoading: true);
  }

  Future<void> _fetchUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      debugPrint('DEBUG: _fetchUsers - Calling getAdminUsers...');
      final api = ref.read(apiServiceProvider);
      final response = await api.getAdminUsers().timeout(
        const Duration(seconds: 40),
      );
      debugPrint('DEBUG: _fetchUsers - Response received');
      final List<AdminUserModel> users = (response.data as List)
          .map((u) => AdminUserModel.fromJson(u))
          .toList();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e, stack) {
      debugPrint('DEBUG: _fetchUsers Error: $e');
      debugPrint('DEBUG: StackTrace: $stack');
      state = state.copyWith(isLoading: false, error: 'Failed to load users');
    }
  }

  Future<void> refresh() => _fetchUsers();
}

final adminUsersProvider =
    NotifierProvider<AdminUsersNotifier, AdminUsersState>(
      AdminUsersNotifier.new,
    );

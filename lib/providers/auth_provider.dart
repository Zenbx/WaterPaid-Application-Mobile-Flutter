import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_service.dart';
import '../models/models.dart';

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final bool isInitializing;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.isInitializing = true,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    bool? isInitializing,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      error: error,
    );
  }

  bool get isAuthenticated => token != null && user != null;
  bool get isAdmin => user?.userType == 'admin';
}

class AuthNotifier extends Notifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    _loadStoredAuth();
    return AuthState();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final token = await _storage.read(key: 'user_token');
      final userId = await _storage.read(key: 'user_id');
      final pseudo = await _storage.read(key: 'user_pseudo');
      final phone = await _storage.read(key: 'user_phone');
      final userType = await _storage.read(key: 'user_type') ?? 'user';

      if (token != null && userId != null) {
        // Validate token with backend
        final apiService = ref.read(apiServiceProvider);
        try {
          // For admins, validate by fetching admin meters; for users, use dashboard
          if (userType == 'admin') {
            await apiService.getAdminMeters();
          } else {
            await apiService.getDashboard(userId);
          }

          state = state.copyWith(
            token: token,
            user: UserModel(
              id: userId,
              pseudo: pseudo ?? 'User',
              phoneNumber: phone ?? '',
              userType: userType,
            ),
            isInitializing: false,
          );
        } catch (e) {
          // Token is invalid or server error
          await logout();
        }
      } else {
        state = state.copyWith(isInitializing: false);
      }
    } catch (e) {
      state = state.copyWith(isInitializing: false);
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.login(phone, password);
      final data = response.data;

      print('=== LOGIN RESPONSE DATA ===');
      print('Full data keys: ${data.keys.toList()}');
      print('Full data: $data');

      final token = data['access_token'] ?? data['token'];

      // The user object might be nested or at the top level
      final userData = data['user'];
      print('User data: $userData');
      print('User data type: ${userData.runtimeType}');

      UserModel user;
      if (userData != null && userData is Map<String, dynamic>) {
        user = UserModel.fromJson(userData);
        print('Parsed user_type from user object: ${user.userType}');
      } else {
        // Fallback: build UserModel from top-level data
        user = UserModel.fromJson(data is Map<String, dynamic> ? data : {});
        print('Parsed user_type from top-level: ${user.userType}');
      }

      // Extra fallback: if user_type is still 'user' but the token contains admin type
      // we can detect it from a successful admin endpoint call
      if (user.userType == 'user') {
        // Check if there's a user_type at the top level of the response
        final topLevelType = data['user_type']?.toString();
        if (topLevelType == 'admin') {
          user = UserModel(
            id: user.id,
            pseudo: user.pseudo,
            phoneNumber: user.phoneNumber,
            email: user.email,
            userType: 'admin',
          );
          print('Corrected user_type from top-level field: admin');
        }
      }

      print('=== FINAL USER TYPE: ${user.userType} ===');

      await _storage.write(key: 'user_token', value: token);
      await _storage.write(key: 'user_id', value: user.id);
      await _storage.write(key: 'user_pseudo', value: user.pseudo);
      await _storage.write(key: 'user_phone', value: user.phoneNumber);
      await _storage.write(key: 'user_type', value: user.userType);

      state = state.copyWith(token: token, user: user, isLoading: false);
    } catch (e) {
      print('Login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please check your credentials.',
      );
    }
  }

  Future<void> signup(
    String phone,
    String pseudo,
    String password, {
    String userType = 'user',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.signup(phone, pseudo, password, userType: userType);
      // After signup, auto-login
      await login(phone, password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Signup failed. Please try again.',
      );
    }
  }

  Future<void> updateProfile({
    String? pseudo,
    String? phone,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = state.isAdmin
          ? await apiService.updateAdminProfile(
              pseudo: pseudo,
              phone: phone,
              email: email,
            )
          : await apiService.updateProfile(
              pseudo: pseudo,
              phone: phone,
              email: email,
            );

      final userData = response.data;
      final updatedUser = UserModel.fromJson(userData);

      // Persist changes
      await _storage.write(key: 'user_pseudo', value: updatedUser.pseudo);
      await _storage.write(key: 'user_phone', value: updatedUser.phoneNumber);

      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      debugPrint('Update profile error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile. Please try again.',
      );
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiService = ref.read(apiServiceProvider);
      if (state.isAdmin) {
        await apiService.changeAdminPassword(oldPassword, newPassword);
      } else {
        await apiService.changePassword(oldPassword, newPassword);
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Change password error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to change password. Old password might be incorrect.',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = AuthState(isInitializing: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

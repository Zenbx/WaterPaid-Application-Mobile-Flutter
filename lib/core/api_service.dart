import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://waterpaid-api.onrender.com',
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'user_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          return handler.next(e);
        },
      ),
    );

    // Add logging to see requests in terminal
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
  }

  // ============================================================
  // Auth Methods
  // ============================================================

  Future<Response> login(String phone, String password) {
    return _dio.post(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
  }

  Future<Response> signup(
    String phone,
    String pseudo,
    String password, {
    String userType = 'user',
  }) {
    return _dio.post(
      '/auth/signup',
      data: {
        'user_phone': phone,
        'user_pseudo': pseudo,
        'user_password': password,
        'user_type': userType,
      },
    );
  }

  // ============================================================
  // User Methods (existing)
  // ============================================================

  Future<Response> getDashboard(String userId) {
    return _dio.get('/u/dashboard/$userId');
  }

  Future<Response> getHistory(String userId) {
    return _dio.get('/u/history/$userId');
  }

  Future<Response> linkMeter(String token) {
    return _dio.post('/u/meter', data: {'token': token});
  }

  Future<Response> unlinkMeter(String meterId) {
    return _dio.delete('/u/meter/$meterId');
  }

  Future<Response> createRefill(String meterId, double price, String method) {
    return _dio.post(
      '/u/refill/$meterId',
      data: {'price': price, 'volume': 0, 'payment_method': method},
    );
  }

  // --- Profile Management ---
  Future<Response> updateProfile({
    String? pseudo,
    String? phone,
    String? email,
  }) {
    final data = <String, dynamic>{};
    if (pseudo != null) data['user_pseudo'] = pseudo;
    if (phone != null) data['user_phone'] = phone;
    if (email != null) data['user_email'] = email;
    return _dio.put('/u/me/', data: data);
  }

  Future<Response> changePassword(String oldPassword, String newPassword) {
    return _dio.put(
      '/u/me/change-password',
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  // ============================================================
  // Admin Methods
  // ============================================================

  // --- Meters ---
  Future<Response> getAdminMeters() {
    return _dio.get('/a/meters');
  }

  Future<Response> getAdminMeter(String meterId) {
    return _dio.get('/a/meters/$meterId');
  }

  Future<Response> createAdminMeter(String serialId, {String? deviceId}) {
    final data = <String, dynamic>{'serial_id': serialId};
    if (deviceId != null) data['device_id'] = deviceId;
    return _dio.post('/a/meters', data: data);
  }

  Future<Response> updateAdminMeter(
    String meterId, {
    String? meterState,
    String? userId,
    bool? attributed,
  }) {
    final data = <String, dynamic>{};
    if (meterState != null) data['meter_state'] = meterState;
    if (userId != null) data['user_id'] = userId;
    if (attributed != null) data['attributed'] = attributed;
    return _dio.put('/a/meters/$meterId', data: data);
  }

  Future<Response> deleteAdminMeter(String meterId) {
    return _dio.delete('/a/meters/$meterId');
  }

  Future<Response> unlinkUserFromMeter(String meterId) {
    return _dio.post('/a/meters/$meterId/unlink-user');
  }

  Future<Response> generateMeterToken(String meterId) {
    return _dio.post('/a/meters/$meterId/generate-token');
  }

  Future<Response> linkDevice(String meterId, String deviceId) {
    return _dio.post(
      '/a/meters/$meterId/link-device',
      queryParameters: {'device_id': deviceId},
    );
  }

  // --- Admin Refill ---
  Future<Response> adminRefillMeter(
    String meterId, {
    required double price,
    required double volume,
    required String method,
  }) {
    return _dio.post(
      '/a/refill-meters/$meterId',
      data: {'price': price, 'volume': volume, 'refill_method': method},
    );
  }

  // --- Users ---
  Future<Response> getAdminUsers({int skip = 0, int limit = 100}) {
    return _dio.get(
      '/a/users',
      queryParameters: {'skip': skip, 'limit': limit},
    );
  }

  // --- Histories ---
  Future<Response> getAdminHistory(String id, {int skip = 0, int limit = 100}) {
    return _dio.get(
      '/a/histories/$id',
      queryParameters: {'skip': skip, 'limit': limit},
    );
  }

  // --- Reports ---
  Future<Response> getAdminReports({int skip = 0, int limit = 50}) {
    return _dio.get(
      '/a/reports',
      queryParameters: {'skip': skip, 'limit': limit},
    );
  }

  Future<Response> createAdminReport({
    required String startedAt,
    required String endedAt,
    String format = 'CSV',
  }) {
    return _dio.post(
      '/a/reports',
      data: {'started_at': startedAt, 'ended_at': endedAt, 'format': format},
    );
  }

  // --- Profile Management ---
  Future<Response> updateAdminProfile({
    String? pseudo,
    String? phone,
    String? email,
  }) {
    final data = <String, dynamic>{};
    if (pseudo != null) data['admin_pseudo'] = pseudo;
    if (phone != null) data['admin_phone'] = phone;
    if (email != null) data['admin_email'] = email;
    return _dio.put('/a/me/', data: data);
  }

  Future<Response> changeAdminPassword(String oldPassword, String newPassword) {
    return _dio.put(
      '/a/me/change-password',
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  Future<Response> getAdminDashboard() {
    return _dio.get('/a/dashboard/');
  }
}

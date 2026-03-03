import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../core/api_service.dart';

class AdminMetersState {
  final List<AdminMeterModel> meters;
  final bool isLoading;
  final String? error;

  AdminMetersState({
    this.meters = const [],
    this.isLoading = false,
    this.error,
  });

  AdminMetersState copyWith({
    List<AdminMeterModel>? meters,
    bool? isLoading,
    String? error,
  }) {
    return AdminMetersState(
      meters: meters ?? this.meters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminMetersNotifier extends Notifier<AdminMetersState> {
  @override
  AdminMetersState build() {
    Future.microtask(() => _fetchMeters());
    return AdminMetersState(isLoading: true);
  }

  Future<void> _fetchMeters() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      debugPrint('DEBUG: _fetchMeters - Calling getAdminMeters...');
      final api = ref.read(apiServiceProvider);
      final response = await api.getAdminMeters().timeout(
        const Duration(seconds: 40),
      );
      debugPrint('DEBUG: _fetchMeters - Response received');
      final List<AdminMeterModel> meters = (response.data as List)
          .map((m) => AdminMeterModel.fromJson(m))
          .toList();
      state = state.copyWith(meters: meters, isLoading: false);
    } catch (e, stack) {
      debugPrint('DEBUG: _fetchMeters Error: $e');
      debugPrint('DEBUG: StackTrace: $stack');
      state = state.copyWith(isLoading: false, error: 'Failed to load meters');
    }
  }

  Future<void> refresh() => _fetchMeters();

  Future<void> createMeter(String serialId, {String? deviceId}) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.createAdminMeter(serialId, deviceId: deviceId);
      await _fetchMeters();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMeter(String meterId) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.deleteAdminMeter(meterId);
      await _fetchMeters();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlinkUser(String meterId) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.unlinkUserFromMeter(meterId);
      await _fetchMeters();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> generateToken(String meterId) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.generateMeterToken(meterId);
      await _fetchMeters();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> linkDevice(String meterId, String deviceId) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.linkDevice(meterId, deviceId);
      await _fetchMeters();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refillMeter(String meterId, double volume, double price) async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.adminRefillMeter(
        meterId,
        price: price,
        volume: volume,
        method: 'CASH',
      );
      await _fetchMeters();
    } catch (e) {
      rethrow;
    }
  }
}

final adminMetersProvider =
    NotifierProvider<AdminMetersNotifier, AdminMetersState>(
      AdminMetersNotifier.new,
    );

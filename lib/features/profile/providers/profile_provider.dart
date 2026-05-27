// =============================================================================
// profile_provider.dart — Gestión de perfil de usuario
// =============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/storage_service.dart';

/// Provider de perfil del usuario: nombre, método de login y avatar.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required this.storageService});

  final StorageService storageService;

  String _name = '';
  String _loginMethod = '';
  String _avatarEmoji = '🌱';

  bool get hasProfile => _name.isNotEmpty;
  String get name => _name;
  String get loginMethod => _loginMethod;
  String get avatarEmoji => _avatarEmoji;

  Future<void> loadProfile() async {
    final data = storageService.readProfile();
    _name        = (data['name']        as String?) ?? '';
    _loginMethod = (data['loginMethod'] as String?) ?? '';
    _avatarEmoji = (data['avatar']      as String?) ?? '🌱';
    notifyListeners();
  }

  /// Persiste el perfil y notifica a los listeners.
  ///
  /// [name] es sanitizado por [StorageService] antes de guardarse.
  Future<void> saveProfile({
    required String name,
    required String loginMethod,
    String avatarEmoji = '🌱',
  }) async {
    _name        = name.trim();
    _loginMethod = loginMethod;
    _avatarEmoji = avatarEmoji;
    await storageService.saveProfile({
      'name':        _name,
      'loginMethod': _loginMethod,
      'avatar':      _avatarEmoji,
    });
    notifyListeners();
  }
}

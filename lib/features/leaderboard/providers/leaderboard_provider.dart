// =============================================================================
// leaderboard_provider.dart — Ranking global de rachas
// =============================================================================

import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// MODELO
// ---------------------------------------------------------------------------

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.countryFlag,
    required this.streak,
    this.isCurrentUser = false,
  });

  final String id;
  final String name;
  final String avatarEmoji;
  final String countryFlag;
  final int streak;
  final bool isCurrentUser;

  LeaderboardEntry copyWith({int? streak, bool? isCurrentUser}) {
    return LeaderboardEntry(
      id: id,
      name: name,
      avatarEmoji: avatarEmoji,
      countryFlag: countryFlag,
      streak: streak ?? this.streak,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

// ---------------------------------------------------------------------------
// COMUNIDAD PRE-SEMBRADA
// ---------------------------------------------------------------------------

const List<LeaderboardEntry> _kCommunity = [
  LeaderboardEntry(
      id: 'c01',
      name: 'María García',
      avatarEmoji: '🌻',
      countryFlag: '🇲🇽',
      streak: 62),
  LeaderboardEntry(
      id: 'c02',
      name: 'Liam Chen',
      avatarEmoji: '🌊',
      countryFlag: '🇨🇳',
      streak: 55),
  LeaderboardEntry(
      id: 'c03',
      name: 'Ana López',
      avatarEmoji: '🦋',
      countryFlag: '🇨🇴',
      streak: 48),
  LeaderboardEntry(
      id: 'c04',
      name: 'Sofia Müller',
      avatarEmoji: '🌿',
      countryFlag: '🇩🇪',
      streak: 41),
  LeaderboardEntry(
      id: 'c05',
      name: 'Carlos Ruiz',
      avatarEmoji: '☀️',
      countryFlag: '🇦🇷',
      streak: 37),
  LeaderboardEntry(
      id: 'c06',
      name: 'Emma Wilson',
      avatarEmoji: '🐝',
      countryFlag: '🇬🇧',
      streak: 33),
  LeaderboardEntry(
      id: 'c07',
      name: 'Yuki Tanaka',
      avatarEmoji: '🍃',
      countryFlag: '🇯🇵',
      streak: 29),
  LeaderboardEntry(
      id: 'c08',
      name: 'Diego Morales',
      avatarEmoji: '🌍',
      countryFlag: '🇵🇪',
      streak: 25),
  LeaderboardEntry(
      id: 'c09',
      name: 'Priya Sharma',
      avatarEmoji: '🌸',
      countryFlag: '🇮🇳',
      streak: 22),
  LeaderboardEntry(
      id: 'c10',
      name: 'Lucas Martin',
      avatarEmoji: '🔥',
      countryFlag: '🇫🇷',
      streak: 19),
  LeaderboardEntry(
      id: 'c11',
      name: 'Nadia Kowalski',
      avatarEmoji: '❄️',
      countryFlag: '🇵🇱',
      streak: 16),
  LeaderboardEntry(
      id: 'c12',
      name: 'Omar Hassan',
      avatarEmoji: '🌈',
      countryFlag: '🇪🇬',
      streak: 13),
  LeaderboardEntry(
      id: 'c13',
      name: 'Isabella Costa',
      avatarEmoji: '🌱',
      countryFlag: '🇧🇷',
      streak: 11),
  LeaderboardEntry(
      id: 'c14',
      name: 'Ravi Patel',
      avatarEmoji: '⚡',
      countryFlag: '🇮🇳',
      streak: 8),
  LeaderboardEntry(
      id: 'c15',
      name: 'Claire Dubois',
      avatarEmoji: '🍎',
      countryFlag: '🇫🇷',
      streak: 6),
  LeaderboardEntry(
      id: 'c16',
      name: 'Tomás Vega',
      avatarEmoji: '🌬️',
      countryFlag: '🇨🇱',
      streak: 4),
  LeaderboardEntry(
      id: 'c17',
      name: 'Nina Johansson',
      avatarEmoji: '🐾',
      countryFlag: '🇸🇪',
      streak: 3),
  LeaderboardEntry(
      id: 'c18',
      name: 'Jack Roberts',
      avatarEmoji: '♻️',
      countryFlag: '🇦🇺',
      streak: 2),
];

// ---------------------------------------------------------------------------
// PROVIDER
// ---------------------------------------------------------------------------

class LeaderboardProvider extends ChangeNotifier {
  LeaderboardProvider() : _entries = List.of(_kCommunity);

  final List<LeaderboardEntry> _entries;
  String _currentUserName = '';
  String _currentUserAvatar = '🌱';
  int _currentUserStreak = 0;

  static const String _currentUserId = 'me';

  List<LeaderboardEntry> get rankedEntries {
    final list = List.of(_entries);
    list.sort((a, b) => b.streak.compareTo(a.streak));
    return list;
  }

  int get currentUserRank {
    final ranked = rankedEntries;
    final idx = ranked.indexWhere((e) => e.isCurrentUser);
    return idx == -1 ? ranked.length + 1 : idx + 1;
  }

  // Actualiza los datos del usuario actual (llamado desde el shell)
  void updateCurrentUser({
    required String name,
    required String avatarEmoji,
    required int streak,
  }) {
    if (name == _currentUserName &&
        avatarEmoji == _currentUserAvatar &&
        streak == _currentUserStreak) {
      return;
    }

    _currentUserName = name;
    _currentUserAvatar = avatarEmoji;
    _currentUserStreak = streak;

    _entries.removeWhere((e) => e.isCurrentUser);
    _entries.add(LeaderboardEntry(
      id: _currentUserId,
      name: name.isEmpty ? 'Tú' : name,
      avatarEmoji: avatarEmoji,
      countryFlag: '📍',
      streak: streak,
      isCurrentUser: true,
    ));
    notifyListeners();
  }
}

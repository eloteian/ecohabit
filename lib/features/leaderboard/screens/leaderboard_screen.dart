// =============================================================================
// leaderboard_screen.dart — Ranking global de rachas
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/eco_theme_colors.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Consumer<LeaderboardProvider>(
        builder: (context, lb, _) {
          final entries = lb.rankedEntries;
          final userRank = lb.currentUserRank;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                snap: true,
                backgroundColor: context.colors.background,
                title: Text('Ranking Global',
                    style: Theme.of(context).textTheme.titleLarge),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding, 8,
                    AppSizes.screenPadding, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    _PodiumSection(entries: entries.take(3).toList()),
                    const SizedBox(height: AppSizes.lg),

                    if (userRank > 3) ...[
                      _YourPositionBanner(rank: userRank, entries: entries),
                      const SizedBox(height: AppSizes.md),
                    ],

                    _RankingList(entries: entries),

                    const SizedBox(height: AppSizes.xl),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// PODIO
// =============================================================================

class _PodiumSection extends StatelessWidget {
  const _PodiumSection({required this.entries});
  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox.shrink();

    final gold   = entries[0];
    final silver = entries[1];
    final bronze = entries[2];

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 20, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Esta semana',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
                letterSpacing: 0.5,
              )),
          const SizedBox(height: AppSizes.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _PodiumSlot(entry: silver, rank: 2, height: 80)),
              const SizedBox(width: AppSizes.sm),
              Expanded(child: _PodiumSlot(entry: gold,   rank: 1, height: 104)),
              const SizedBox(width: AppSizes.sm),
              Expanded(child: _PodiumSlot(entry: bronze, rank: 3, height: 68)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.rank,
    required this.height,
  });

  final LeaderboardEntry entry;
  final int rank;
  final double height;

  static const _medals = ['🥇', '🥈', '🥉'];
  static const _colors = [
    Color(0xFFFFD700),
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
  ];

  @override
  Widget build(BuildContext context) {
    final medal = _medals[rank - 1];
    final color = _colors[rank - 1];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.22),
                border: Border.all(
                    color: color.withValues(alpha: 0.70), width: 2.5),
              ),
              child: Center(
                  child: Text(entry.avatarEmoji,
                      style: const TextStyle(fontSize: 24))),
            ),
            Positioned(
              bottom: -4, right: -4,
              child: Text(medal, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          entry.name.split(' ').first,
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 2),

        Text(
          '🔥 ${entry.streak}d',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.90),
          ),
        ),

        const SizedBox(height: AppSizes.xs),

        Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.25),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(
                color: color.withValues(alpha: 0.45), width: 1.5),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// BANNER "TU POSICIÓN"
// =============================================================================

class _YourPositionBanner extends StatelessWidget {
  const _YourPositionBanner({required this.rank, required this.entries});
  final int rank;
  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final me = entries.firstWhere(
        (e) => e.isCurrentUser,
        orElse: () => const LeaderboardEntry(
            id: 'me', name: 'Tú', avatarEmoji: '🌱',
            countryFlag: '📍', streak: 0, isCurrentUser: true));

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text('#$rank',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(me.avatarEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              me.name,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
            ),
            child: Text(
              '🔥 ${me.streak} días',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// LISTA COMPLETA
// =============================================================================

class _RankingList extends StatelessWidget {
  const _RankingList({required this.entries});
  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxStreak = entries.isEmpty ? 1 : entries.first.streak.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Clasificación', style: Theme.of(context).textTheme.titleMedium),
            Text('${entries.length} participantes',
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),

        const SizedBox(height: AppSizes.sm),

        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: entries.asMap().entries.map((e) {
              final rank  = e.key + 1;
              final entry = e.value;
              final pct   = maxStreak > 0
                  ? entry.streak / maxStreak
                  : 0.0;

              return _RankRow(
                rank: rank,
                entry: entry,
                pct: pct,
                isLast: rank == entries.length,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.entry,
    required this.pct,
    required this.isLast,
  });

  final int rank;
  final LeaderboardEntry entry;
  final double pct;
  final bool isLast;

  Color _rankColor() {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = entry.isCurrentUser ? colors.primarySurface : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(
          top: rank == 1
              ? const Radius.circular(AppSizes.radiusMd - 1)
              : Radius.zero,
          bottom: isLast
              ? const Radius.circular(AppSizes.radiusMd - 1)
              : Radius.zero,
        ),
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm + 2),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: rank <= 3
                ? Text(
                    ['🥇', '🥈', '🥉'][rank - 1],
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _rankColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),

          const SizedBox(width: AppSizes.sm),

          Text(entry.avatarEmoji, style: const TextStyle(fontSize: 20)),

          const SizedBox(width: AppSizes.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: entry.isCurrentUser
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: entry.isCurrentUser
                              ? AppColors.primary
                              : colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(entry.countryFlag,
                        style: const TextStyle(fontSize: 12)),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusCircle),
                        ),
                        child: const Text('Tú',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 3),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusCircle),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 5,
                      backgroundColor: colors.surfaceGray,
                      valueColor: AlwaysStoppedAnimation(
                        entry.isCurrentUser
                            ? AppColors.primary
                            : AppColors.primaryLight
                                .withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSizes.sm),

          Text(
            '🔥 ${entry.streak}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: entry.isCurrentUser
                  ? AppColors.primary
                  : colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

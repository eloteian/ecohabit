// =============================================================================
// profile_screen.dart — Perfil de usuario y logros de EcoHabit
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/eco_theme_colors.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../habits/providers/habit_provider.dart';
import '../../statistics/providers/statistics_provider.dart';
import '../providers/profile_provider.dart';

const List<String> _kAvatars = ['🌱', '🌿', '🍃', '🌍', '🌊', '☀️',
                                  '🦋', '🐝', '🌻', '🔥', '❄️', '🌈'];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Consumer3<ProfileProvider, HabitProvider, StatisticsProvider>(
        builder: (context, profile, habits, stats, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                snap: true,
                backgroundColor: context.colors.background,
                title: Text('Perfil',
                    style: Theme.of(context).textTheme.titleLarge),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings_outlined,
                        color: context.colors.textSecondary),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.settings),
                    tooltip: 'Configuración',
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding, 8,
                    AppSizes.screenPadding, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    _ProfileCard(profile: profile),

                    const SizedBox(height: AppSizes.lg),

                    _ActivitySummary(habits: habits, stats: stats),

                    const SizedBox(height: AppSizes.lg),

                    _AchievementsSection(habits: habits, stats: stats),

                    const SizedBox(height: AppSizes.lg),

                    _EditProfileTile(profile: profile),

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
// SUBWIDGETS
// =============================================================================

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});
  final ProfileProvider profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.40), width: 2),
            ),
            child: Center(
              child: Text(
                profile.avatarEmoji,
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),

          const SizedBox(width: AppSizes.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isEmpty ? 'Eco Usuario' : profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircle),
                  ),
                  child: Text(
                    _loginLabel(profile.loginMethod),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _loginLabel(String method) {
    switch (method) {
      case 'apple':  return '🍎  Apple ID';
      case 'google': return '🔵  Google';
      default:       return '📧  Correo';
    }
  }
}

class _ActivitySummary extends StatelessWidget {
  const _ActivitySummary({required this.habits, required this.stats});
  final HabitProvider habits;
  final StatisticsProvider stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actividad',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            _ActivityTile(
              icon: '✅',
              value: '${stats.totalCompletions}',
              label: 'Completaciones',
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSizes.sm),
            _ActivityTile(
              icon: '🔥',
              value: '${habits.globalStreak}',
              label: 'Racha días',
              color: AppColors.energy,
            ),
            const SizedBox(width: AppSizes.sm),
            _ActivityTile(
              icon: '📋',
              value: '${habits.habits.length}',
              label: 'Hábitos',
              color: AppColors.co2,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final String icon, value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                )),
            Text(label,
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.habits, required this.stats});
  final HabitProvider habits;
  final StatisticsProvider stats;

  List<_Achievement> _buildAchievements() {
    final total = stats.totalCompletions;
    final streak = habits.globalStreak;
    final habitCount = habits.habits.length;
    final water = stats.totalWater;
    final co2 = stats.totalCo2;

    return [
      _Achievement(emoji: '🌱', title: 'Primer paso',
          description: 'Completa tu primer hábito', unlocked: total >= 1),
      _Achievement(emoji: '🔥', title: 'En racha',
          description: '7 días consecutivos', unlocked: streak >= 7),
      _Achievement(emoji: '🌍', title: 'Eco Guerrero',
          description: '50 completaciones totales', unlocked: total >= 50),
      _Achievement(emoji: '💧', title: 'Guardián del Agua',
          description: 'Ahorra 500L de agua', unlocked: water >= 500),
      _Achievement(emoji: '🌿', title: 'Carbono Zero',
          description: 'Reduce 10kg de CO₂', unlocked: co2 >= 10),
      _Achievement(emoji: '📚', title: 'Coleccionista',
          description: 'Crea 5 hábitos diferentes', unlocked: habitCount >= 5),
      _Achievement(emoji: '💎', title: 'Campeón Verde',
          description: '100 completaciones totales', unlocked: total >= 100),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _buildAchievements();
    final unlocked = achievements.where((a) => a.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Logros', style: Theme.of(context).textTheme.titleMedium),
            Text('$unlocked / ${achievements.length}',
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSizes.sm,
            mainAxisSpacing: AppSizes.sm,
            childAspectRatio: 0.9,
          ),
          itemCount: achievements.length,
          itemBuilder: (_, i) => _AchievementBadge(achievement: achievements[i]),
        ),
      ],
    );
  }
}

class _Achievement {
  const _Achievement({
    required this.emoji,
    required this.title,
    required this.description,
    required this.unlocked,
  });
  final String emoji, title, description;
  final bool unlocked;
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});
  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unlocked = achievement.unlocked;
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: unlocked ? colors.primarySurface : colors.surfaceGray,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: unlocked
              ? AppColors.primary.withValues(alpha: 0.35)
              : colors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: unlocked ? 1.0 : 0.22,
                child: Text(achievement.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
              if (!unlocked)
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: colors.textTertiary.withValues(alpha: 0.82),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded,
                      size: 13, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: unlocked ? colors.textPrimary : colors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 9,
              color: unlocked ? colors.textSecondary : colors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EditProfileTile extends StatelessWidget {
  const _EditProfileTile({required this.profile});
  final ProfileProvider profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => _showEditDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_outlined,
                color: AppColors.primary, size: 22),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text('Editar nombre y avatar',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(profile: profile),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});
  final ProfileProvider profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late String _selectedAvatar;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _selectedAvatar = widget.profile.avatarEmoji;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.length < 2) return;

    setState(() => _isSaving = true);
    final provider = context.read<ProfileProvider>();
    await HapticFeedback.mediumImpact();

    await provider.saveProfile(
      name: name,
      loginMethod: widget.profile.loginMethod,
      avatarEmoji: _selectedAvatar,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg)),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSizes.screenPadding, AppSizes.lg,
          AppSizes.screenPadding, AppSizes.lg + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          Text('Editar perfil',
              style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: AppSizes.md),

          TextFormField(
            controller: _nameCtrl,
            maxLength: 50,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Tu nombre',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),

          const SizedBox(height: AppSizes.md),

          Text('Elige tu avatar',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.textSecondary)),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: _kAvatars.map((emoji) {
              final sel = emoji == _selectedAvatar;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedAvatar = emoji);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sel
                        ? colors.primarySurface
                        : colors.surfaceGray,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(
                      color: sel ? AppColors.primary : colors.border,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSizes.lg),

          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded),
              label: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }
}

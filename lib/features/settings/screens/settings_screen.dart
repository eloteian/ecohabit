// =============================================================================
// settings_screen.dart — Configuración de EcoHabit
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/eco_theme_colors.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../habits/providers/habit_provider.dart';
import '../providers/settings_provider.dart';

String _formatTime(int hour, int minute) {
  final h = hour.toString().padLeft(2, '0');
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: colors.background,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            children: [
              // ── Sección: Apariencia ──────────────────────────────────────
              const _SectionHeader(text: 'Apariencia'),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Modo oscuro',
                subtitle: 'Cambia el tema de la app',
                trailing: Switch(
                  value: settings.isDarkMode,
                  onChanged: (v) async {
                    HapticFeedback.selectionClick();
                    await settings.toggleDarkMode(v);
                  },
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primaryLight,
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // ── Sección: Notificaciones ─────────────────────────────────
              const _SectionHeader(text: 'Notificaciones'),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Recordatorios diarios',
                subtitle: 'Recibe una notificación para completar tus hábitos',
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: (v) async {
                    HapticFeedback.selectionClick();
                    final granted =
                        await settings.toggleNotifications(v, context);
                    if (!granted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Permiso denegado. Actívalo en ajustes del sistema.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primaryLight,
                ),
              ),
              if (settings.notificationsEnabled) ...[
                const SizedBox(height: AppSizes.xs),
                _SettingsTile(
                  icon: Icons.schedule_outlined,
                  title: 'Hora del recordatorio',
                  subtitle: _formatTime(
                      settings.reminderHour, settings.reminderMinute),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: settings.reminderTime,
                      helpText: 'HORA DEL RECORDATORIO',
                      builder: (ctx, child) => MediaQuery(
                        data: MediaQuery.of(ctx)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      ),
                    );
                    if (picked != null && context.mounted) {
                      HapticFeedback.selectionClick();
                      await settings.setReminderTime(
                          picked.hour, picked.minute);
                    }
                  },
                ),
              ],

              const SizedBox(height: AppSizes.lg),

              // ── Sección: Datos ──────────────────────────────────────────
              const _SectionHeader(text: 'Mis datos'),
              _SettingsTile(
                icon: Icons.delete_sweep_outlined,
                iconColor: AppColors.error,
                title: 'Restablecer todos los datos',
                subtitle: 'Elimina hábitos, progreso y configuración',
                onTap: () => _confirmReset(context),
              ),

              const SizedBox(height: AppSizes.lg),

              // ── Sección: App ────────────────────────────────────────────
              const _SectionHeader(text: 'Aplicación'),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Acerca de EcoHabit',
                subtitle: 'Versión, licencia y créditos',
                onTap: () => Navigator.pushNamed(context, AppRoutes.about),
              ),

              const SizedBox(height: AppSizes.xl),

              Center(
                child: Text(
                  'Todos tus datos se guardan únicamente en\neste dispositivo. No compartimos nada.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textTertiary,
                        height: 1.6,
                      ),
                ),
              ),

              const SizedBox(height: AppSizes.xl),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restablecer datos'),
        content: const Text(
          'Se eliminarán todos tus hábitos, historial de completaciones y '
          'configuración. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar todo',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final habitProvider = context.read<HabitProvider>();
      await HapticFeedback.heavyImpact();
      await habitProvider.resetAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos restablecidos correctamente')),
        );
        Navigator.pop(context);
      }
    }
  }
}

// =============================================================================
// SUBWIDGETS
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.textTertiary,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
        ),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right_rounded,
                    color: colors.textTertiary, size: 20)
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      ),
    );
  }
}

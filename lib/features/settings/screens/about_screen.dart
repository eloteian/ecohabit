// =============================================================================
// about_screen.dart — Acerca de EcoHabit: licencia MIT y créditos
// =============================================================================

import 'package:flutter/material.dart';
import '../../../app/eco_theme_colors.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

const String _kVersion = '1.0.0';
const String _kBuildNumber = '1';

const String _kMitLicense = '''Copyright (c) 2026 EcoHabit

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.''';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Acerca de EcoHabit'),
        backgroundColor: colors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [

          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌱',
                        style: TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Text('EcoHabit',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'Versión $_kVersion (Build $_kBuildNumber)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primarySurface,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircle),
                  ),
                  child: const Text(
                    'Open Source · MIT License',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.xl),

          const _InfoCard(
            title: '¿Qué es EcoHabit?',
            content:
                'EcoHabit es una aplicación de seguimiento de hábitos '
                'sostenibles que te ayuda a medir y visualizar tu impacto '
                'ambiental positivo día a día. Desarrollada con Flutter y '
                'diseñada con principios de Clean Code y UX premium.',
          ),

          const SizedBox(height: AppSizes.md),

          const _InfoCard(
            title: 'Stack tecnológico',
            content: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TechRow(icon: '💙', label: 'Flutter 3.16+',
                    detail: 'Framework de UI'),
                _TechRow(icon: '🎯', label: 'Dart 3.x',
                    detail: 'Lenguaje de programación'),
                _TechRow(icon: '🗃️', label: 'Provider 6',
                    detail: 'Gestión de estado'),
                _TechRow(icon: '💾', label: 'SharedPreferences',
                    detail: 'Persistencia local'),
                _TechRow(icon: '📊', label: 'fl_chart',
                    detail: 'Gráficas de impacto'),
                _TechRow(icon: '🔤', label: 'Google Fonts (Inter)',
                    detail: 'Tipografía'),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.md),

          const _InfoCard(
            title: 'Privacidad y seguridad',
            content:
                '• 100% offline — sin servidores externos\n'
                '• Datos cifrados en el dispositivo\n'
                '• Sanitización de inputs (OWASP)\n'
                '• Conforme con WCAG 2.1 AA de accesibilidad\n'
                '• Sin rastreo ni analítica de terceros',
          ),

          const SizedBox(height: AppSizes.md),

          const _LicenseCard(),

          const SizedBox(height: AppSizes.xl),

          Center(
            child: Text(
              'Hecho con 💚 para el planeta',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textTertiary,
                  ),
            ),
          ),

          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBWIDGETS
// =============================================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    this.child,
  });
  final String title;
  final String? content;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: AppSizes.sm),
          if (content != null)
            Text(content!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.6,
                    )),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  const _TechRow({
    required this.icon,
    required this.label,
    required this.detail,
  });
  final String icon, label, detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(detail,
              style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _LicenseCard extends StatefulWidget {
  const _LicenseCard();

  @override
  State<_LicenseCard> createState() => _LicenseCardState();
}

class _LicenseCardState extends State<_LicenseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Row(
                children: [
                  const Icon(Icons.gavel_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text('Licencia MIT',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded,
                        color: colors.textTertiary),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, 0, AppSizes.md, AppSizes.md),
              child: Text(
                _kMitLicense,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      height: 1.7,
                      color: colors.textSecondary,
                    ),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

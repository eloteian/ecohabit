// =============================================================================
// habit_form_screen.dart — Formulario para crear / editar hábitos
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/eco_theme_colors.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';

const List<String> _kEmojis = [
  '🚿',
  '🥗',
  '🚴',
  '♻️',
  '💡',
  '🌱',
  '🌿',
  '🍃',
  '🌍',
  '🌊',
  '🐾',
  '🛒',
  '🍎',
  '☀️',
  '🌬️',
  '🚶',
  '🧴',
  '🛁',
  '🔌',
  '🌻',
];

const List<String> _kDayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key, this.habitToEdit});

  final Habit? habitToEdit;

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _emoji = '🌱';
  HabitCategory _category = HabitCategory.water;
  List<bool> _weekDays = List.filled(7, true);
  bool _isSaving = false;

  double _water = 0;
  double _co2 = 0;
  double _energy = 0;
  double _waste = 0;

  bool get _isEditing => widget.habitToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final h = widget.habitToEdit!;
      _nameCtrl.text = h.name;
      _descCtrl.text = h.description;
      _emoji = h.emoji;
      _category = h.category;
      _weekDays = List<bool>.from(h.weekDays);
      _water = h.waterSavedLiters;
      _co2 = h.co2SavedKg;
      _energy = h.energySavedKwh;
      _waste = h.wasteReducedGrams;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(HabitCategory cat) {
    setState(() {
      _category = cat;
      switch (cat) {
        case HabitCategory.water:
          _water = 55;
          _co2 = 0.05;
          _energy = 0;
          _waste = 0;
        case HabitCategory.food:
          _water = 0;
          _co2 = 1.5;
          _energy = 0;
          _waste = 200;
        case HabitCategory.transport:
          _water = 0;
          _co2 = 1.2;
          _energy = 0;
          _waste = 0;
        case HabitCategory.energy:
          _water = 0;
          _co2 = 0.3;
          _energy = 1.5;
          _waste = 0;
        case HabitCategory.waste:
          _water = 0;
          _co2 = 0.5;
          _energy = 0;
          _waste = 400;
      }
    });
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_weekDays.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un día')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<HabitProvider>();
    await HapticFeedback.mediumImpact();

    final habit = Habit(
      id: _isEditing
          ? widget.habitToEdit!.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      emoji: _emoji,
      description: _descCtrl.text.trim(),
      category: _category,
      weekDays: _weekDays,
      completedDates:
          _isEditing ? widget.habitToEdit!.completedDates : const {},
      createdAt: _isEditing ? widget.habitToEdit!.createdAt : DateTime.now(),
      waterSavedLiters: _water,
      co2SavedKg: _co2,
      energySavedKwh: _energy,
      wasteReducedGrams: _waste,
    );

    if (_isEditing) {
      await provider.updateHabit(habit);
    } else {
      await provider.addHabit(habit);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar hábito' : 'Nuevo hábito'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              onPressed: _onDelete,
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          children: [
            const _SectionLabel(text: 'Ícono del hábito'),
            const SizedBox(height: AppSizes.sm),
            _EmojiPicker(
              selected: _emoji,
              onSelect: (e) => setState(() => _emoji = e),
            ),
            const SizedBox(height: AppSizes.lg),
            const _SectionLabel(text: 'Nombre del hábito *'),
            const SizedBox(height: AppSizes.sm),
            TextFormField(
              controller: _nameCtrl,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Ej: Ducha de 5 minutos',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const _SectionLabel(text: 'Descripción (opcional)'),
            const SizedBox(height: AppSizes.sm),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              maxLength: 120,
              decoration: const InputDecoration(
                hintText: 'Describe brevemente este hábito...',
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const _SectionLabel(text: 'Categoría *'),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: HabitCategory.values.map((cat) {
                final sel = cat == _category;
                return ChoiceChip(
                  label: Text('${cat.emoji} ${cat.label}'),
                  selected: sel,
                  onSelected: (_) => _applyPreset(cat),
                  selectedColor: context.colors.categoryBackground(cat),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: sel ? cat.color : colors.textSecondary,
                  ),
                  side: BorderSide(
                    color: sel ? cat.color : colors.border,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.lg),
            const _SectionLabel(text: 'Días programados *'),
            const SizedBox(height: AppSizes.sm),
            _WeekDaySelector(
              weekDays: _weekDays,
              onToggle: (i) => setState(() => _weekDays[i] = !_weekDays[i]),
            ),
            const SizedBox(height: AppSizes.lg),
            const _SectionLabel(text: 'Impacto ambiental por completación'),
            const SizedBox(height: AppSizes.xs),
            Text(
                'Valores pre-rellenados según la categoría. Puedes ajustarlos.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSizes.md),
            _ImpactField(
              label: 'Agua ahorrada (litros)',
              icon: '💧',
              value: _water,
              onChanged: (v) => setState(() => _water = v),
            ),
            const SizedBox(height: AppSizes.sm),
            _ImpactField(
              label: 'CO₂ reducido (kg)',
              icon: '🌿',
              value: _co2,
              onChanged: (v) => setState(() => _co2 = v),
            ),
            const SizedBox(height: AppSizes.sm),
            _ImpactField(
              label: 'Energía ahorrada (kWh)',
              icon: '⚡',
              value: _energy,
              onChanged: (v) => setState(() => _energy = v),
            ),
            const SizedBox(height: AppSizes.sm),
            _ImpactField(
              label: 'Residuos reducidos (gramos)',
              icon: '♻️',
              value: _waste,
              onChanged: (v) => setState(() => _waste = v),
            ),
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _onSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded),
                label: Text(_isEditing ? 'Guardar cambios' : 'Crear hábito'),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Seguro que quieres eliminar "${_nameCtrl.text}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<HabitProvider>().deleteHabit(widget.habitToEdit!.id);
      if (mounted) Navigator.pop(context);
    }
  }
}

// =============================================================================
// SUBWIDGETS
// =============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: context.colors.textSecondary,
              letterSpacing: 0.5,
            ),
      );
}

class _EmojiPicker extends StatelessWidget {
  const _EmojiPicker({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: _kEmojis.map((e) {
        final isSel = e == selected;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(e);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSel ? colors.primarySurface : colors.surfaceGray,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              border: Border.all(
                color: isSel ? AppColors.primary : colors.border,
                width: isSel ? 2 : 1,
              ),
            ),
            child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekDaySelector extends StatelessWidget {
  const _WeekDaySelector({required this.weekDays, required this.onToggle});
  final List<bool> weekDays;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = weekDays[i];
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : colors.surfaceGray,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.primary : colors.border,
              ),
            ),
            child: Center(
              child: Text(
                _kDayLabels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : colors.textTertiary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ImpactField extends StatelessWidget {
  const _ImpactField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label, icon;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value == 0 ? '' : value.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
      decoration: InputDecoration(
        labelText: label,
        prefixText: '$icon  ',
        suffixIcon: Icon(Icons.info_outline_rounded,
            size: 16, color: context.colors.textTertiary),
      ),
    );
  }
}

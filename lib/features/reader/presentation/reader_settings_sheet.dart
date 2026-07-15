import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/di/injection.dart';
import '../../../core/storage/local_storage.dart';

class ReaderSettingsSheet extends StatefulWidget {
  final VoidCallback onChanged;

  const ReaderSettingsSheet({super.key, required this.onChanged});

  @override
  State<ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<ReaderSettingsSheet> {
  final _storage = getIt<LocalStorage>();

  late double _fontScale;
  late double _lineHeight;
  late double _paragraphSpacing;
  late String _fontFamily;
  late String _alignment;
  late String _margin;

  @override
  void initState() {
    super.initState();
    _fontScale = _storage.getReaderFontScale();
    _lineHeight = _storage.getReaderLineHeight();
    _paragraphSpacing = _storage.getReaderParagraphSpacing();
    _fontFamily = _storage.getReaderFontFamily();
    _alignment = _storage.getReaderAlignment();
    _margin = _storage.getReaderMargin();
  }

  void _save() {
    _storage.setReaderFontScale(_fontScale);
    _storage.setReaderLineHeight(_lineHeight);
    _storage.setReaderParagraphSpacing(_paragraphSpacing);
    _storage.setReaderFontFamily(_fontFamily);
    _storage.setReaderAlignment(_alignment);
    _storage.setReaderMargin(_margin);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Reader Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFontFamilySelector(),
                const SizedBox(height: 24),
                _buildSlider('Font Size', _fontScale, 0.7, 1.6, '${(_fontScale * 100).round()}%',
                    (v) => _fontScale = v),
                const SizedBox(height: 20),
                _buildSlider('Line Height', _lineHeight, 1.2, 2.4, _lineHeight.toStringAsFixed(1),
                    (v) => _lineHeight = v),
                const SizedBox(height: 20),
                _buildSlider('Paragraph Spacing', _paragraphSpacing, 4, 32,
                    '${_paragraphSpacing.round()}px', (v) => _paragraphSpacing = v),
                const SizedBox(height: 20),
                _buildAlignmentSelector(),
                const SizedBox(height: 20),
                _buildMarginSelector(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _save();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      ),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontFamilySelector() {
    const fonts = ['Georgia', 'Merriweather', 'Lora', 'EB Garamond', 'System'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Font',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: fonts.map((f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f, style: TextStyle(fontSize: 13, fontFamily: f == 'System' ? null : f)),
                selected: _fontFamily == f,
                onSelected: (_) => setState(() => _fontFamily = f),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundColor: AppColors.background,
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: _fontFamily == f ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, String display, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            Text(display,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: 3,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) => setState(() => onChanged(v)),
          ),
        ),
      ],
    );
  }

  Widget _buildAlignmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alignment',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            _alignChip(Icons.format_align_left, 'left', 'Left'),
            const SizedBox(width: 8),
            _alignChip(Icons.format_align_justify, 'justify', 'Justify'),
            const SizedBox(width: 8),
            _alignChip(Icons.format_align_center, 'center', 'Center'),
          ],
        ),
      ],
    );
  }

  Widget _alignChip(IconData icon, String value, String label) {
    final selected = _alignment == value;
    return Expanded(
      child: ChoiceChip(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
        selected: selected,
        onSelected: (_) => setState(() => _alignment = value),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        backgroundColor: AppColors.background,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildMarginSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Margins',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            _marginChip('narrow', 'Narrow'),
            const SizedBox(width: 8),
            _marginChip('normal', 'Normal'),
            const SizedBox(width: 8),
            _marginChip('wide', 'Wide'),
          ],
        ),
      ],
    );
  }

  Widget _marginChip(String value, String label) {
    final selected = _margin == value;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => setState(() => _margin = value),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        backgroundColor: AppColors.background,
        side: BorderSide.none,
      ),
    );
  }
}

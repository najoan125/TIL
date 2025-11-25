import 'package:flutter/material.dart';

class SettingsPanel extends StatelessWidget {
  final int width;
  final double contrast;
  final double brightness;
  final String charSet;
  final bool invert;
  final Function(int) onWidthChanged;
  final Function(double) onContrastChanged;
  final Function(double) onBrightnessChanged;
  final Function(String) onCharSetChanged;
  final Function(bool) onInvertChanged;

  const SettingsPanel({
    super.key,
    required this.width,
    required this.contrast,
    required this.brightness,
    required this.charSet,
    required this.invert,
    required this.onWidthChanged,
    required this.onContrastChanged,
    required this.onBrightnessChanged,
    required this.onCharSetChanged,
    required this.onInvertChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildSlider(
            context,
            'Resolution (Width)',
            width.toDouble(),
            50,
            300,
            (val) => onWidthChanged(val.toInt()),
            label: width.toString(),
          ),
          _buildSlider(
            context,
            'Contrast',
            contrast,
            0.0,
            3.0,
            onContrastChanged,
          ),
          _buildSlider(
            context,
            'Brightness',
            brightness,
            -128.0,
            128.0,
            onBrightnessChanged,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Character Set'),
              DropdownButton<String>(
                value: charSet,
                items: ['Simple', 'Complex', 'Blocks']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) onCharSetChanged(val);
                },
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Invert Colors'),
            value: invert,
            onChanged: onInvertChanged,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String title,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    String? label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${label ?? value.toStringAsFixed(1)}'),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 공 크기 설정
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '공 크기',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: settings.ballRadius,
                              min: 20,
                              max: 50,
                              divisions: 30,
                              label: settings.ballRadius.toStringAsFixed(1),
                              onChanged: (value) {
                                settings.setBallRadius(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            settings.ballRadius.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 미리보기
                      Center(
                        child: CustomPaint(
                          painter: _BallPreviewPainter(radius: settings.ballRadius),
                          size: const Size(120, 120),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '무게: ${settings.ballMass.toStringAsFixed(2)}x',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 테마 설정
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '테마',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          _buildThemeOption(
                            context,
                            'Light',
                            ThemeMode.light,
                            settings,
                          ),
                          _buildThemeOption(
                            context,
                            'Dark',
                            ThemeMode.dark,
                            settings,
                          ),
                          _buildThemeOption(
                            context,
                            'System',
                            ThemeMode.system,
                            settings,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    ThemeMode mode,
    SettingsProvider settings,
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(label),
      value: mode,
      groupValue: settings.themeMode,
      onChanged: (value) {
        if (value != null) {
          settings.setThemeMode(value);
        }
      },
    );
  }
}

class _BallPreviewPainter extends CustomPainter {
  final double radius;

  _BallPreviewPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, paint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final highlightOffset = Offset(
      center.dx - radius * 0.3,
      center.dy - radius * 0.3,
    );
    canvas.drawCircle(highlightOffset, radius * 0.3, highlightPaint);
  }

  @override
  bool shouldRepaint(_BallPreviewPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}

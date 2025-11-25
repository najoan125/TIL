import 'package:flutter/material.dart';

class WelcomeDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const WelcomeDialog({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '카운터 앱에 오신 것을 환영합니다! 👋',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.touch_app,
              title: '간단한 조작',
              description: '오른쪽 하단의 버튼을 클릭하여 숫자를 증가시킵니다.',
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.storage,
              title: '자동 저장',
              description: '증가된 값은 자동으로 저장되므로 앱을 종료해도 데이터가 유지됩니다.',
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.refresh,
              title: '지속적 동작',
              description: '앱을 다시 실행하면 마지막으로 저장된 숫자부터 다시 시작합니다.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '이 메시지는 처음 실행할 때만 나타납니다.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onDismiss,
            icon: const Icon(Icons.check),
            label: const Text('시작하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

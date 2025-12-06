import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ball.dart';
import '../providers/settings_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Ball> balls;
  DateTime? lastUpdateTime;
  Size screenSize = Size.zero;
  static const int maxBalls = 10;

  @override
  void initState() {
    super.initState();
    balls = [];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_updatePhysics);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    final now = DateTime.now();
    if (lastUpdateTime != null && screenSize != Size.zero) {
      final dt = now.difference(lastUpdateTime!).inMicroseconds / 1000000.0;

      setState(() {
        for (var ball in balls) {
          ball.updatePhysics(dt, screenSize);
        }
        // 공끼리 충돌 처리
        for (int i = 0; i < balls.length; i++) {
          for (int j = i + 1; j < balls.length; j++) {
            Ball.resolveCollision(balls[i], balls[j]);
          }
        }
      });
    }
    lastUpdateTime = now;
  }

  void _addBall(Offset position) {
    if (balls.length >= maxBalls) return;

    final settings = context.read<SettingsProvider>();
    final newBall = Ball(
      position: position,
      radius: settings.ballRadius,
    );
    newBall.updateMass();

    setState(() {
      balls.add(newBall);
    });
  }

  void _onTapDown(TapDownDetails details) {
    final tapPosition = details.localPosition;

    // 기존 공을 클릭했는지 확인
    for (var ball in balls) {
      if (ball.containsPoint(tapPosition)) {
        return;
      }
    }

    // 빈 공간을 클릭했으면 새 공 추가
    _addBall(tapPosition);
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;

    for (var ball in balls) {
      if (ball.containsPoint(localPosition)) {
        setState(() {
          ball.isDragging = true;
          ball.velocity = Offset.zero;
        });
        break;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    for (var ball in balls) {
      if (ball.isDragging) {
        setState(() {
          ball.position = details.localPosition;
        });
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    for (var ball in balls) {
      if (ball.isDragging) {
        setState(() {
          ball.velocity = Offset(
            details.velocity.pixelsPerSecond.dx,
            details.velocity.pixelsPerSecond.dy,
          );
          ball.isDragging = false;
        });
      }
    }
  }

  void _resetGame() {
    setState(() {
      balls.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ball Physics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          screenSize = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            onTapDown: _onTapDown,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            behavior: HitTestBehavior.opaque,
            child: SizedBox.expand(
              child: CustomPaint(
                painter: GamePainter(balls: balls),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<Ball> balls;

  GamePainter({required this.balls});

  @override
  void paint(Canvas canvas, Size size) {
    // 배경
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.grey.shade100,
    );

    for (var ball in balls) {
      // 공 그리기
      final paint = Paint()
        ..color = ball.isDragging ? Colors.red : Colors.blue
        ..style = PaintingStyle.fill;

      canvas.drawCircle(ball.position, ball.radius, paint);

      // 하이라이트
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      final highlightOffset = Offset(
        ball.position.dx - ball.radius * 0.3,
        ball.position.dy - ball.radius * 0.3,
      );
      canvas.drawCircle(highlightOffset, ball.radius * 0.3, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    if (oldDelegate.balls.length != balls.length) return true;
    for (int i = 0; i < balls.length; i++) {
      if (oldDelegate.balls[i].position != balls[i].position ||
          oldDelegate.balls[i].isDragging != balls[i].isDragging) {
        return true;
      }
    }
    return false;
  }
}

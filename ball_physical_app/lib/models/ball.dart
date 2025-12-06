import 'dart:math';
import 'package:flutter/material.dart';

const double gravity = 980.0;
const double restitution = 0.8;
const double friction = 0.99;

class Ball {
  late Offset position;
  late Offset velocity;
  late double radius;
  late double mass;
  bool isDragging = false;
  final String id;

  Ball({
    required this.position,
    required this.radius,
    this.velocity = const Offset(0, 0),
    this.isDragging = false,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  void updateMass() {
    mass = (radius / 30.0) * (radius / 30.0);
  }

  void updatePhysics(double dt, Size screenSize) {
    if (isDragging) return;
    if (screenSize.width == 0 || screenSize.height == 0) return;

    // 중력 적용 (질량에 따라 조절)
    velocity = Offset(
      velocity.dx * friction,
      velocity.dy + gravity * mass * dt,
    );

    // 위치 업데이트
    position = Offset(
      position.dx + velocity.dx * dt,
      position.dy + velocity.dy * dt,
    );

    // 벽 충돌 처리
    checkWallCollision(screenSize);
  }

  void checkWallCollision(Size screenSize) {
    // 좌측 벽
    if (position.dx - radius < 0) {
      position = Offset(radius, position.dy);
      velocity = Offset(-velocity.dx * restitution, velocity.dy);
    }

    // 우측 벽
    if (position.dx + radius > screenSize.width) {
      position = Offset(screenSize.width - radius, position.dy);
      velocity = Offset(-velocity.dx * restitution, velocity.dy);
    }

    // 상단 벽
    if (position.dy - radius < 0) {
      position = Offset(position.dx, radius);
      velocity = Offset(velocity.dx, -velocity.dy * restitution);
    }

    // 하단 벽
    if (position.dy + radius > screenSize.height) {
      position = Offset(position.dx, screenSize.height - radius);
      velocity = Offset(velocity.dx, -velocity.dy * restitution);

      // 바닥에서 속도가 작으면 멈춤
      if (velocity.dy.abs() < 50) {
        velocity = Offset(velocity.dx, 0);
      }
    }
  }

  bool containsPoint(Offset point) {
    final distance = (point - position).distance;
    return distance <= radius;
  }

  // 2D 탄성 충돌 처리
  static void resolveCollision(Ball ball1, Ball ball2) {
    final dx = ball2.position.dx - ball1.position.dx;
    final dy = ball2.position.dy - ball1.position.dy;
    final distance = sqrt(dx * dx + dy * dy);

    // 충돌 여부 확인
    if (distance > ball1.radius + ball2.radius) return;

    // 충돌 시 겹침 해결
    if (distance == 0) return;

    final overlap = ball1.radius + ball2.radius - distance;
    final nx = dx / distance;
    final ny = dy / distance;

    ball1.position = Offset(
      ball1.position.dx - nx * overlap / 2,
      ball1.position.dy - ny * overlap / 2,
    );
    ball2.position = Offset(
      ball2.position.dx + nx * overlap / 2,
      ball2.position.dy + ny * overlap / 2,
    );

    // 속도 계산 (운동량 보존)
    final v1x = ball1.velocity.dx;
    final v1y = ball1.velocity.dy;
    final v2x = ball2.velocity.dx;
    final v2y = ball2.velocity.dy;

    final m1 = ball1.mass;
    final m2 = ball2.mass;

    // 상대 속도
    final dvx = v2x - v1x;
    final dvy = v2y - v1y;

    // 충돌 법선 방향
    final dotProduct = dvx * nx + dvy * ny;

    // 분리 중이면 처리 안 함
    if (dotProduct >= 0) return;

    // 임펄스 계산
    final impulse = -(1 + restitution) * dotProduct / (1 / m1 + 1 / m2);
    final impulseX = impulse * nx;
    final impulseY = impulse * ny;

    // 속도 업데이트
    ball1.velocity = Offset(
      v1x - impulseX / m1,
      v1y - impulseY / m1,
    );
    ball2.velocity = Offset(
      v2x + impulseX / m2,
      v2y + impulseY / m2,
    );
  }
}

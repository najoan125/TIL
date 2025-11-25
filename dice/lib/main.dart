import 'dart:math';
import 'package:flutter/material.dart';
import 'dice_3d.dart';

void main() {
  runApp(const DiceApp());
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const DicePage(),
    );
  }
}

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> with TickerProviderStateMixin {
  // Target values for the dice
  int leftDiceTarget = 1;
  int rightDiceTarget = 1;

  // Animation controllers
  late AnimationController _controller;

  // Animation state
  double _xRotLeftStart = 0;
  double _yRotLeftStart = 0;
  double _zRotLeftStart = 0;
  double _xRotLeftEnd = 0;
  double _yRotLeftEnd = 0;
  double _zRotLeftEnd = 0;

  double _xRotRightStart = 0;
  double _yRotRightStart = 0;
  double _zRotRightStart = 0;
  double _xRotRightEnd = 0;
  double _yRotRightEnd = 0;
  double _zRotRightEnd = 0;

  double _height = 0; // For the throw arc
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        // Parabolic arc for height
        // y = -4x(x-1) * height_scale
        _height = -200 * _controller.value * (_controller.value - 1);

        // Bounce effect at the end
        if (_controller.value > 0.8) {
          _scale = 1.0 + sin((_controller.value - 0.8) * pi * 5) * 0.1;
        } else {
          _scale = 1.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void rollDice() {
    setState(() {
      // 1. Determine targets
      leftDiceTarget = Random().nextInt(6) + 1;
      rightDiceTarget = Random().nextInt(6) + 1;

      // 2. Set start rotation to current end rotation (continuity)
      _xRotLeftStart = _xRotLeftEnd;
      _yRotLeftStart = _yRotLeftEnd;
      _zRotLeftStart = _zRotLeftEnd;

      _xRotRightStart = _xRotRightEnd;
      _yRotRightStart = _yRotRightEnd;
      _zRotRightStart = _zRotRightEnd;

      // 3. Calculate target rotation for the face
      final leftTargetRot = _getRotationForFace(leftDiceTarget);
      final rightTargetRot = _getRotationForFace(rightDiceTarget);

      // 4. Add random spins (multiples of 2pi)
      // Ensure we spin at least 2 times
      final int spins = 2 + Random().nextInt(2);

      _xRotLeftEnd = leftTargetRot.x + (spins * 2 * pi);
      _yRotLeftEnd = leftTargetRot.y + (spins * 2 * pi);
      _zRotLeftEnd = leftTargetRot.z + (spins * 2 * pi); // Add some Z spin too

      _xRotRightEnd = rightTargetRot.x + (spins * 2 * pi);
      _yRotRightEnd = rightTargetRot.y + (spins * 2 * pi);
      _zRotRightEnd = rightTargetRot.z + (spins * 2 * pi);
    });

    _controller.forward(from: 0.0);
  }

  // Returns the (x, y, z) rotation needed to show the given face
  // Standard Dice Layout (from Dice3D):
  // 1: Front (0,0,0)
  // 6: Back (0, pi, 0)
  // 2: Top (-pi/2, 0, 0) -> To show Top, we need to rotate X by pi/2?
  //    Dice3D defines Top as translated -Y and rotated X pi/2.
  //    To bring Top to Front, we need to rotate the whole cube by X = pi/2.
  // 5: Bottom (pi/2, 0, 0) -> Rotate X = -pi/2
  // 3: Left (0, pi/2, 0) -> Rotate Y = pi/2
  // 4: Right (0, -pi/2, 0) -> Rotate Y = -pi/2

  // Wait, let's verify the rotations.
  // If Top face is at (0, -size/2, 0) rotated X pi/2.
  // To see it, we look from +Z.
  // We need to rotate the cube so that (0, -size/2, 0) moves to (0, 0, -size/2) [Front]?
  // Actually, we just need the face normal to point towards +Z.
  // Top face normal points UP (-Y).
  // To make it point +Z, we rotate around X axis by +90 deg (pi/2).
  // Let's test:
  // 1: Front. Normal -Z (Wait, Dice3D front is translated -Z/2. Normal points -Z? No, usually Front is +Z).
  // In Dice3D: Front is translate(0,0,-size/2). That's "into" the screen.
  // So we are looking at the BACK of the front face?
  // Let's assume standard camera looks down -Z.
  // If Front is at -Z/2, it's visible.
  // If Back is at +Z/2 rotated Y pi. It's facing +Z.
  // This coordinate system is a bit tricky.
  // Let's stick to the previous implementation's logic which seemed to work, but refine it.

  // Previous logic:
  // case 1: x = 0; y = 0;
  // case 2: x = -pi / 2; y = 0;
  // case 3: x = 0; y = pi / 2;
  // case 4: x = 0; y = -pi / 2;
  // case 5: x = pi / 2; y = 0;
  // case 6: x = 0; y = pi;

  // Let's use this as a base.
  ({double x, double y, double z}) _getRotationForFace(int face) {
    switch (face) {
      case 1:
        return (x: 0.0, y: 0.0, z: 0.0);
      case 2:
        return (x: -pi / 2, y: 0.0, z: 0.0);
      case 3:
        return (x: 0.0, y: pi / 2, z: 0.0);
      case 4:
        return (x: 0.0, y: -pi / 2, z: 0.0);
      case 5:
        return (x: pi / 2, y: 0.0, z: 0.0);
      case 6:
        return (x: 0.0, y: pi, z: 0.0);
      default:
        return (x: 0.0, y: 0.0, z: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Interpolate rotation based on controller value
    // Use a curve for smooth settling
    final double t = Curves.easeOutCubic.transform(_controller.value);

    final double curXLeft = _lerp(_xRotLeftStart, _xRotLeftEnd, t);
    final double curYLeft = _lerp(_yRotLeftStart, _yRotLeftEnd, t);
    final double curZLeft = _lerp(_zRotLeftStart, _zRotLeftEnd, t);

    final double curXRight = _lerp(_xRotRightStart, _xRotRightEnd, t);
    final double curYRight = _lerp(_yRotRightStart, _yRotRightEnd, t);
    final double curZRight = _lerp(_zRotRightStart, _zRotRightEnd, t);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF000000)],
            radius: 1.5,
            center: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text(
                  'Dicee 3D',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.5,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDiceWithShadow(curXLeft, curYLeft, curZLeft),
                            _buildDiceWithShadow(
                              curXRight,
                              curYRight,
                              curZRight,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                      ElevatedButton(
                        onPressed: _controller.isAnimating ? null : rollDice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          shadowColor: Colors.white.withOpacity(0.3),
                        ),
                        child: const Text(
                          'ROLL',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  Widget _buildDiceWithShadow(double x, double y, double z) {
    // Calculate shadow properties based on height
    // Height is negative (upwards), so we invert it for shadow logic
    double heightFactor =
        -_height / 200.0; // 0.0 at ground, 1.0 at peak (approx)
    double shadowScale = 1.0 - (heightFactor * 0.5); // Smaller when high
    double shadowOpacity = 0.5 - (heightFactor * 0.3); // Fainter when high

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, -_height),
          child: Transform.scale(
            scale: _scale,
            child: Dice3D(size: 100, xRot: x, yRot: y, zRot: z),
          ),
        ),
        const SizedBox(height: 20), // Spacing between dice and shadow
        Transform.scale(
          scale: shadowScale,
          child: Container(
            width: 100,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    shadowOpacity.clamp(0.0, 1.0),
                  ),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class Dice3D extends StatelessWidget {
  final double size;
  final double xRot;
  final double yRot;
  final double zRot;

  const Dice3D({
    super.key,
    required this.size,
    required this.xRot,
    required this.yRot,
    required this.zRot,
  });

  @override
  Widget build(BuildContext context) {
    // Define the 6 faces with their initial transforms (assuming 0 rotation)
    final List<_DiceFaceDef> faces = [
      _DiceFaceDef(1, Matrix4.identity()..translate(0.0, 0.0, -size / 2)),
      _DiceFaceDef(
        6,
        Matrix4.identity()
          ..translate(0.0, 0.0, size / 2)
          ..rotateY(pi),
      ),
      _DiceFaceDef(
        2,
        Matrix4.identity()
          ..translate(0.0, -size / 2, 0.0)
          ..rotateX(pi / 2),
      ),
      _DiceFaceDef(
        5,
        Matrix4.identity()
          ..translate(0.0, size / 2, 0.0)
          ..rotateX(-pi / 2),
      ),
      _DiceFaceDef(
        3,
        Matrix4.identity()
          ..translate(-size / 2, 0.0, 0.0)
          ..rotateY(-pi / 2),
      ),
      _DiceFaceDef(
        4,
        Matrix4.identity()
          ..translate(size / 2, 0.0, 0.0)
          ..rotateY(pi / 2),
      ),
    ];

    // Sort faces by Z-depth after applying the current rotation
    faces.sort((a, b) {
      final double zA = _getTransformedZ(a.transform);
      final double zB = _getTransformedZ(b.transform);
      // Draw furthest first (lowest Z? In Flutter stack, first is bottom)
      // We want furthest away to be at the bottom of the stack.
      // In camera view, negative Z is usually "into" the screen, positive is "out".
      // But let's check the projection.
      // Actually, we want the one with the largest positive Z (closest to camera) to be last in the list.
      // Wait, standard OpenGL: Camera at 0, looking down -Z.
      // Flutter Matrix4:
      // Let's just use a simple heuristic: transform the center point (0,0,0) of the face.
      // The one with the largest Z value (closest to viewer) should be drawn LAST.
      return zA.compareTo(zB);
    });

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: faces
            .map((face) => _buildFace(face.number, face.transform))
            .toList(),
      ),
    );
  }

  double _getTransformedZ(Matrix4 faceTransform) {
    // 1. Create the rotation matrix for the whole cube
    final Matrix4 rotationMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateX(xRot)
      ..rotateY(yRot)
      ..rotateZ(zRot);

    // 2. Combine with the face's local transform
    final Matrix4 combined = rotationMatrix * faceTransform;

    // 3. Transform the center point (0,0,0)
    final vector.Vector3 center = combined.perspectiveTransform(
      vector.Vector3(0, 0, 0),
    );

    return center.z;
  }

  Widget _buildFace(int number, Matrix4 faceLocalTransform) {
    // We apply the global rotation AND the face local transform here
    // But wait, if we apply global rotation here, we are doing it per face.
    // That's correct.

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateX(xRot)
        ..rotateY(yRot)
        ..rotateZ(zRot)
        ..multiply(faceLocalTransform),
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: size * 0.02),
          borderRadius: BorderRadius.circular(size * 0.15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: size * 0.05,
              spreadRadius: 0,
            ),
          ],
        ),
        child: _buildPips(number),
      ),
    );
  }

  Widget _buildPips(int number) {
    final double pipSize = size * 0.2;
    final double padding = size * 0.15;

    // Helper to create a pip
    Widget pip() => Container(
      width: pipSize,
      height: pipSize,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );

    // Logic to place pips based on number
    // It's easier to just return specific layouts
    switch (number) {
      case 1:
        return Center(child: pip());
      case 2:
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Stack(
            children: [
              Align(alignment: Alignment.topRight, child: pip()),
              Align(alignment: Alignment.bottomLeft, child: pip()),
            ],
          ),
        );
      case 3:
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Stack(
            children: [
              Align(alignment: Alignment.topRight, child: pip()),
              Align(alignment: Alignment.center, child: pip()),
              Align(alignment: Alignment.bottomLeft, child: pip()),
            ],
          ),
        );
      case 4:
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()],
              ),
            ],
          ),
        );
      case 5:
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Stack(
            children: [
              Align(alignment: Alignment.topLeft, child: pip()),
              Align(alignment: Alignment.topRight, child: pip()),
              Align(alignment: Alignment.center, child: pip()),
              Align(alignment: Alignment.bottomLeft, child: pip()),
              Align(alignment: Alignment.bottomRight, child: pip()),
            ],
          ),
        );
      case 6:
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()],
              ),
            ],
          ),
        );
      default:
        return Center(child: pip());
    }
  }
}

class _DiceFaceDef {
  final int number;
  final Matrix4 transform;

  _DiceFaceDef(this.number, this.transform);
}

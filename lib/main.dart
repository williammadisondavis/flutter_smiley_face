// In-Class Activity 06 — Drawing with Flutter
// Student: Will Davis
// Date: September 30, 2026

import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const SmileyApp());
}

// The three different face designs used in the gallery.
enum FaceType { classic, sleepy, surprised }

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Mood goes from 0.0 for sad to 1.0 for very happy.
  double mood = 0.8;

  // Start with the normal classic smiley.
  FaceType faceType = FaceType.classic;

  // Long-press can temporarily give the face a random color.
  Color? randomFaceColor;

  final math.Random _random = math.Random();

  // Gives the face a color based on its mood.
  Color get faceColor {
    // A long press can override the normal mood color.
    if (randomFaceColor != null) {
      return randomFaceColor!;
    }

    if (mood < 0.35) {
      return Colors.lightBlue.shade300;
    } else if (mood <= 0.70) {
      return Colors.yellow.shade600;
    } else {
      return Colors.orange.shade400;
    }
  }

  // Returns a readable name for the selected face.
  String get faceName {
    switch (faceType) {
      case FaceType.classic:
        return 'Classic';
      case FaceType.sleepy:
        return 'Sleepy';
      case FaceType.surprised:
        return 'Surprised';
    }
  }

  // Removes the previous SnackBar before showing a new one.
  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  // Tapping the face cycles through all three designs.
  void _cycleFace() {
    setState(() {
      final nextIndex = (faceType.index + 1) % FaceType.values.length;
      faceType = FaceType.values[nextIndex];

      // Go back to normal mood-based color.
      randomFaceColor = null;
    });

    _showMessage('Changed face to $faceName');
  }

  // Long-press randomizes the mood, face type, and face color.
  void _randomizeFace() {
    setState(() {
      mood = _random.nextDouble();

      faceType = FaceType.values[_random.nextInt(FaceType.values.length)];

      randomFaceColor =
          Colors.primaries[_random.nextInt(Colors.primaries.length)];
    });

    _showMessage('Random face created!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: Column(
        children: [
          // Expanded lets the drawing resize when the phone rotates.
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use the smaller available dimension so the face
                  // stays completely visible in portrait and landscape.
                  final drawingSize = math.min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );

                  return GestureDetector(
                    onTap: _cycleFace,
                    onLongPress: _randomizeFace,
                    child: CustomPaint(
                      size: Size.square(drawingSize),
                      painter: SmileyPainter(
                        mood: mood,
                        faceType: faceType,
                        faceColor: faceColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Directly choose one of the three faces.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Face: '),
                    const SizedBox(width: 8),
                    DropdownButton<FaceType>(
                      value: faceType,
                      items: FaceType.values.map((type) {
                        String name;

                        switch (type) {
                          case FaceType.classic:
                            name = 'Classic';
                            break;
                          case FaceType.sleepy:
                            name = 'Sleepy';
                            break;
                          case FaceType.surprised:
                            name = 'Surprised';
                            break;
                        }

                        return DropdownMenuItem(value: type, child: Text(name));
                      }).toList(),
                      onChanged: (FaceType? newType) {
                        if (newType == null) {
                          return;
                        }

                        setState(() {
                          faceType = newType;
                          randomFaceColor = null;
                        });
                      },
                    ),
                  ],
                ),

                Text('Mood: ${mood.toStringAsFixed(2)}'),

                Slider(
                  value: mood,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (double value) {
                    setState(() {
                      mood = value;

                      // Moving the slider returns to mood-based color.
                      randomFaceColor = null;
                    });
                  },
                ),

                const Text(
                  'Tap face to change design • Long press to randomize',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceType,
    required this.faceColor,
  });

  final double mood;
  final FaceType faceType;
  final Color faceColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Center of the available drawing area.
    final center = Offset(size.width / 2, size.height / 2);

    // shortestSide keeps the face inside both portrait
    // and landscape layouts.
    final radius = size.shortestSide * 0.40;

    // ---------- FACE ----------

    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, facePaint);

    // Face border.
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035;

    canvas.drawCircle(center, radius, borderPaint);

    // ---------- EYE POSITIONS ----------

    final eyeY = center.dy - radius * 0.22;
    final eyeDistance = radius * 0.35;

    final leftEye = Offset(center.dx - eyeDistance, eyeY);

    final rightEye = Offset(center.dx + eyeDistance, eyeY);

    final eyePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = radius * 0.055
      ..strokeCap = StrokeCap.round;

    // ---------- EYES ----------

    if (faceType == FaceType.sleepy) {
      // Sleepy face uses lines for closed eyes.
      canvas.drawLine(
        Offset(leftEye.dx - radius * 0.10, leftEye.dy),
        Offset(leftEye.dx + radius * 0.10, leftEye.dy),
        eyePaint,
      );

      canvas.drawLine(
        Offset(rightEye.dx - radius * 0.10, rightEye.dy),
        Offset(rightEye.dx + radius * 0.10, rightEye.dy),
        eyePaint,
      );
    } else {
      // Surprised eyes are slightly larger.
      final eyeRadius = faceType == FaceType.surprised
          ? radius * 0.11
          : radius * 0.075;

      canvas.drawCircle(leftEye, eyeRadius, eyePaint);

      canvas.drawCircle(rightEye, eyeRadius, eyePaint);
    }

    // ---------- MOUTH ----------

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.045
      ..strokeCap = StrokeCap.round;

    // Surprised face gets a round open mouth.
    if (faceType == FaceType.surprised) {
      final mouthCenter = Offset(center.dx, center.dy + radius * 0.30);

      canvas.drawCircle(
        mouthCenter,
        radius * (0.13 + mood * 0.07),
        Paint()..color = Colors.black87,
      );

      return;
    }

    // The mouth is positioned and sized relative to radius,
    // not fixed screen pixels.
    final mouthRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius * 0.18),
      width: radius * 1.05,
      height: radius * (0.40 + mood * 0.50),
    );

    if (faceType == FaceType.sleepy) {
      // Small soft smile.
      canvas.drawArc(
        mouthRect,
        0.25 * math.pi,
        0.50 * math.pi,
        false,
        mouthPaint,
      );

      return;
    }

    // Classic face expression changes with the mood slider.
    if (mood < 0.35) {
      // Frown.
      final frownRect = mouthRect.translate(0, radius * 0.22);

      canvas.drawArc(
        frownRect,
        1.15 * math.pi,
        0.70 * math.pi,
        false,
        mouthPaint,
      );
    } else if (mood <= 0.70) {
      // Smaller / more neutral smile.
      canvas.drawArc(
        mouthRect,
        0.20 * math.pi,
        0.60 * math.pi,
        false,
        mouthPaint,
      );
    } else {
      // Large happy smile.
      canvas.drawArc(
        mouthRect,
        0.15 * math.pi,
        0.70 * math.pi,
        false,
        mouthPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    // Only repaint when something that changes the drawing changed.
    return oldDelegate.mood != mood ||
        oldDelegate.faceType != faceType ||
        oldDelegate.faceColor != faceColor;
  }
}

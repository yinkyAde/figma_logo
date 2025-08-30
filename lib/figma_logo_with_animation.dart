import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Color(0xFF101013),
      body: SafeArea(
        child: Center(child: AnimatedFigmaLogo(size: 260)),
      ),
    ),
  ));
}

class AnimatedFigmaLogo extends StatefulWidget {
  final double size;
  const AnimatedFigmaLogo({super.key, this.size = 240});

  @override
  State<AnimatedFigmaLogo> createState() => _AnimatedFigmaLogoState();
}

class _AnimatedFigmaLogoState extends State<AnimatedFigmaLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // Animations
  late final Animation<double> _spin;             // Row 1 (top pill)
  late final Animation<double> _row2LeftOpacity;  // Row 2 left (half-pill)
  late final Animation<double> _row2RightOpacity; // Row 2 right (circle)
  late final Animation<double> _row3Opacity;      // Row 3 (green)

  @override
  void initState() {
    super.initState();

    // Slower pacing: 14s per cycle, loops forever.
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 14000))
      ..repeat();

    // Row1 spins EXACTLY 3 full turns over the first 8s (0.0–~0.5714 of cycle)
    _spin = Tween<double>(begin: 0, end: 2 * math.pi * 3).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(
          0.0,
          0.5714286, // 800 / 1400 of the timeline = 8s of a 14s cycle
          curve: Curves.easeInOutCubic, // buttery acceleration/deceleration
        ),
      ),
    );

    const ease = Curves.easeInOutCubic;

    // ===== TIMELINE (14s = 1400 weight units) =====
    // 0–800    spin only (8.0s)
    // 800–820  pause (0.2s)
    // 820–880  Row2 Left fade in (0.6s)
    // 880–900  short rest (0.2s)
    // 900–960  Row2 Right fade in (0.6s)
    // 960–980  short rest (0.2s)
    // 980–1040 Row3 fade in (0.6s)
    // 1040–1100 hold full logo (0.6s)
    // 1100–1160 Row3 fade out (0.6s)
    // 1160–1180 short rest (0.2s)
    // 1180–1240 Row2 Right fade out (0.6s)
    // 1240–1260 short rest (0.2s)
    // 1260–1320 Row2 Left fade out (0.6s)
    // 1320–1400 final rest (0.8s)

    // Row 2 LEFT (first in, last out)
    _row2LeftOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 820), // spin + pause
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: ease)),
        weight: 60, // 820–880 fade in
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 380), // 880–1260 hold visible
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: ease)),
        weight: 60, // 1260–1320 fade out
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 80), // 1320–1400 final rest
    ]).animate(_c);

    // Row 2 RIGHT (after left, before left out)
    _row2RightOpacity = TweenSequence<double>([
      // Hidden through: spin + pause + left-in + short rest
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 900), // 0–900
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: ease)),
        weight: 60, // 900–960 fade in
      ),
      // Hold through: rest + row3 in + hold + row3 out + rest
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 220), // 960–1180
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: ease)),
        weight: 60, // 1180–1240 fade out (before Left)
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 160), // 1240–1400 rest
    ]).animate(_c);

    // Row 3 (last in, first out)
    _row3Opacity = TweenSequence<double>([
      // Hidden through: spin + pause + L-in + rest + R-in + rest
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 980), // 0–980
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: ease)),
        weight: 60, // 980–1040 fade in
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60), // 1040–1100 hold
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: ease)),
        weight: 60, // 1100–1160 fade out (first in exit)
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 240), // 1160–1400 rest
    ]).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.002) // perspective for 3D effect
          ..rotateY(_spin.value);

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Row 2 LEFT (half-pill)
              Opacity(
                opacity: _row2LeftOpacity.value.clamp(0.0, 1.0),
                child: CustomPaint(size: Size.square(size), painter: _Row2LeftPainter()),
              ),
              // Row 2 RIGHT (circle)
              Opacity(
                opacity: _row2RightOpacity.value.clamp(0.0, 1.0),
                child: CustomPaint(size: Size.square(size), painter: _Row2RightPainter()),
              ),
              // Row 3 (green droplet)
              Opacity(
                opacity: _row3Opacity.value.clamp(0.0, 1.0),
                child: CustomPaint(size: Size.square(size), painter: _Row3Painter()),
              ),
              // Row 1 (spinning pill)
              Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: CustomPaint(size: Size.square(size), painter: _Row1Painter()),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ------------------------------- Brand Colors ------------------------------ */
const _cRed    = Color(0xFFF24E1E);
const _cOrange = Color(0xFFFF7262);
const _cPurple = Color(0xFFA259FF);
const _cBlue   = Color(0xFF1ABCFE);
const _cGreen  = Color(0xFF0ACF83);

/* ------------------------------- Grid Helpers ------------------------------ */
class _Grid {
  final double s;
  final double r;
  _Grid(this.s) : r = s / 2;
  Rect cell(int col, int row) => Rect.fromLTWH(col * s, row * s, s, s);
  RRect halfPillLeft(Rect rect) => RRect.fromRectAndCorners(
      rect, topLeft: Radius.circular(r), bottomLeft: Radius.circular(r));
  RRect halfPillRight(Rect rect) => RRect.fromRectAndCorners(
      rect, topRight: Radius.circular(r), bottomRight: Radius.circular(r));
  RRect circle(Rect rect) => RRect.fromRectXY(rect, r, r);
}

/* -------------------------- Painters --------------------------------------- */
class _Row1Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 3;
    final g = _Grid(s);
    final dx = (size.width - 2 * s) / 2;
    final dy = (size.height - 3 * s) / 2;
    canvas.translate(dx, dy);
    canvas.drawRRect(g.halfPillLeft(g.cell(0, 0)), Paint()..color = _cRed);
    canvas.drawRRect(g.halfPillRight(g.cell(1, 0)), Paint()..color = _cOrange);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Row 2 LEFT only
class _Row2LeftPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 3;
    final g = _Grid(s);
    final dx = (size.width - 2 * s) / 2;
    final dy = (size.height - 3 * s) / 2;
    canvas.translate(dx, dy);
    canvas.drawRRect(g.halfPillLeft(g.cell(0, 1)), Paint()..color = _cPurple);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Row 2 RIGHT only
class _Row2RightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 3;
    final g = _Grid(s);
    final dx = (size.width - 2 * s) / 2;
    final dy = (size.height - 3 * s) / 2;
    canvas.translate(dx, dy);
    canvas.drawRRect(g.circle(g.cell(1, 1)), Paint()..color = _cBlue);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Row 3 with the “top-right fill” to create the droplet illusion
class _Row3Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 3;
    final g = _Grid(s);
    final dx = (size.width - 2 * s) / 2;
    final dy = (size.height - 3 * s) / 2;
    canvas.translate(dx, dy);

    final greenRect = g.cell(0, 2);
    final paintGreen = Paint()..color = _cGreen;

    // Perfect circle
    canvas.drawRRect(g.circle(greenRect), paintGreen);

    // Fill only the top-right quadrant so it meets the purple above
    final r = g.r;
    final topRightQuadrant =
    Rect.fromLTWH(greenRect.left + r, greenRect.top, r, r);
    canvas.drawRect(topRightQuadrant, paintGreen);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

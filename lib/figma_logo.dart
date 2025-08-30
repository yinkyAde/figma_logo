import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: Color(0xFF1E1E1E),
    body: Center(child: FigmaLogo(size: 240)),
  ),
));

/// Exact static Figma logo with bottom-left circle + top-right quadrant fill.
class FigmaLogo extends StatelessWidget {
  final double size;
  const FigmaLogo({super.key, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _FigmaPainter());
  }
}

class _FigmaPainter extends CustomPainter {
  // Figma brand colors
  static const red    = Color(0xFFF24E1E);
  static const orange = Color(0xFFFF7262);
  static const purple = Color(0xFFA259FF);
  static const blue   = Color(0xFF1ABCFE);
  static const green  = Color(0xFF0ACF83);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 3; // cell size
    final r = s / 2;                 // corner radius

    // center the 2×3 block
    final dx = (size.width  - 2 * s) / 2;
    final dy = (size.height - 3 * s) / 2;
    canvas.translate(dx, dy);

    Rect cell(int col, int row) => Rect.fromLTWH(col * s, row * s, s, s);

    RRect halfPillLeft(Rect rect)  => RRect.fromRectAndCorners(
        rect, topLeft: Radius.circular(r), bottomLeft: Radius.circular(r));
    RRect halfPillRight(Rect rect) => RRect.fromRectAndCorners(
        rect, topRight: Radius.circular(r), bottomRight: Radius.circular(r));
    RRect circle(Rect rect)        => RRect.fromRectXY(rect, r, r);

    // Row 1
    canvas.drawRRect(halfPillLeft(cell(0, 0)),  Paint()..color = red);
    canvas.drawRRect(halfPillRight(cell(1, 0)), Paint()..color = orange);

    // Row 2
    final purpleRect = cell(0, 1);
    canvas.drawRRect(halfPillLeft(purpleRect), Paint()..color = purple);
    canvas.drawRRect(circle(cell(1, 1)),        Paint()..color = blue);

    // Row 3 — bottom-left circle + ONLY top-right quadrant fill
    final greenRect = cell(0, 2);

    // 1) Perfect circle
    final paintGreen = Paint()..color = green;
    canvas.drawRRect(circle(greenRect), paintGreen);

    // 2) Fill the top-right quadrant of the bottom-left cell
    //    (width r, height r) so it meets the purple above.
    final topRightQuadrant =
    Rect.fromLTWH(greenRect.left + r, greenRect.top, r, r);
    canvas.drawRect(topRightQuadrant, paintGreen);

    // Row 3 right is intentionally empty.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

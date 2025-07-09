import 'package:flutter/material.dart';

class PriceChart extends CustomPainter {
  final List<double> prices;
  final Color color;
  final double maxPrice;
  final double minPrice;

  PriceChart(this.prices, this.color)
    : maxPrice = prices.reduce((a, b) => a > b ? a : b),
      minPrice = prices.reduce((a, b) => a < b ? a : b);

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Calculate scaling factors
    final double xUnit = size.width / (prices.length - 1);
    final double yUnit;
    if (maxPrice == minPrice) {
      yUnit = 0;
    } else {
      yUnit = size.height / (maxPrice - minPrice);
    }

    // Move to the first point
    if (yUnit == 0) {
      path.moveTo(0, size.height / 2);
    } else {
      path.moveTo(0, size.height - (prices[0] - minPrice) * yUnit);
    }

    // Draw lines to subsequent points
    double x, y;
    for (int i = 1; i < prices.length; i++) {
      x = i * xUnit;
      if (yUnit == 0) {
        y = size.height / 2;
      } else {
        y = size.height - (prices[i] - minPrice) * yUnit;
      }
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

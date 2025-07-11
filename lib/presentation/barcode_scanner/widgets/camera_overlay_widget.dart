import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CameraOverlayWidget extends StatelessWidget {
  final Animation<double> scanAnimation;
  final Function(TapUpDetails) onTapToFocus;

  const CameraOverlayWidget({
    super.key,
    required this.scanAnimation,
    required this.onTapToFocus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: onTapToFocus,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Scanning reticle in center
            _buildScanningReticle(),

            // Corner guides for barcode alignment
            _buildCornerGuides(),

            // Scanning line animation
            _buildScanningLine(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningReticle() {
    return Center(
      child: Container(
        width: 70.w,
        height: 35.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner brackets
            _buildCornerBracket(Alignment.topLeft),
            _buildCornerBracket(Alignment.topRight),
            _buildCornerBracket(Alignment.bottomLeft),
            _buildCornerBracket(Alignment.bottomRight),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBracket(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? BorderSide(color: AppTheme.lightTheme.primaryColor, width: 3)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? BorderSide(color: AppTheme.lightTheme.primaryColor, width: 3)
                : BorderSide.none,
            left: alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? BorderSide(color: AppTheme.lightTheme.primaryColor, width: 3)
                : BorderSide.none,
            right: alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? BorderSide(color: AppTheme.lightTheme.primaryColor, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCornerGuides() {
    return Positioned.fill(
      child: CustomPaint(
        painter: CornerGuidesPainter(),
      ),
    );
  }

  Widget _buildScanningLine() {
    return Center(
      child: Container(
        width: 70.w,
        height: 35.h,
        child: AnimatedBuilder(
          animation: scanAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: scanAnimation.value * 35.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.lightTheme.primaryColor,
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CornerGuidesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final guideLength = 20;

    // Top guides
    canvas.drawLine(
      Offset(centerX - guideLength, centerY - size.height * 0.2),
      Offset(centerX + guideLength, centerY - size.height * 0.2),
      paint,
    );

    // Bottom guides
    canvas.drawLine(
      Offset(centerX - guideLength, centerY + size.height * 0.2),
      Offset(centerX + guideLength, centerY + size.height * 0.2),
      paint,
    );

    // Left guides
    canvas.drawLine(
      Offset(centerX - size.width * 0.3, centerY - guideLength),
      Offset(centerX - size.width * 0.3, centerY + guideLength),
      paint,
    );

    // Right guides
    canvas.drawLine(
      Offset(centerX + size.width * 0.3, centerY - guideLength),
      Offset(centerX + size.width * 0.3, centerY + guideLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

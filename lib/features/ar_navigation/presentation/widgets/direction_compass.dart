import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DirectionCompass extends StatefulWidget {
  final double bearing; // degrees (0-360), where 0 = North
  final String currentStreet;
  final String nextInstruction;
  final double distance; // in meters

  const DirectionCompass({
    this.bearing = 0,
    this.currentStreet = 'Main Street',
    this.nextInstruction = 'Turn right',
    this.distance = 150,
    super.key,
  });

  @override
  State<DirectionCompass> createState() => _DirectionCompassState();
}

class _DirectionCompassState extends State<DirectionCompass>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(DirectionCompass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bearing != widget.bearing) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Compass Triangle
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final animation =
                  Tween<double>(
                    begin: 0,
                    end: widget.bearing * (3.14159 / 180),
                  ).evaluate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOutCubic,
                    ),
                  );

              return Transform.rotate(
                angle: animation,
                child: CustomPaint(
                  size: const Size(120, 140),
                  painter: CompassPainter(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Street Name
          Text(
            widget.currentStreet,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Next Instruction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Text(
              widget.nextInstruction,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // Distance
          Text(
            '${widget.distance.toStringAsFixed(0)}m ahead',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw shadow/glow effect
    canvas.drawPath(_createTrianglePath(size, offset: 4), shadowPaint);

    // Draw main triangle
    canvas.drawPath(_createTrianglePath(size), paint);

    // Draw highlight/shine effect
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(size.width / 2, size.height * 0.15);
    highlightPath.lineTo(size.width * 0.35, size.height * 0.4);
    highlightPath.lineTo(size.width * 0.65, size.height * 0.4);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);

    // Draw north indicator circle at the top
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.1), 5, paint);
  }

  Path _createTrianglePath(Size size, {double offset = 0}) {
    final path = Path();
    // Point (top center)
    path.moveTo(size.width / 2, offset);
    // Bottom left
    path.lineTo(offset, size.height);
    // Bottom right
    path.lineTo(size.width - offset, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) => false;
}

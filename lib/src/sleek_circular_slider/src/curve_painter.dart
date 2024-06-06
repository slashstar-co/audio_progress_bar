part of 'circular_slider.dart';

class _CurvePainter extends CustomPainter {
  final double angle;
  final CircularSliderAppearance appearance;
  final double startAngle;
  final double angleRange;

  Offset? handler;
  Offset? center;
  late double radius;

  _CurvePainter({required this.appearance, this.angle = 30, required this.startAngle, required this.angleRange});

  @override
  void paint(Canvas canvas, Size size) {
    radius = math.min(size.width / 2, size.height / 2) - appearance.progressBarWidth * 0.5;
    center = Offset(size.width / 2, size.height / 2);

    final progressBarRect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);

    Paint trackPaint;
    if (appearance.trackColors != null) {
      final trackGradient = SweepGradient(
        startAngle: degreeToRadians(appearance.trackGradientStartAngle),
        endAngle: degreeToRadians(appearance.trackGradientStopAngle),
        tileMode: TileMode.mirror,
        colors: appearance.trackColors!,
      );
      trackPaint = Paint()
        ..shader = trackGradient.createShader(progressBarRect)
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke
        ..strokeWidth = appearance.trackWidth;
    } else {
      trackPaint = Paint()
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke
        ..strokeWidth = appearance.trackWidth
        ..color = appearance.trackColor;
    }
    drawCircularArc(canvas: canvas, size: size, paint: trackPaint, ignoreAngle: true);

    if (!appearance.hideShadow) {
      drawShadow(canvas: canvas, size: size);
    }

    final currentAngle = angle;
    final dynamicGradient = appearance.dynamicGradient;
    final gradientRotationAngle = dynamicGradient
        ? startAngle - 10.0
        : 0.0;
    final GradientRotation rotation = GradientRotation(degreeToRadians(gradientRotationAngle));

    final gradientStartAngle = dynamicGradient
        ? 0.0
        : appearance.gradientStartAngle;
    final gradientEndAngle = dynamicGradient
        ? currentAngle.abs()
        : appearance.gradientStopAngle;
    final colors = appearance.progressBarColors;

    final progressBarGradient = SweepGradient(
      transform: rotation,
      startAngle: degreeToRadians(gradientStartAngle),
      endAngle: degreeToRadians(gradientEndAngle),
      tileMode: TileMode.mirror,
      colors: colors,
    );

    final progressBarPaint = Paint()
      ..shader = progressBarGradient.createShader(progressBarRect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.progressBarWidth;
    drawCircularArc(canvas: canvas, size: size, paint: progressBarPaint);

    var dotPaint = Paint()..color = appearance.dotColor;

    Offset handler = degreesToCoordinates(center!, -math.pi / 2 + startAngle + currentAngle + 1.5, radius);
    Offset handler1 = degreesToCoordinates(center!, -math.pi / 2 + appearance.startAngle + 1.5, radius);

    canvas.save();
    canvas.translate(handler1.dx, handler1.dy);
    canvas.rotate(12.05);
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0,6), width: appearance.progressBarWidth, height: appearance.progressBarWidth - 10),
      Paint()..shader = progressBarGradient.createShader(progressBarRect)..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    canvas.drawCircle(handler, appearance.handlerSize, dotPaint);
  }

  drawCircularArc(
      {required Canvas canvas, required Size size, required Paint paint, bool ignoreAngle = false}) {
    final double angleValue = ignoreAngle ? 0 : (angleRange - angle);
    final range =  angleRange;
    final currentAngle =  -angleValue;
    canvas.drawArc(Rect.fromCircle(center: center!, radius: radius), degreeToRadians(startAngle),
        degreeToRadians(range + currentAngle), false, paint);
  }

  drawShadow({required Canvas canvas, required Size size}) {
    final shadowStep = appearance.shadowStep != null
        ? appearance.shadowStep!
        : math.max(1, (appearance.shadowWidth - appearance.progressBarWidth) ~/ 10);
    final maxOpacity = math.min(1.0, appearance.shadowMaxOpacity);
    final repetitions = math.max(1, ((appearance.shadowWidth - appearance.progressBarWidth) ~/ shadowStep));
    final opacityStep = maxOpacity / repetitions;
    final shadowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= repetitions; i++) {
      shadowPaint.strokeWidth = appearance.progressBarWidth + i * shadowStep;
      shadowPaint.color = appearance.shadowColor.withOpacity(maxOpacity - (opacityStep * (i - 1)));
      drawCircularArc(canvas: canvas, size: size, paint: shadowPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

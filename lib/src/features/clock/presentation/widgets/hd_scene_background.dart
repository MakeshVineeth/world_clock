import 'dart:math' as math;

import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Native 24-bit QHD+ vector background reproducing the Day (Sunset Swan Lake)
/// and Night (Starry Crescent-Moon Mountains) scenes without 8-bit GIF dithering.
class HdSceneBackground extends StatefulWidget {
  final bool isDayTime;
  final Widget child;

  const HdSceneBackground({
    super.key,
    required this.isDayTime,
    required this.child,
  });

  @override
  State<HdSceneBackground> createState() => _HdSceneBackgroundState();
}

class _HdSceneBackgroundState extends State<HdSceneBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (GoogleFonts.config.allowRuntimeFetching) {
      _controller.repeat();
    } else {
      _controller.value = 0.25;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: widget.isDayTime
          ? _DayScenePainter(animation: _controller)
          : _NightScenePainter(animation: _controller),
      child: widget.child,
    );
  }
}

class _DayScenePainter extends CustomPainter {
  final Animation<double> animation;

  _DayScenePainter({required this.animation}) : super(repaint: animation);

  static const List<_StarSpec> _stars = <_StarSpec>[
    _StarSpec(0.118, 0.118, 2.2, 0.0),
    _StarSpec(0.326, 0.052, 2.4, 1.3),
    _StarSpec(0.556, 0.101, 2.0, 2.6),
    _StarSpec(0.866, 0.031, 2.3, 3.8),
    _StarSpec(0.758, 0.135, 1.8, 5.1),
    _StarSpec(0.210, 0.195, 1.5, 2.0),
    _StarSpec(0.640, 0.155, 1.6, 4.4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double phase = animation.value * 2.0 * math.pi;
    final double horizonY = size.height * 0.568;

    _paintSky(canvas, size, horizonY);
    _paintStars(canvas, size, phase);
    _paintClouds(canvas, size, phase);
    _paintSun(canvas, size, horizonY, phase);
    _paintDistantMountains(canvas, size, horizonY);
    _paintLakeWater(canvas, size, horizonY, phase);
    _paintForegroundHeadlands(canvas, size, horizonY);
    _paintFence(canvas, size, horizonY);
    _paintSwan(canvas, size, phase);
  }

  void _paintSky(Canvas canvas, Size size, double horizonY) {
    final Rect skyRect = Rect.fromLTWH(0, 0, size.width, horizonY + 2);
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF0A1931),
          Color(0xFF1D335B),
          Color(0xFF3E4A78),
          Color(0xFF775680),
          Color(0xFFB86C6E),
          Color(0xFFE7955E),
          Color(0xFFFAD184),
        ],
        stops: <double>[0.0, 0.16, 0.34, 0.52, 0.70, 0.86, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);
  }

  void _paintStars(Canvas canvas, Size size, double phase) {
    final Paint starPaint = Paint()..style = PaintingStyle.fill;
    for (final _StarSpec star in _stars) {
      final double alpha =
          (0.45 + 0.50 * math.sin(phase + star.phaseOffset)).clamp(0.15, 0.95);
      starPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(size.width * star.x, size.height * star.y),
        star.radius,
        starPaint,
      );
    }
  }

  void _paintClouds(Canvas canvas, Size size, double phase) {
    final double drift = math.sin(phase) * size.width * 0.012;
    final Paint upperCloud = Paint()
      ..color = const Color(0x444B5A94)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.82 + drift, size.height * 0.075),
        width: size.width * 0.42,
        height: size.height * 0.055,
      ),
      upperCloud,
    );

    final Paint sunsetCloud = Paint()
      ..color = const Color(0x558B4F6E)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.80 - drift, size.height * 0.398),
          width: size.width * 0.46,
          height: size.height * 0.036,
        ),
        const Radius.circular(24),
      ),
      sunsetCloud,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.84 - drift * 0.6, size.height * 0.422),
          width: size.width * 0.36,
          height: size.height * 0.028,
        ),
        const Radius.circular(20),
      ),
      sunsetCloud,
    );
  }

  void _paintSun(Canvas canvas, Size size, double horizonY, double phase) {
    final Offset sunCenter = Offset(size.width * 0.482, horizonY);
    final double sunRadius = size.width * 0.068;
    final double pulse = 1.0 + 0.03 * math.sin(phase);

    final Rect glowRect = Rect.fromCircle(
      center: sunCenter,
      radius: sunRadius * 3.8 * pulse,
    );
    final Paint glowPaint = Paint()
      ..shader = const RadialGradient(
        colors: <Color>[
          Color(0xCCFFF8DC),
          Color(0x66FFB35C),
          Color(0x00E7955E),
        ],
        stops: <double>[0.0, 0.45, 1.0],
      ).createShader(glowRect);
    canvas.drawCircle(sunCenter, sunRadius * 3.8 * pulse, glowPaint);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, horizonY));
    final Paint sunDisc = Paint()..color = const Color(0xFFFFFDF7);
    canvas.drawCircle(sunCenter, sunRadius, sunDisc);
    canvas.restore();
  }

  void _paintDistantMountains(Canvas canvas, Size size, double horizonY) {
    final Path leftMountain = Path()
      ..moveTo(0, horizonY)
      ..lineTo(size.width * 0.125, horizonY - size.height * 0.035)
      ..lineTo(size.width * 0.175, horizonY - size.height * 0.022)
      ..lineTo(size.width * 0.195, horizonY - size.height * 0.026)
      ..lineTo(size.width * 0.262, horizonY)
      ..close();
    canvas.drawPath(
      leftMountain,
      Paint()..color = const Color(0xFF635375),
    );

    final Path rightDistant = Path()
      ..moveTo(size.width * 0.635, horizonY)
      ..lineTo(size.width * 0.725, horizonY - size.height * 0.032)
      ..lineTo(size.width * 0.768, horizonY - size.height * 0.038)
      ..lineTo(size.width * 0.835, horizonY)
      ..close();
    canvas.drawPath(
      rightDistant,
      Paint()..color = const Color(0xFF61516B),
    );
  }

  void _paintLakeWater(
    Canvas canvas,
    Size size,
    double horizonY,
    double phase,
  ) {
    final Rect waterRect = Rect.fromLTWH(
      0,
      horizonY,
      size.width,
      size.height - horizonY,
    );
    final Paint waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFEDA66A),
          Color(0xFFC27368),
          Color(0xFF8B4F66),
          Color(0xFF563353),
          Color(0xFF281936),
        ],
        stops: <double>[0.0, 0.22, 0.48, 0.76, 1.0],
      ).createShader(waterRect);
    canvas.drawRect(waterRect, waterPaint);

    // Shimmering sun reflection column
    final Offset reflectCenter = Offset(
      size.width * 0.482,
      horizonY + size.height * 0.035,
    );
    final Rect reflectRect = Rect.fromCenter(
      center: reflectCenter,
      width: size.width * 0.34,
      height: size.height * 0.18,
    );
    final Paint reflectPaint = Paint()
      ..shader = const RadialGradient(
        colors: <Color>[
          Color(0xCCFFF3C4),
          Color(0x55F7B46E),
          Color(0x00C27368),
        ],
      ).createShader(reflectRect);
    canvas.save();
    canvas.clipRect(waterRect);
    canvas.drawOval(reflectRect, reflectPaint);

    final Paint ripplePaint = Paint()
      ..color = const Color(0x44FFE5B4)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 12; i++) {
      final double y = horizonY + (i * size.height * 0.014) + 4.0;
      final double halfW =
          size.width * (0.085 - i * 0.004) *
          (0.92 + 0.08 * math.sin(phase + i));
      canvas.drawLine(
        Offset(reflectCenter.dx - halfW, y),
        Offset(reflectCenter.dx + halfW, y),
        ripplePaint,
      );
    }
    canvas.restore();
  }

  void _paintForegroundHeadlands(Canvas canvas, Size size, double horizonY) {
    final Path leftSlope = Path()
      ..moveTo(0, horizonY - size.height * 0.022)
      ..lineTo(size.width * 0.185, horizonY + size.height * 0.011)
      ..lineTo(0, horizonY + size.height * 0.045)
      ..close();
    canvas.drawPath(leftSlope, Paint()..color = const Color(0xFF3E2236));

    final Path rightCliff = Path()
      ..moveTo(size.width * 0.745, horizonY + size.height * 0.004)
      ..quadraticBezierTo(
        size.width * 0.86,
        horizonY - size.height * 0.038,
        size.width * 0.905,
        horizonY - size.height * 0.082,
      )
      ..quadraticBezierTo(
        size.width * 0.945,
        horizonY - size.height * 0.098,
        size.width,
        horizonY - size.height * 0.105,
      )
      ..lineTo(size.width, horizonY + size.height * 0.006)
      ..close();
    canvas.drawPath(rightCliff, Paint()..color = const Color(0xFF2B121E));
  }

  void _paintFence(Canvas canvas, Size size, double horizonY) {
    final Path bankPath = Path()
      ..moveTo(size.width * 0.635, horizonY + size.height * 0.062)
      ..quadraticBezierTo(
        size.width * 0.86,
        horizonY + size.height * 0.068,
        size.width,
        horizonY + size.height * 0.118,
      )
      ..lineTo(size.width, horizonY + size.height * 0.103)
      ..quadraticBezierTo(
        size.width * 0.86,
        horizonY + size.height * 0.058,
        size.width * 0.635,
        horizonY + size.height * 0.058,
      )
      ..close();
    canvas.drawPath(bankPath, Paint()..color = const Color(0xFF23162B));

    final List<Offset> posts = <Offset>[
      Offset(size.width * 0.636, horizonY + size.height * 0.059),
      Offset(size.width * 0.695, horizonY + size.height * 0.061),
      Offset(size.width * 0.758, horizonY + size.height * 0.065),
      Offset(size.width * 0.835, horizonY + size.height * 0.072),
      Offset(size.width * 0.915, horizonY + size.height * 0.084),
      Offset(size.width * 0.985, horizonY + size.height * 0.102),
    ];

    final Paint postPaint = Paint()
      ..color = const Color(0xFF23162B)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final Paint ropePaint = Paint()
      ..color = const Color(0xCC23162B)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < posts.length; i++) {
      final double postH = size.height * (0.016 + i * 0.0025);
      final Offset base = posts[i];
      final Offset top = Offset(base.dx, base.dy - postH);
      canvas.drawLine(base, top, postPaint);

      if (i < posts.length - 1) {
        final Offset nextBase = posts[i + 1];
        final double nextH = size.height * (0.016 + (i + 1) * 0.0025);
        final Offset nextTop = Offset(nextBase.dx, nextBase.dy - nextH);
        final Path rope = Path()
          ..moveTo(top.dx, top.dy + 2)
          ..quadraticBezierTo(
            (top.dx + nextTop.dx) * 0.5,
            math.max(top.dy, nextTop.dy) + 4,
            nextTop.dx,
            nextTop.dy + 2,
          );
        canvas.drawPath(rope, ropePaint);
      }
    }
  }

  void _paintSwan(Canvas canvas, Size size, double phase) {
    final double bob = math.sin(phase) * 1.5;
    final double driftX = math.cos(phase * 0.5) * size.width * 0.008;
    final Offset origin = Offset(
      size.width * 0.268 + driftX,
      size.height * 0.795 + bob,
    );
    final double s = size.width * 0.082;

    // Water ripple ring under swan
    final Paint ripple = Paint()
      ..color = const Color(0x55E7A890)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(origin.dx + s * 0.05, origin.dy + s * 0.14),
        width: s * 1.25,
        height: s * 0.22,
      ),
      ripple,
    );

    // Swan silhouette
    final Path swan = Path()
      ..moveTo(origin.dx - s * 0.45, origin.dy + s * 0.05)
      ..quadraticBezierTo(
        origin.dx - s * 0.25,
        origin.dy - s * 0.14,
        origin.dx + s * 0.18,
        origin.dy - s * 0.08,
      )
      ..quadraticBezierTo(
        origin.dx + s * 0.08,
        origin.dy - s * 0.45,
        origin.dx + s * 0.22,
        origin.dy - s * 0.56,
      )
      ..quadraticBezierTo(
        origin.dx + s * 0.36,
        origin.dy - s * 0.62,
        origin.dx + s * 0.44,
        origin.dy - s * 0.46,
      )
      ..lineTo(origin.dx + s * 0.36, origin.dy - s * 0.44)
      ..quadraticBezierTo(
        origin.dx + s * 0.22,
        origin.dy - s * 0.48,
        origin.dx + s * 0.24,
        origin.dy - s * 0.22,
      )
      ..quadraticBezierTo(
        origin.dx + s * 0.36,
        origin.dy + s * 0.06,
        origin.dx + s * 0.42,
        origin.dy + s * 0.12,
      )
      ..quadraticBezierTo(
        origin.dx,
        origin.dy + s * 0.18,
        origin.dx - s * 0.45,
        origin.dy + s * 0.05,
      )
      ..close();
    canvas.drawPath(swan, Paint()..color = const Color(0xFF19162B));
  }

  @override
  bool shouldRepaint(covariant _DayScenePainter oldDelegate) => false;
}

class _NightScenePainter extends CustomPainter {
  final Animation<double> animation;

  _NightScenePainter({required this.animation}) : super(repaint: animation);

  static const List<_StarSpec> _stars = <_StarSpec>[
    _StarSpec(0.10, 0.08, 2.0, 0.0),
    _StarSpec(0.24, 0.13, 2.6, 1.1),
    _StarSpec(0.18, 0.24, 1.8, 2.2),
    _StarSpec(0.42, 0.10, 2.1, 3.3),
    _StarSpec(0.58, 0.07, 1.9, 4.4),
    _StarSpec(0.51, 0.29, 1.7, 0.8),
    _StarSpec(0.34, 0.38, 2.2, 1.9),
    _StarSpec(0.68, 0.35, 1.8, 2.7),
    _StarSpec(0.84, 0.41, 2.1, 3.9),
    _StarSpec(0.14, 0.49, 2.4, 4.8),
    _StarSpec(0.55, 0.51, 2.3, 5.5),
    _StarSpec(0.76, 0.58, 1.9, 1.4),
    _StarSpec(0.90, 0.29, 1.7, 2.9),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double phase = animation.value * 2.0 * math.pi;

    _paintNightSky(canvas, size);
    _paintStars(canvas, size, phase);
    _paintCrescentMoon(canvas, size, phase);
    _paintNightClouds(canvas, size, phase);
    _paintMountains(canvas, size);
  }

  void _paintNightSky(Canvas canvas, Size size) {
    final Rect full = Offset.zero & size;
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: <Color>[
          Color(0xFF010414),
          Color(0xFF060B28),
          Color(0xFF17183B),
          Color(0xFF392347),
          Color(0xFF6A3C49),
          Color(0xFF8C534E),
        ],
        stops: <double>[0.0, 0.24, 0.46, 0.68, 0.86, 1.0],
      ).createShader(full);
    canvas.drawRect(full, skyPaint);
  }

  void _paintStars(Canvas canvas, Size size, double phase) {
    final Paint starPaint = Paint()..style = PaintingStyle.fill;
    for (final _StarSpec star in _stars) {
      final double alpha =
          (0.50 + 0.48 * math.sin(phase + star.phaseOffset)).clamp(0.20, 0.98);
      final Offset center = Offset(size.width * star.x, size.height * star.y);
      starPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(center, star.radius, starPaint);

      if (star.radius >= 2.2) {
        final Paint sparkle = Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.65)
          ..strokeWidth = 1.0;
        final double arm = star.radius * 2.4;
        canvas.drawLine(
          Offset(center.dx - arm, center.dy),
          Offset(center.dx + arm, center.dy),
          sparkle,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - arm),
          Offset(center.dx, center.dy + arm),
          sparkle,
        );
      }
    }
  }

  void _paintCrescentMoon(Canvas canvas, Size size, double phase) {
    final Offset moonCenter = Offset(size.width * 0.78, size.height * 0.165);
    final double moonRadius = size.width * 0.088;
    final double haloScale = 1.0 + 0.025 * math.sin(phase);

    final Rect haloRect = Rect.fromCircle(
      center: moonCenter,
      radius: moonRadius * 2.5 * haloScale,
    );
    final Paint haloPaint = Paint()
      ..shader = const RadialGradient(
        colors: <Color>[
          Color(0x44CBD5E1),
          Color(0x1894A3B8),
          Color(0x00060B28),
        ],
      ).createShader(haloRect);
    canvas.drawCircle(moonCenter, moonRadius * 2.5 * haloScale, haloPaint);

    // Subtle dark lunar disc (earthshine)
    canvas.drawCircle(
      moonCenter,
      moonRadius,
      Paint()..color = const Color(0xFF1B2338),
    );

    // Bright crescent via evenOdd path difference
    final Path outerCircle = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    final Path innerCut = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(
            moonCenter.dx + moonRadius * 0.38,
            moonCenter.dy - moonRadius * 0.14,
          ),
          radius: moonRadius * 0.88,
        ),
      );
    final Path crescent = Path.combine(
      PathOperation.difference,
      outerCircle,
      innerCut,
    );
    canvas.drawPath(crescent, Paint()..color = const Color(0xFFF8FAFC));
  }

  void _paintNightClouds(Canvas canvas, Size size, double phase) {
    final double drift = math.sin(phase) * size.width * 0.015;
    final Paint cloudPaint = Paint()
      ..color = const Color(0x40CBD5E1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Top-center wispy cloud bands
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.45 + drift, size.height * 0.215),
          width: size.width * 0.56,
          height: size.height * 0.014,
        ),
        const Radius.circular(12),
      ),
      cloudPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.42 - drift * 0.7, size.height * 0.232),
          width: size.width * 0.64,
          height: size.height * 0.016,
        ),
        const Radius.circular(12),
      ),
      cloudPaint,
    );

    // Moon lower wisp
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.84 - drift, size.height * 0.255),
          width: size.width * 0.34,
          height: size.height * 0.014,
        ),
        const Radius.circular(12),
      ),
      cloudPaint,
    );
  }

  void _paintMountains(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;

    // Far-left snow-capped peak
    _drawPeak(
      canvas,
      apex: Offset(w * 0.04, h * 0.62),
      leftBase: Offset(-w * 0.12, h * 0.94),
      rightBase: Offset(w * 0.26, h * 0.94),
      litColor: const Color(0xFF223D33),
      shadowColor: const Color(0xFF0A1713),
      snowColor: const Color(0xFFDCE3E6),
    );

    // Mid-left foreground peak
    _drawPeak(
      canvas,
      apex: Offset(w * 0.22, h * 0.72),
      leftBase: Offset(-w * 0.05, h),
      rightBase: Offset(w * 0.46, h),
      litColor: const Color(0xFF1B332B),
      shadowColor: const Color(0xFF07120E),
      snowColor: const Color(0xFFBEC9CD),
    );

    // Central tall Matterhorn-style snow-capped peak
    _drawPeak(
      canvas,
      apex: Offset(w * 0.54, h * 0.63),
      leftBase: Offset(w * 0.24, h),
      rightBase: Offset(w * 0.82, h),
      litColor: const Color(0xFF183328),
      shadowColor: const Color(0xFF050E0A),
      snowColor: const Color(0xFFE2E8EC),
    );

    // Right green-black peak
    _drawPeak(
      canvas,
      apex: Offset(w * 0.76, h * 0.79),
      leftBase: Offset(w * 0.56, h),
      rightBase: Offset(w * 0.98, h),
      litColor: const Color(0xFF102A1E),
      shadowColor: const Color(0xFF040B08),
      snowColor: null,
    );

    // Bottom rolling dark emerald hill
    final Path hill = Path()
      ..moveTo(w * 0.58, h)
      ..quadraticBezierTo(w * 0.85, h * 0.90, w * 1.05, h * 0.93)
      ..lineTo(w * 1.05, h)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF0C2318));
  }

  void _drawPeak(
    Canvas canvas, {
    required Offset apex,
    required Offset leftBase,
    required Offset rightBase,
    required Color litColor,
    required Color shadowColor,
    required Color? snowColor,
  }) {
    final Offset ridgeMid = Offset(
      apex.dx + (rightBase.dx - leftBase.dx) * 0.03,
      leftBase.dy,
    );

    final Path leftFace = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(leftBase.dx, leftBase.dy)
      ..lineTo(ridgeMid.dx, ridgeMid.dy)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = litColor);

    final Path rightFace = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(ridgeMid.dx, ridgeMid.dy)
      ..lineTo(rightBase.dx, rightBase.dy)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = shadowColor);

    if (snowColor != null) {
      final double snowDrop = (leftBase.dy - apex.dy) * 0.24;
      final double leftT = 0.24;
      final double rightT = 0.22;
      final Offset snowLeft = Offset(
        apex.dx + (leftBase.dx - apex.dx) * leftT,
        apex.dy + snowDrop,
      );
      final Offset snowRight = Offset(
        apex.dx + (rightBase.dx - apex.dx) * rightT,
        apex.dy + snowDrop * 0.95,
      );
      final Path snowCap = Path()
        ..moveTo(apex.dx, apex.dy)
        ..lineTo(snowLeft.dx, snowLeft.dy)
        ..lineTo(
          apex.dx - (apex.dx - snowLeft.dx) * 0.35,
          apex.dy + snowDrop * 1.18,
        )
        ..lineTo(apex.dx, apex.dy + snowDrop * 0.85)
        ..lineTo(
          apex.dx + (snowRight.dx - apex.dx) * 0.45,
          apex.dy + snowDrop * 1.12,
        )
        ..lineTo(snowRight.dx, snowRight.dy)
        ..close();
      canvas.drawPath(
        snowCap,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              snowColor,
              snowColor.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromLTRB(
              snowLeft.dx,
              apex.dy,
              snowRight.dx,
              apex.dy + snowDrop * 1.25,
            ),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NightScenePainter oldDelegate) => false;
}

class _StarSpec {
  final double x;
  final double y;
  final double radius;
  final double phaseOffset;

  const _StarSpec(this.x, this.y, this.radius, this.phaseOffset);
}

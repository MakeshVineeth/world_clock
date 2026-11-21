import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Typography styles matching the original Flutter Clock presentation.
abstract final class AppTypography {
  static const List<Shadow> clockShadow = <Shadow>[
    Shadow(offset: Offset(1.0, 1.0), blurRadius: 3.0),
  ];

  static const TextStyle locationStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: clockShadow,
  );

  static const TextStyle dateStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
    color: Colors.white,
    shadows: clockShadow,
  );

  static const TextStyle boldLabelStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  static const TextStyle menuItemStyle = TextStyle(
    fontWeight: FontWeight.w600,
  );

  static TextStyle clockTimeStyle() {
    final TextStyle baseStyle = dateStyle.copyWith(
      fontSize: 50.0,
      letterSpacing: 2.0,
    );
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return baseStyle.copyWith(fontFamily: 'Aladin');
    }
    return GoogleFonts.aladin(textStyle: baseStyle);
  }
}

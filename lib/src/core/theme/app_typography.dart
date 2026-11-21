import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Typography system using geometric Google Sans-style UI text (`Plus Jakarta Sans`)
/// and a bold, high-contrast display clock typeface (`Outfit`).
abstract final class AppTypography {
  static const List<Shadow> clockShadow = <Shadow>[
    Shadow(
      offset: Offset(0.0, 1.5),
      blurRadius: 4.0,
      color: Color(0xE6000000),
    ),
    Shadow(
      offset: Offset(0.0, 3.0),
      blurRadius: 14.0,
      color: Color(0xB3000000),
    ),
  ];

  static const List<Shadow> clockTimeShadows = <Shadow>[
    Shadow(
      offset: Offset(0.0, 2.0),
      blurRadius: 5.0,
      color: Color(0xF2000000),
    ),
    Shadow(
      offset: Offset(0.0, 4.0),
      blurRadius: 18.0,
      color: Color(0xCC000000),
    ),
    Shadow(
      offset: Offset(0.0, 0.0),
      blurRadius: 30.0,
      color: Color(0x99000000),
    ),
  ];

  static const TextStyle _baseLocationStyle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.25,
    color: Colors.white,
    shadows: clockShadow,
  );

  static const TextStyle _baseDateStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
    color: Colors.white,
    shadows: clockShadow,
  );

  static const TextStyle _baseBoldLabelStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Color(0xFF1E293B),
  );

  static const TextStyle _baseMenuItemStyle = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Color(0xFF1E293B),
  );

  static const TextStyle _baseAppBarTitleStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: Colors.white,
  );

  static TextStyle get locationStyle =>
      _applyUiFont(_baseLocationStyle);

  static TextStyle get dateStyle =>
      _applyUiFont(_baseDateStyle);

  static TextStyle get boldLabelStyle =>
      _applyUiFont(_baseBoldLabelStyle);

  static TextStyle get menuItemStyle =>
      _applyUiFont(_baseMenuItemStyle);

  static TextStyle get appBarTitleStyle =>
      _applyUiFont(_baseAppBarTitleStyle);

  static TextStyle searchHintStyle(Color color) => _applyUiFont(
    TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: color,
    ),
  );

  static TextStyle clockTimeStyle() {
    const TextStyle baseStyle = TextStyle(
      fontSize: 60.0,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
      height: 1.1,
      color: Colors.white,
      shadows: clockTimeShadows,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    );
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return baseStyle.copyWith(fontFamily: 'Outfit');
    }
    return GoogleFonts.outfit(textStyle: baseStyle);
  }

  static TextTheme buildTextTheme(TextTheme base) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return base.apply(fontFamily: 'PlusJakartaSans');
    }
    return GoogleFonts.plusJakartaSansTextTheme(base);
  }

  static TextStyle _applyUiFont(TextStyle base) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return base.copyWith(fontFamily: 'PlusJakartaSans');
    }
    return GoogleFonts.plusJakartaSans(textStyle: base);
  }
}

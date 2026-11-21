import 'package:flutter/services.dart';
import 'package:flutter_clock/src/core/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';

/// Visual styling and overlay configuration for Flutter Clock.
abstract final class AppTheme {
  static final BorderRadius circleRadius = BorderRadius.circular(20);
  static const MaterialColor primarySwatch = Colors.blue;
  static const Color primaryColor = Colors.blue;
  static const Color loaderBackgroundColor = Colors.blueAccent;
  static const Color searchBarFillColor = Color.fromRGBO(142, 142, 147, 0.15);
  static const Color searchHintColor = Color.fromRGBO(110, 115, 125, 1);

  static const SystemUiOverlayStyle homeOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  static const SystemUiOverlayStyle locationsOverlayStyle =
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      );

  static ThemeData get lightTheme {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      primarySwatch: primarySwatch,
      scaffoldBackgroundColor: Colors.white,
    );
    return base.copyWith(
      textTheme: AppTypography.buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTypography.appBarTitleStyle,
        centerTitle: true,
        systemOverlayStyle: locationsOverlayStyle,
      ),
    );
  }
}

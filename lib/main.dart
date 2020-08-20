import 'package:flutter/material.dart';
import 'package:flutter_clock/home.dart';
import 'package:flutter_clock/loader.dart';
import 'package:flutter_clock/locations.dart';

void main() => runApp(MyClockApp());

class MyClockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => Loader(),
        '/home': (context) => Home(),
        '/location': (context) => Location(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

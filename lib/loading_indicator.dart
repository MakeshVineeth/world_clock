import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicator extends StatelessWidget {
  final Color color;

  const LoadingIndicator({this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitPulse(
        color: color,
        size: 50.0,
      ),
    );
  }
}

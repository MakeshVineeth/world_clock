import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_clock/locations_list/display_image.dart';
import 'package:flutter_clock/services/data_methods.dart';
import 'package:flutter_clock/services/time_provider.dart';
import 'package:provider/provider.dart';

class DisplayDate extends StatefulWidget {
  @override
  _DisplayDateState createState() => _DisplayDateState();
}

class _DisplayDateState extends State<DisplayDate> {
  Timer timer;
  int secondsLeft;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TimeProvider timeProvider = Provider.of<TimeProvider>(context);
    timer = Timer.periodic(
        Duration(seconds: timeProvider.worldTime.secondsLeft),
        (Timer t) => DataMethods().getNewTimeData(timeProvider));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DisplayImage(url: timeProvider.worldTime.flag),
            SizedBox(width: 10.0),
            Text(
              timeProvider.worldTime.location ?? '--',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          timeProvider.worldTime.time ?? '--:--',
          style: TextStyle(
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
              ),
            ],
          ),
        ),
        Text(
          timeProvider.worldTime.date ?? '--',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

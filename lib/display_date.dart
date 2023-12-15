import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clock/locations_list/display_image.dart';
import 'package:flutter_clock/services/data_methods.dart';
import 'package:flutter_clock/services/time_provider.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DisplayDate extends StatefulWidget {
  @override
  _DisplayDateState createState() => _DisplayDateState();
}

class _DisplayDateState extends State<DisplayDate> {
  late Timer timer;
  late int secondsLeft;
  late String flagUrl;
  late String timeString;
  late String place;
  late String dateString;

  @override
  void initState() {
    super.initState();
    final TimeProvider timeProvider = context.read<TimeProvider>();
    setTheStates(timeProvider.worldTime);

    timeProvider.addListener(() {
      // Cancel previous timers as data is changed.
      timer.cancel();

      setTheStates(timeProvider.worldTime);

      timer = Timer.periodic(
        Duration(seconds: timeProvider.worldTime.secondsLeft),
        (Timer t) async {
          bool status = await DataMethods().getNewTimeData(timeProvider);
          if (status) setTheStates(timeProvider.worldTime);
        },
      );
    });
  }

  void setTheStates(WorldTime worldTime) {
    if (mounted)
      setState(() {
        flagUrl = worldTime.flag;
        place = worldTime.location;
        timeString = worldTime.time;
        dateString = worldTime.date;
      });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: DisplayImage(url: flagUrl),
            ),
            SizedBox(width: 8.0),
            Flexible(
              child: Text(
                place,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
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
            ),
          ],
        ),
        SizedBox(height: 5.0),
        Text(
          timeString,
          style: GoogleFonts.aladin(
            textStyle: commonStyle.copyWith(
              fontSize: 50.0,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Text(
          dateString,
          style: commonStyle,
        ),
      ],
    );
  }

  TextStyle get commonStyle => const TextStyle(
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
      );
}

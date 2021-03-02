import 'package:flutter/material.dart';
import 'package:flutter_clock/commons.dart';
import 'package:flutter_clock/locations_list/display_image.dart';
import 'package:flutter_clock/services/worldtime.dart';

class LocationItem extends StatelessWidget {
  final WorldTime worldTime;
  final int index;
  final Function onTap;

  const LocationItem({this.worldTime, this.index, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ListTile(
        onTap: () => onTap(),
        shape: RoundedRectangleBorder(borderRadius: Commons.circleRadius),
        leading: DisplayImage(url: worldTime.flag),
        title: Text(
          worldTime.location,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

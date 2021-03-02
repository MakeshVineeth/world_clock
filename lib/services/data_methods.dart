import 'package:flutter/foundation.dart';
import 'package:flutter_clock/services/time_provider.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class DataMethods {
  Future<Response> getData(String urlStr) async {
    try {
      String optionalCorProxy = 'https://cors-anywhere.herokuapp.com/';
      String httpStr = 'https://';
      String fullUrl;

      if (kIsWeb)
        fullUrl = '$optionalCorProxy$httpStr$urlStr';
      else
        fullUrl = '$httpStr$urlStr';

      return await get(fullUrl);
    } catch (e) {
      return null;
    }
  }

  Future<List> getList() async {
    try {
      Response responseList = await getData('worldtimeapi.org/api/timezone');
      List listData = jsonDecode(responseList.body);
      return listData;
    } catch (e) {
      return [];
    }
  }

  Future<WorldTime> taskLoader(
      {String location, String url, String flag}) async {
    try {
      Response response = await getData('worldtimeapi.org/api/timezone/$url');

      Map e = jsonDecode(response.body);

      String dumpTime = e['datetime'];
      String offset = e['utc_offset'].substring(1);
      String check = e['utc_offset'].substring(0, 1);
      DateTime now = DateTime.parse(dumpTime);

      int hours = int.tryParse(offset.split(":")[0]);
      int min = int.tryParse(offset.split(":")[1]);

      if (check.contains('-')) {
        now = now.subtract(Duration(hours: hours, minutes: min));
      } else {
        now = now.add(Duration(hours: hours, minutes: min));
      }

      DateFormat formatter = DateFormat('dd-MMM-yyyy');
      String date = formatter.format(now);

      bool isDayTime = now.hour > 6 && now.hour < 19 ? true : false;
      String time = DateFormat.jm().format(now);
      int secondsLeft = 60 - now.second;

      return WorldTime(
        location: location,
        url: url,
        flag: flag,
        date: date,
        isDayTime: isDayTime,
        time: time,
        secondsLeft: secondsLeft,
      );
    } catch (e) {
      return WorldTime();
    }
  }

  Future<void> getTimeData(TimeProvider timeProvider) async {
    WorldTime old = timeProvider.worldTime;
    WorldTime newTime = await DataMethods()
        .taskLoader(location: old.location, url: old.url, flag: old.flag);

    
    timeProvider.change(newTime);
  }
}

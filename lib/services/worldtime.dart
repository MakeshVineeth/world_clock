import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class WorldTime {
  String location =
      ''; // All initializations to avoid nulls due to lack of connectivity.
  String time = '';
  String url = '';
  bool isDayTime =
      true; // We initialize with a temporary value because bool should never be null!
  List<dynamic> listData = [];
  String flag = '';
  String date = '';
  int secondsLeft = 10; // Refresh rate defaults to 10 seconds for retry.

  WorldTime({@required this.location, @required this.url, this.flag});

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

  Future<void> taskLoader() async {
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
      date = formatter.format(now);

      isDayTime = now.hour > 6 && now.hour < 19 ? true : false;
      time = DateFormat.jm().format(now);
      secondsLeft = 60 - now.second;
    } catch (e) {
      time = 'Cannot fetch data.';
    }
  }

  Future<void> getList() async {
    try {
      Response responseList = await getData('worldtimeapi.org/api/timezone');
      listData = jsonDecode(responseList.body);
    } catch (e) {
      listData.clear();
      listData.add('Offline.');
    }
  }
}

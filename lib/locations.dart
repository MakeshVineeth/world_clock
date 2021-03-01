import 'dart:convert';
import 'dart:io';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  List<WorldTime> locations = [];
  Map listData = {};

  @override
  void initState() {
    super.initState();
    firstSetup();
  }

  void updateTime(index) async {
    try {
      WorldTime instance = locations[index];
      await instance.taskLoader();

      final prefs = await SharedPreferences
          .getInstance(); // We set SharedPrefs only when changing the location
      prefs.setString('url', instance.url);
      prefs.setString('flag', instance.flag);
      prefs.setString('location', instance.location);

      Navigator.pop(context, {
        'time': instance.time,
        'isDayTime': instance.isDayTime,
        'location': instance.location,
        'flag': instance.flag,
        'date': instance.date,
        'url': instance.url,
        'secondsLeft': instance.secondsLeft
      });
    } catch (e) {}
  }

  void firstSetup() async {
    try {
      WorldTime ins = WorldTime(url: "", location: "");
      await ins.getList();
      Map e = jsonDecode(await rootBundle.loadString('assets/countries.json'));
      for (var item in ins.listData) {
        String listItem = item.toString();

        String flag = e['$listItem'].toString().toLowerCase();
        flag = 'https://www.countryflags.io/$flag/flat/32.png';
        if (flag.contains('null')) {
          flag =
              'https://cdn2.iconfinder.com/data/icons/Siena/32/globe%20green.png';
        }

        listItem = listItem.replaceAll('[', '');
        listItem = listItem.replaceAll(' ', '');

        var temp = listItem.split('/');
        String countryName = temp[temp.length - 1];
        countryName = countryName.replaceAll('_', ' ');

        setState(() {
          locations
              .add(WorldTime(url: listItem, location: countryName, flag: flag));
        });
      }
    } catch (e) {}
  }

  Widget loadCards(WorldTime worldTime, int index) {
    return ListTile(
      onTap: () async => updateTime(index),
      leading: getFlagImg(index),
      title: Text(
        worldTime.location,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget getFlagImg(int index) {
    try {
      return FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: '${locations[index].flag}',
      );
    } on SocketException catch (_) {
      return Placeholder();
    }
  }

  Future<List<WorldTime>> search(String searchStr) async {
    await Future.delayed(Duration(seconds: 1));
    List<WorldTime> lists = [];
    for (var i = 0; i < locations.length; i++) {
      String locationURL = locations[i].url.toLowerCase().replaceAll('_', '');
      String searchFormatted = searchStr.toLowerCase().replaceAll(' ', '');
      if (locationURL.contains(searchFormatted)) {
        lists.add(locations.elementAt(i));
      }
    }
    return lists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Choose Location'),
          centerTitle: true,
          backgroundColor: Colors.blue[900],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 2.0),
          child: SearchBar<WorldTime>(
            onSearch: search,
            suggestions: locations,
            onItemFound: (WorldTime foundCard, int index) {
              return loadCards(foundCard, index);
            },
            searchBarStyle: SearchBarStyle(
              padding: EdgeInsets.all(5),
              borderRadius: BorderRadius.circular(20),
            ),
            minimumChars: 2,
            onError: (error) {
              return Center(
                child: Text(
                  "Error occurred : $error",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            emptyWidget: Center(
              child: Text(
                "No Results",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            cancellationWidget: Text(
              "Cancel",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
              child: Icon(
                Icons.search,
              ),
            ),
            hintText: "Type here to search...",
            searchBarPadding: EdgeInsets.all(15.0),
            listPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            iconActiveColor: Colors.blue,
          ),
        ));
  }
}

/// Immutable domain entity representing a location's time and visual state.
class WorldTime {
  final String location;
  final String time;
  final String url;
  final bool isDayTime;
  final String flag;
  final String date;
  final int secondsLeft;

  const WorldTime({
    required this.location,
    required this.url,
    required this.flag,
    required this.date,
    required this.isDayTime,
    this.secondsLeft = 10,
    required this.time,
  });

  static const WorldTime initialPlaceholder = WorldTime(
    location: '',
    url: '',
    flag: '',
    date: '',
    isDayTime: true,
    secondsLeft: 10,
    time: '',
  );

  WorldTime copyWith({
    String? location,
    String? time,
    String? url,
    bool? isDayTime,
    String? flag,
    String? date,
    int? secondsLeft,
  }) {
    return WorldTime(
      location: location ?? this.location,
      time: time ?? this.time,
      url: url ?? this.url,
      isDayTime: isDayTime ?? this.isDayTime,
      flag: flag ?? this.flag,
      date: date ?? this.date,
      secondsLeft: secondsLeft ?? this.secondsLeft,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is WorldTime &&
        other.location == location &&
        other.time == time &&
        other.url == url &&
        other.isDayTime == isDayTime &&
        other.flag == flag &&
        other.date == date &&
        other.secondsLeft == secondsLeft;
  }

  @override
  int get hashCode => Object.hash(
    location,
    time,
    url,
    isDayTime,
    flag,
    date,
    secondsLeft,
  );

  @override
  String toString() =>
      'WorldTime(location: $location, url: $url, time: $time, date: $date, '
      'isDayTime: $isDayTime, secondsLeft: $secondsLeft)';
}

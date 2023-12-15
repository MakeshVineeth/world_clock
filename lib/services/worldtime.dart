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
}

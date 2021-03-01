class WorldTime {
  final String location;
  final String time;
  final String url;
  final bool isDayTime;
  final String flag;
  final String date;
  final int secondsLeft;

  const WorldTime({
    this.location = '',
    this.url = '',
    this.flag = '',
    this.date = '',
    this.isDayTime = true,
    this.secondsLeft = 10,
    this.time = '',
  });
}

/// Domain entity representing a selectable timezone entry.
class TimezoneLocation {
  final String timeZoneId;
  final String displayName;
  final String flagAssetPath;

  const TimezoneLocation({
    required this.timeZoneId,
    required this.displayName,
    required this.flagAssetPath,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TimezoneLocation &&
        other.timeZoneId == timeZoneId &&
        other.displayName == displayName &&
        other.flagAssetPath == flagAssetPath;
  }

  @override
  int get hashCode => Object.hash(timeZoneId, displayName, flagAssetPath);

  @override
  String toString() =>
      'TimezoneLocation(timeZoneId: $timeZoneId, displayName: $displayName, '
      'flagAssetPath: $flagAssetPath)';
}

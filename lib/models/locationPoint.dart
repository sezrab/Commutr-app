class LocationPoint {
  final int id;
  int frequency;
  final double lat;
  final double lon;
  LocationPoint({
    required this.id,
    required this.frequency,
    required this.lat,
    required this.lon,
  });
  String coords() {
    return lat.toString() + "," + lon.toString();
  }
}

class MapLatLng {
  final double latitude;
  final double longitude;

  MapLatLng(this.latitude, this.longitude);

  double get x => longitude;
  double get y => latitude;
}

List<MapLatLng> convexHull(List<MapLatLng> points) {
  if (points.length <= 3) {
    return points;
  }

  points.sort((a, b) => a.x.compareTo(b.x));

  List<MapLatLng> lower = [];
  for (MapLatLng point in points) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower[lower.length - 1], point) <= 0) {
      lower.removeLast();
    }
    lower.add(point);
  }

  List<MapLatLng> upper = [];
  for (MapLatLng point in points.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper[upper.length - 1], point) <= 0) {
      upper.removeLast();
    }
    upper.add(point);
  }

  lower.removeLast();
  upper.removeLast();
  lower.addAll(upper);

  return lower;
}

double cross(MapLatLng o, MapLatLng a, MapLatLng b) {
  return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
}
